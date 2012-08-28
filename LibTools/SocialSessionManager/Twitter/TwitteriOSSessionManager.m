//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


//#define USE_REVERSE_AUTH 1


#import "TwitteriOSSessionManager.h"
#import "Security/SFHFKeychainUtils.h"
#import <Twitter/Twitter.h>
#import "UserSettings.h"

#ifdef USE_REVERSE_AUTH
#import "TWSignedRequest.h"
#endif

#import "UserSettings.h"



#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH          @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_X_AUTH_USERNAME                  @"x_auth_username"
#define TW_X_AUTH_PASSWORD                  @"x_auth_password"
#define TW_SCREEN_NAME                      @"screen_name"
#define TW_USER_ID                          @"user_id"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"



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
    NSString* identifier = [[UserSettings main] objectForKey:USKEYtwitterAccountId];
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
    [self invalidConnexion];
  [self.delegate sessionDidLogout];    
}



- (void)invalidConnexion
{
    [[UserSettings main] removeObjectKey:USKEYtwitterAccountId];

    // also clean oauth credentials
    NSString* username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];
    NSString* token = [[UserSettings main] objectForKey:USKEYtwitterOAuthToken];
    
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthUsername];
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthToken];
    
    
    NSError* error;
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [SFHFKeychainUtils deleteItemForUsername:username andServiceName:BundleName error:&error];
    [SFHFKeychainUtils deleteItemForUsername:token andServiceName:BundleName error:nil];
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
//  DLog(@"TwitterIOSSessionManager onUserInfoReceived info %@", info);
  
  NSString* userid = [info valueForKey:@"id_str"];
  NSString* userscreenname = [info valueForKey:@"screen_name"];
  
  NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
  [user setValue:userid forKey:DATA_FIELD_ID];
    
    NSString* token = [[UserSettings main] objectForKey:USKEYtwitterOAuthToken];
    
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    NSString* tokenSecret = [SFHFKeychainUtils getPasswordForUsername:token andServiceName:BundleName error:nil];
    
    [user setValue:token forKey:DATA_FIELD_TOKEN];
    [user setValue:tokenSecret forKey:DATA_FIELD_TOKEN_SECRET];
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
//  DLog(@"TwitterIOSSessionManager onUserListReceived info %@", info);
  
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
    UIImage* img = [[UIImage alloc] initWithData:imgData];
    
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
  
  return TRUE;
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
      
      // choose an item in the list of registered twitter accounts
    TwitterAccountsViewController* controller = [[TwitterAccountsViewController alloc] initWithNibName:@"TwitterAccountsViewController" bundle:nil accounts:self.accounts target:self];
      //LBDEBUG ICI //parent
//    [self.delegate presentModalViewController:controller animated: YES];  
      
#ifdef USE_REVERSE_AUTH      
      YasoundAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
      NSArray* viewControllers = appDelegate.navigationController.childViewControllers;
      UIViewController* viewController = [viewControllers objectAtIndex:(viewControllers.count-1)];

      [viewController presentModalViewController:controller animated: YES];  
#endif

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

- (void)sessionLoginCanceled
{
  [self.delegate sessionLoginCanceled];
}


- (void)createAccount
{
  //.................................................................................
  // get registered username 
  //
    NSString* username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];


  //.................................................................................
  // get secured credentials (that have been store in the KeyChain by TwitterOAuthSessionManager
  //
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:BundleName error:&error];

  if (data == nil)
  {
      DLog(@"no credentials recorded. can not create account.");
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
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  NSRange end = [data rangeOfString:@"&oauth_token_secret=" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract oauth_token
  NSString* oauth_token = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  begin = end;
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract oauth_token_secret
  NSString* oauth_token_secret = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
    //LBDEBUG
    assert (oauth_token != nil);
    [[UserSettings main] setObject:oauth_token forKey:USKEYtwitterOAuthToken];

    assert (oauth_token_secret != nil);
    [SFHFKeychainUtils storeUsername:oauth_token andPassword:oauth_token_secret  forServiceName:BundleName updateExisting:YES error:nil];
    
  //  DLog(@"oauth_token %@", oauth_token);
    
  //  DLog(@"oauth_token_secret %@", oauth_token_secret);
  
  
  
  
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
         [[UserSettings main] setObject:identifier forKey:USKEYtwitterAccountId];
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
  
  DLog(@"selected accountDescription %@", account.accountDescription);
  DLog(@"selected username %@", account.username);
    

  // store this account identifier in order to load it automatically the next times
  NSString* identifier = self.account.identifier;
    [[UserSettings main] setObject:identifier forKey:USKEYtwitterAccountId];

    
    // check if the oauth token and token secret are already there
    NSString* token = [[UserSettings main] objectForKey:USKEYtwitterOAuthToken];

    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    NSString* tokenSecret = [SFHFKeychainUtils getPasswordForUsername:token andServiceName:BundleName error:nil];
    
    // no. request reverse auth 
    if ((token == nil) || (tokenSecret == nil))
    {
        DLog(@"need to perform reverse auth.");
        [self performReverseAuth];
        return;
    }
    
    
    // yes. go on.
  
  [self.delegate sessionDidLogin:YES];
}








#pragma mark - Reverse Auth




//- (void)performReverseAuth
//{
//        NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
//        
//        // "reverse_auth" is a required parameter
//        NSDictionary *dict = [NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
//        TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
//        
//        [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            if (!data) 
//            {
//                //[self showAlert:@"Unable to receive a request_token." title:@"Yikes"];
//                [self _handleError:error forResponse:response];
//            }
//            else 
//            {
//                NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                
//                //
//                //  Step 2)  Ask Twitter for the user's auth token and secret
//                //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
//                //
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    
//                    NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[TWSignedRequest consumerKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
//                    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
//                    TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];
//                    
//                    //  Obtain the user's permission to access the store
//                            [step2Request setAccount:self.account];
//                            [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
//                    {
//                                if (!responseData) 
//                                {
//                                    //[self showAlert:@"Error occurred in Step 2.  Check console for more info." title:@"Yikes"];
//                                    [self _handleError:error forResponse:response];
//                                }
//                                else 
//                                {
//                                    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//                                    [self _handleStep2Response:responseStr];
//                                }
//                    }];
//                    
//                });
//            }
//        }];
//
//}

                               
                               
                               
- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;

    DLog(@"reverse auth error!");
    DLog(@"[Step Two Request Error]: %@", [error localizedDescription]);
    DLog(@"[Step Two Request Error]: Response Code:%d \"%@\" ", [urlResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]);
    
    [self.delegate sessionDidLogin:NO];
}



#define RESPONSE_EXPECTED_SIZE 4
- (void)_handleStep2Response:(NSString *)responseStr
{
    NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];
    
    // We are expecting a response dict of the format:
    //
    // {
    //     "oauth_token" = ...
    //     "oauth_token_secret" = ...
    //     "screen_name" = ...
    //     "user_id" = ...
    // }
    
    if ([dict count] == RESPONSE_EXPECTED_SIZE) 
    {
        //[self showAlert:[NSString stringWithFormat:@"User: %@\nUser ID: %@", [dict objectForKey:TW_SCREEN_NAME], [dict objectForKey:TW_USER_ID]] title:@"Success!"];
        // DLog(@"The user's info for your server:\n%@", dict);
        DLog(@"reverse auth success!");

    }
    else 
    {
        //[self showAlert:@"The response doesn't seem correct.  Please check the console." title:@"Hmm..."];
        DLog(@"reverse auth received answer but its size is not what we expected:");
        DLog(@"The user's info for your server:\n%@", dict);
    }
    
    NSString* token = [dict objectForKey:@"oauth_token"];
    NSString* token_secret = [dict objectForKey:@"oauth_token_secret"];
    if (token == nil)
    {
        DLog(@"reverse auth error : dit not retrieved token!");
         [self.delegate sessionDidLogin:NO];
        return;
    }
    else
    {
        // store token and secret
        [[UserSettings main] setObject:token ForKey:USKEYtwitterOAuthToken];
    }
    
    
    if (token_secret == nil)
    {
        DLog(@"reverse auth error : dit not retrieved token_secret!");
        [self.delegate sessionDidLogin:NO];
        return;
    }
    else
    {
        NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
        [SFHFKeychainUtils storeUsername:token andPassword:token_secret  forServiceName:BundleName updateExisting:YES error:nil];
    }
    
    [self.delegate sessionDidLogin:YES];
        
}





@end
