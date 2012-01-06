//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//



#import "TwitteriOSSessionManager.h"
#import "Security/SFHFKeychainUtils.h"
#import <Twitter/Twitter.h>
#import "YasoundAppDelegate.h"



#define ACCOUNT_IDENTIFIER @"twitterAccountIdentifier"

@implementation TwitteriOSSessionManager

@synthesize store = _store;
@synthesize account = _account;
@synthesize accounts = _accounts;


// LBDEBUG
//#define kAccessToken @"409372338-sdDFNhWpVjomGbsAhbIBjAYnBLDeThvajQEKe9I6"
//#define kAccessTokenSecret @"HjCLrPG60q9FlmPXIwPNx2iAm7EA3KOrGmzu4z08"      


- (void)setTarget:(id<SessionDelegate>)delegate
{
  self.delegate = delegate;
}

- (void)login
{
  _granted = NO;
  
  self.store = [[ACAccountStore alloc] init];
  self.account = nil;

  // check if a twitter account has already been selected as default
  NSString* identifier = [[NSUserDefaults standardUserDefaults] valueForKey:ACCOUNT_IDENTIFIER];
  if (identifier != nil)
    self.account = [self.store accountWithIdentifier:identifier];

  // if no account has been selected as default, or if it has been deleted,
  // load the available accounts to select a new one.
  if (self.account == nil)
  {
    [self loadTwitterAccounts];
  }
  else
  {
    // consider everything's fine
    [self.delegate sessionDidLogin:YES];
  }
}



- (void)logout
{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCOUNT_IDENTIFIER];

  // also clean oauth credentials
  NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:OAUTH_USERNAME];
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  [SFHFKeychainUtils deleteItemForUsername:username andServiceName:BundleName error:&error];
  
  [self.delegate sessionDidLogout];    
}


- (BOOL)authorized
{
  return (self.account != nil);
}


- (BOOL)requestGetInfo:(SessionRequestType)requestType
{
  if (!self.account)
    return NO;
  
  if (requestType == SRequestInfoUser)
  {
    TWRequest* request = [[TWRequest alloc]
                              initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"] 
                              parameters:[NSDictionary dictionaryWithObject:self.account.username forKey:@"screen_name"] 
                              requestMethod:TWRequestMethodGET];
    
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
     {
       [self performSelectorOnMainThread:@selector(onUserInfoReceived:) withObject:[NSArray arrayWithObjects:responseData,urlResponse,nil] waitUntilDone:NO];
     }];
    
    return YES;
  }

  
  if ((requestType == SRequestInfoFriends) || (requestType == SRequestInfoFollowers))
  {
    NSString* url = @"https://api.twitter.com/1/statuses/friends.json";
    
    if (requestType == SRequestInfoFollowers)
      url = @"https://api.twitter.com/1/statuses/followers.json";
      
    TWRequest* request = [[TWRequest alloc] 
                          initWithURL:[NSURL URLWithString:url] 
                          parameters:[NSDictionary dictionaryWithObject:self.account.username forKey:@"screen_name"] 
                          requestMethod:TWRequestMethodGET];
    
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
     {
       [self performSelectorOnMainThread:@selector(onUserListReceived:) withObject:[NSArray arrayWithObjects:responseData,urlResponse,[NSNumber numberWithInteger:requestType], nil] waitUntilDone:NO];
     }];

    return YES;
  }
  
  return NO;
}





- (void)onUserInfoReceived:(NSArray*)args
{
  NSData* responseData = [args objectAtIndex:0];
  NSHTTPURLResponse* urlResponse = [args objectAtIndex:1];
  
  if ([urlResponse statusCode] != 200)
  {
    [self.delegate requestDidFailed:SRequestInfoUser error:nil errorMessage:[NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]];
    return;
  }
  
  NSError* jsonParsingError = nil;
  NSDictionary* info = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
    //LBDEBUG
  NSLog(@"%@", info);
  
  NSString* userid = [info valueForKey:@"id_str"];
  NSString* userscreenname = [info valueForKey:@"screen_name"];
  
  NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
  [user setValue:userid forKey:DATA_FIELD_ID];
    [user setValue:[[NSUserDefaults standardUserDefaults] objectForKey:DATA_FIELD_TOKEN] forKey:DATA_FIELD_TOKEN];
    [user setValue:[[NSUserDefaults standardUserDefaults] objectForKey:DATA_FIELD_TOKEN_SECRET] forKey:DATA_FIELD_TOKEN_SECRET];
  [user setValue:@"twitter" forKey:DATA_FIELD_TYPE];
  [user setValue:self.account.username forKey:DATA_FIELD_USERNAME];
    [user setValue:userscreenname forKey:DATA_FIELD_NAME];
    
    //twitter doesn't provide the user's email, event if he's authenticated
    [user setValue:@"" forKey:DATA_FIELD_EMAIL];
  
  NSArray* data = [NSArray arrayWithObjects:user, nil];
  
  [self.delegate requestDidLoad:SRequestInfoUser data:data];
}




- (void)onUserListReceived:(NSArray*)args
{
  NSData* responseData = [args objectAtIndex:0];
  NSHTTPURLResponse* urlResponse = [args objectAtIndex:1];
  NSInteger requestCode = [[args objectAtIndex:2] integerValue];
  SessionRequestType requestType = requestCode;
  
  if ([urlResponse statusCode] != 200)
  {
    [self.delegate requestDidFailed:requestType error:nil  errorMessage:[NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]];
    return;
  }
  
  NSError* jsonParsingError = nil;
  NSDictionary* info = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
  NSLog(@"%@", info);
  
  NSMutableArray* data = [[NSMutableArray alloc] init];
  for (NSDictionary* user in info)
  {
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:[user valueForKey:@"id"] forKey:DATA_FIELD_ID];
    [userInfo setValue:@"twitter" forKey:DATA_FIELD_TYPE];
    [userInfo setValue:[user valueForKey:@"screen_name"] forKey:DATA_FIELD_USERNAME]; // no username directly available from this list
    [userInfo setValue:[user valueForKey:@"name"] forKey:DATA_FIELD_NAME];
    
    [data addObject:userInfo];
  }

  
  [self.delegate requestDidLoad:requestType data:data];
}








- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl;
{
  TWRequest* request;
  
  if (pictureUrl == nil)
  {
    request = [[TWRequest alloc] initWithURL: [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"]
                                               parameters:[NSDictionary dictionaryWithObject:message 
                                               forKey:@"status"] requestMethod:TWRequestMethodPOST];             
  }
  else
  {
    request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST];
  
    NSData* imgData = [NSData dataWithContentsOfURL:pictureUrl];
    UIImage* img = [[UIImage alloc] initWithData:imgData cache:NO];
    
    NSData* data = UIImagePNGRepresentation(img);
    [request addMultiPartData:data withName:@"media" type:@"image/png"];
    data = [[NSString stringWithFormat:message] dataUsingEncoding:NSUTF8StringEncoding];
    [request addMultiPartData:data withName:@"status" type:@"text/plain"];
  }
  
  [request setAccount:self.account];
  [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
   {
     [self performSelectorOnMainThread:@selector(onMessagePosted:) withObject:urlResponse waitUntilDone:NO];
   }];
}

- (void)onMessagePosted:(NSHTTPURLResponse*)urlResponse
{
  if ([urlResponse statusCode] == 200)
    [self.delegate requestDidLoad:SRequestPostMessage data:nil];
  else
    [self.delegate requestDidFailed:SRequestPostMessage error:nil   errorMessage:[NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]];
}








#pragma mark - Data Management


- (void)loadTwitterAccounts
{
  ACAccountType* accountTypeTwitter = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
  [self.store requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) 
   {
     if (!granted) 
     {
       [self.delegate sessionDidLogin:NO];
       return;
     }

     dispatch_sync(dispatch_get_main_queue(), ^
     {
       self.accounts = [self.store accountsWithAccountType:accountTypeTwitter];
       [self performSelectorOnMainThread:@selector(onAccountsLoaded) withObject:nil waitUntilDone:NO];
     });
   }];
}




- (void)onAccountsLoaded
{
  // no twitter account registered yet.
  if ([self.accounts count] == 0)
  {
    // here's the trick : 
    // 1. use the TwitterOAuthSessionManager dialog to let the user enter its username and password
    // 2. let [self] be the delegate of the TwitterOAuthSessionManager
    // 3. when TwitterOAuthSessionManager returns (through delegate), get the credentials to create and register a twitter account for the user
    _oauthManager = [[TwitterOAuthSessionManager alloc] init];
    [_oauthManager retain];
    [_oauthManager setTarget:self];
    [_oauthManager login:self.delegate];
  }
  // choose an account and register the app
  else
  {
    TwitterAccountsViewController* controller = [[TwitterAccountsViewController alloc] initWithNibName:@"TwitterAccountsViewController" bundle:nil accounts:self.accounts target:self];
      //LBDEBUG ICI //parent
//    [self.delegate presentModalViewController:controller animated: YES];  
      YasoundAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
      NSArray* viewControllers = appDelegate.navigationController.childViewControllers;
      UIViewController* viewController = [viewControllers objectAtIndex:(viewControllers.count-1)];

      [viewController presentModalViewController:controller animated: YES];  

    [controller release];
  }

}




#pragma mark - SessionDelegate

// TwitterOAuthSessionManager has been in charge of the user dialog, 
// to let the user enter its username and password, and connect to the twitter server.
// we are now able to get the user credentials and create a twitter account for the user 
- (void)sessionDidLogin:(BOOL)authorized
{
  [_oauthManager release];
  
  [self createAccount];  
}


- (void)sessionLoginFailed
{
    [self.delegate sessionLoginFailed];
}


- (void)createAccount
{
  //.................................................................................
  // get registered username 
  //
  NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];


  //.................................................................................
  // get secured credentials (that have been store in the KeyChain by TwitterOAuthSessionManager
  //
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:BundleName error:&error];

  if (data == nil)
  {
      NSLog(@"no credentials recorded. can not create account.");
      return;
  }
    

  //.................................................................................
  // and now, parse the secured data string, to extract the user token and its associated secret
  //
  NSInteger length = [data length];
  NSRange range = NSMakeRange(0, length);
  
  NSRange begin = [data rangeOfString:@"oauth_token=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  NSRange end = [data rangeOfString:@"&oauth_token_secret=" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract oauth_token
  NSString* oauth_token = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  begin = end;
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract oauth_token_secret
  NSString* oauth_token_secret = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
    //LBDEBUG
    assert (oauth_token != nil);
    [[NSUserDefaults standardUserDefaults] setValue:oauth_token forKey:DATA_FIELD_TOKEN];
    assert (oauth_token_secret != nil);
    [[NSUserDefaults standardUserDefaults] setValue:oauth_token_secret forKey:DATA_FIELD_TOKEN_SECRET];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
  //  NSLog(@"oauth_token %@", oauth_token);
    
  //  NSLog(@"oauth_token_secret %@", oauth_token_secret);
  
  
  
  
  //.................................................................................
  //
  // now create the twitter account
  
  ACAccountType* accountTypeTwitter = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  ACAccount* newAccount = [[ACAccount alloc] initWithAccountType:accountTypeTwitter];
  ACAccountCredential* credential = [[ACAccountCredential alloc] initWithOAuthToken:oauth_token tokenSecret:oauth_token_secret];
  newAccount.credential = credential;
  
  [self.store saveAccount:newAccount withCompletionHandler:^(BOOL granted, NSError *error) 
   {
     if (granted)
     {
       self.account = newAccount;
       
       // store this new account identifier in order to load it automatically the next times
       NSString* identifier = self.account.identifier;
       [[NSUserDefaults standardUserDefaults] setValue:identifier forKey:ACCOUNT_IDENTIFIER];
     }

     _granted = granted;
     [self performSelectorOnMainThread:@selector(onAccountCreated:) withObject:[NSNumber numberWithBool:granted] waitUntilDone:NO];
   }];
}





- (void)onAccountCreated:(BOOL)granted
{
  NSString* message;
  if (_granted)
    message = @"Your Twitter account has been registered. Check your device's Settings.";
  else
    message = @"Your Twitter account could not be registered!";
    
    
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                     cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [av show];
  [av release];  
}





#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (_granted)
    [self.delegate sessionDidLogin:YES];
  else
    [self.delegate sessionDidLogin:NO];
}


#pragma mark - TwitterAccountsDelegate

- (void)twitterDidSelectAccount:(ACAccount*)account
{
  self.account = account;
  
//  NSLog(@"accountDescription %@", account.accountDescription);
//  NSLog(@"username %@", account.username);

  // store this account identifier in order to load it automatically the next times
  NSString* identifier = self.account.identifier;
  [[NSUserDefaults standardUserDefaults] setValue:identifier forKey:ACCOUNT_IDENTIFIER];
  
  
  [self.delegate sessionDidLogin:YES];
}











@end
