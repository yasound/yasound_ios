//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//



#import "TwitteriOSSessionManager.h"



@implementation TwitteriOSSessionManager

@synthesize store = _store;
@synthesize account = _account;
@synthesize accounts = _accounts;


#define kAccessToken @"409372338-sdDFNhWpVjomGbsAhbIBjAYnBLDeThvajQEKe9I6"
#define kAccessTokenSecret @"HjCLrPG60q9FlmPXIwPNx2iAm7EA3KOrGmzu4z08"      


- (void)login:(UIViewController*)target
{
  self.delegate = target;
  self.store = [[ACAccountStore alloc] init];

  
  [self loadTwitterAccounts];
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
  // no twitter account register.
  // display sign in dialog , save the account and register the app
  if ([self.accounts count] == 0)
  {
    // An existing credential may be provided when creating an account.
    // For example, to create a system Twitter account using an existing OAuth token/secret pair:
    //
    // 1. Create the new account instance.
    // 2. Set the account type.
    // 3. Create an ACAccountCredential using your existing OAuth token/secret and set the account's credential property.
    // 4. Save the account.
    //
    // The account will be validated and saved as a system account.
    
    ACAccountType* accountTypeTwitter = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    ACAccount* newAccount = [[ACAccount alloc] initWithAccountType:accountTypeTwitter];
    ACAccountCredential* credential = [[ACAccountCredential alloc] initWithOAuthToken:kAccessToken tokenSecret:kAccessTokenSecret];
    newAccount.credential = credential;
    
    [self.store saveAccount:newAccount withCompletionHandler:^(BOOL granted, NSError *error) 
     {
        if (granted)
        {
          self.account = newAccount;
          [self.delegate sessionDidLogin:YES];
        }
     }];

      
    
  }
  // choose an account and register the app
  else
  {
    TwitterAccountsViewController* controller = [[TwitterAccountsViewController alloc] initWithNibName:@"TwitterAccountsViewController" bundle:nil accounts:self.accounts target:self];
    [self.delegate presentModalViewController:controller animated: YES];  
    [controller release];
  }

}




#pragma mark - TwitterAccountsDelegate




- (void)twitterDidSelectAccount:(ACAccount*)account
{
  self.account = account;
  
  NSLog(@"accountDescription %@", account.accountDescription);
  NSLog(@"username %@", account.username);
  
  [self.delegate sessionDidLogin:YES];
}











@end
