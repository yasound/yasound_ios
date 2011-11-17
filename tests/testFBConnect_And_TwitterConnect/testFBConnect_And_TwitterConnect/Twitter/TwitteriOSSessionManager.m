//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//



#import "TwitteriOSSessionManager.h"
#import "Security/SFHFKeychainUtils.h"


#define ACCOUNT_IDENTIFIER @"twitterAccountIdentifier"

@implementation TwitteriOSSessionManager

@synthesize store = _store;
@synthesize account = _account;
@synthesize accounts = _accounts;


// LBDEBUG
//#define kAccessToken @"409372338-sdDFNhWpVjomGbsAhbIBjAYnBLDeThvajQEKe9I6"
//#define kAccessTokenSecret @"HjCLrPG60q9FlmPXIwPNx2iAm7EA3KOrGmzu4z08"      


- (void)login:(UIViewController*)target
{
  _granted = NO;
  
  self.delegate = target;
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

}


- (BOOL)authorized
{
  return (self.account != nil);
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
    [_oauthManager login:self withParentViewController:self.delegate];
  }
  // choose an account and register the app
  else
  {
    TwitterAccountsViewController* controller = [[TwitterAccountsViewController alloc] initWithNibName:@"TwitterAccountsViewController" bundle:nil accounts:self.accounts target:self];
    [self.delegate presentModalViewController:controller animated: YES];  
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



- (void)createAccount
{
  //.................................................................................
  // get registered username 
  //
  NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:AUTH_NAME];


  //.................................................................................
  // get secured credentials (that have been store in the KeyChain by TwitterOAuthSessionManager
  //
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:BundleName error:&error];

  

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
