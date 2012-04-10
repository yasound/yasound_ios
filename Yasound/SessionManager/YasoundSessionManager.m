//
//  YasoundSessionManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundSessionManager.h"
#import "Security/SFHFKeychainUtils.h"
#import "FacebookSessionManager.h"
#import "TwitterSessionManager.h"
//#import "ActivityAlertView.h"

@implementation YasoundSessionManager

@synthesize registered;
@synthesize associatingFacebook;
@synthesize associatingTwitter;
@synthesize associatingYasound;
@synthesize associatingAutomatic;

static YasoundSessionManager* _main = nil;


+ (YasoundSessionManager*)main
{
    if (_main == nil)
    {
        _main = [[YasoundSessionManager alloc] init];
    }
    
    return _main;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        NSDictionary* dico = [[NSUserDefaults standardUserDefaults] objectForKey:@"YasoundSessionManager"];
        if (dico != nil)
            _dico = [[NSMutableDictionary alloc] initWithDictionary:dico];
        else
            _dico = [[NSMutableDictionary alloc] init];
        
        NSLog(@"import dico %@", _dico);
        
        self.associatingFacebook = NO;
        self.associatingTwitter = NO;
        self.associatingYasound = NO;
        self.associatingAutomatic = NO;
        _error = NO;

        
        
        [_dico retain];
            
    }
    return self;
}


- (void)dealloc
{
    [_dico release];
    [super dealloc];
}




// return YES if an account has already been created.
// ! LOCAL TEST ON THE DEVICE, NOT ON THE SERVER
- (BOOL)getAccount:(User*)user
{
    int user_id_value = [user.id intValue];
    NSNumber* user_id = [NSNumber numberWithInt:user_id_value];
     
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:@"YasoundSessionManagerAccounts"];
    for (int i = 0; i < array.count; i++)
    {
        NSNumber* userID = [array objectAtIndex:i];
        if ([userID isEqualToNumber:user_id])
            return YES;
    }
    
    return NO;
}
//
//- (BOOL)getAccount:(User*)user
//{
//    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:@"YasoundSessionManagerAccounts"];
//    for (int i = 0; i < array.count; i++)
//    {
//        NSNumber* userID = [array objectAtIndex:i];
//        if ([userID isEqualToNumber:user.id])
//            return YES;
//    }
//    
//    return NO;
//}


// register the user account LOCALLY, ON THE DEVICE
- (void)addAccount:(User*)user
{
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:@"YasoundSessionManagerAccounts"];
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:array];
    
    int userID = [user.id intValue];
    [newArray addObject:[NSNumber numberWithInt:userID]];
    [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"YasoundSessionManagerAccounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}









- (void)setRegistered:(BOOL)registered
{
    [_dico setObject:[NSNumber numberWithBool:registered] forKey:@"registered"];
}
     

- (BOOL)registered
{
    return [[_dico objectForKey:@"registered"] boolValue];
}


- (NSString*)loginType
{
    NSString* str = [_dico objectForKey:@"loginType"];
    return str;
}

- (void)setLoginType:(NSString *)loginType
{
    if (loginType == nil)
    {
        [_dico removeObjectForKey:@"loginType"];
        return;
    }
    
    [_dico setObject:loginType forKey:@"loginType"];
}


- (void)save
{
    NSLog(@"save : %@", _dico);
    
    [[NSUserDefaults standardUserDefaults] setObject:_dico forKey:@"YasoundSessionManager"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}






- (BOOL)loginForYasoundWithTarget:(id)target action:(SEL)action
{
    if (!self.registered)
        return NO;
    if (![self.loginType isEqualToString:LOGIN_TYPE_YASOUND])
        return NO;
    
    _target = target;
    _action = action;
    _error = NO;

    
    NSString* email = [_dico objectForKey:@"email"];
    NSString* pword = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:@"YasoundSessionManager" error:nil];

    // login request to server
    [[YasoundDataProvider main] login:email password:pword target:self action:@selector(loginForYasoundRequestDidReturn:info:)];
}

- (BOOL)loginForFacebookWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _error = NO;
    
    self.loginType = LOGIN_TYPE_FACEBOOK;

    [[FacebookSessionManager facebook] setTarget:self];
    [[FacebookSessionManager facebook] login];    
}



- (BOOL)loginForTwitterWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _error = NO;
    
    self.loginType = LOGIN_TYPE_TWITTER;

    [[TwitterSessionManager twitter] setTarget:self];
    [[TwitterSessionManager twitter] login];
}





- (void) loginForYasoundRequestDidReturn:(User*)user info:(NSDictionary*)info
{
    NSLog(@"YasoundSessionManager login returned : %@ %@", user, info);
    
    if (user == nil)
    {
        [self loginError];
        return;
    }
    
    NSLog(@"YasoundSessionManager yasound login successful!");
    
    // callback
    assert(_target);
    [_target performSelector:_action withObject:user];
    
}














#pragma mark - YasoundDataProvider actions

- (void) loginSocialValidated:(User*)user info:(NSDictionary*)info
{
    if (_error)
    {
        NSLog(@"loginSocialValidated returned but canceled because error");
        return;
    }

    NSLog(@"loginSocialValidated returned : %@ %@", user, info);
    
    if (user == nil)
    {
        assert(_target);
        [self loginError];
        // callback
        //[_target performSelector:_action withObject:nil];        
        return;
    }
    
    if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        [self registerForFacebook];
    }
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        [self registerForTwitter];
    }

    
    // callback
    assert(_target);
    [_target performSelector:_action withObject:user];
}







#pragma mark - UIAlertViewDelegate

- (void)loginError
{
    User* nilUser = nil;
    _error = YES;
    [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"Login" forKey:@"error"]];
//    [ActivityAlertView close];
    
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:NSLocalizedString(@"YasoundSessionManager_login_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [av show];
//    [av release];  
}

- (void)loginCanceled
{
  User* nilUser = nil;
  _error = NO;
  [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"Cancel" forKey:@"error"]];
  //    [ActivityAlertView close];
  
  //    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:NSLocalizedString(@"YasoundSessionManager_login_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  //    [av show];
  //    [av release];  
}

- (void)userInfoError
{
    User* nilUser = nil;
    _error = YES;
    [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"UserInfo" forKey:@"error"]];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    // refers to (user == nil) in loginRequestDidReturn
//    
//    // callback
//    assert(_target);
//    [_target performSelector:_action withObject:nil];
//}







- (void)logoutWithTarget:(id)target action:(SEL)action
{
    // do it for all, this way you're sure :)
    if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        _target = target;
        _action = action;
        [FacebookSessionManager facebook].delegate = self;
        [[FacebookSessionManager facebook] logout];
    }
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        _target = target;
        _action = action;
        [TwitterSessionManager twitter].delegate = self;
        [[TwitterSessionManager twitter] logout];
    }
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_YASOUND])
    {
        NSString* email = [_dico objectForKey:@"email"];
        [SFHFKeychainUtils deleteItemForUsername:email andServiceName:@"YasoundSessionManager" error:nil];
    }
    

    [_dico release];
    _dico = nil;
    _dico = [[NSMutableDictionary alloc] init];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"YasoundSessionManager"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // callback
    [target performSelector:action];
}



- (void)registerForYasound:(NSString*)email withPword:(NSString*)pword
{
    self.loginType = LOGIN_TYPE_YASOUND;
    self.registered = YES;
    
    // store email
    [_dico setObject:email forKey:@"email"];
    
    // store pword with security
    [SFHFKeychainUtils storeUsername:email andPassword:pword  forServiceName:@"YasoundSessionManager" updateExisting:YES error:nil];

    // and add the account as associated account
    [self accountManagerAdd:LOGIN_TYPE_YASOUND withInfo:[NSDictionary dictionaryWithObjectsAndKeys:email,@"email",pword,@"pword",nil]];

    [self save];
}


- (void)registerForFacebook
{
    self.loginType = LOGIN_TYPE_FACEBOOK;
    self.registered = YES;
    
    // local account manager is handle in the SocialSessionManager delegate
    
    NSLog(@"registerForFacebook self.loginType %@", self.loginType);
    
    [self save];

}

- (void)registerForTwitter
{
    self.loginType = LOGIN_TYPE_TWITTER;
    self.registered = YES;
    
    NSLog(@"registerForTwitter self.loginType %@", self.loginType);
    
    // local account manager is handle in the SocialSessionManager delegate

    [self save];

}




#pragma mark - post Messages


- (BOOL)postMessageForFacebook:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl link:(NSURL*)link target:(id)target action:(SEL)action
{
    _postTarget = target;
    _postAction = action;
    [[FacebookSessionManager facebook] requestPostMessage:message title:title picture:pictureUrl link:link];
}



- (BOOL)postMessageForTwitter:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl target:(id)target action:(SEL)action
{
    _postTarget = target;
    _postAction = action;
    [[TwitterSessionManager twitter] requestPostMessage:message title:title picture:pictureUrl];
}












#pragma mark - SessionDelegate

- (void)sessionDidLogin:(BOOL)authorized
{
    NSLog(@"YasoundSessionManager::sessionDidLogin    authorized %d", authorized);
    
    if (self.associatingAutomatic)
    {
        NSLog(@"associating automatic.");
        [_target performSelector:_action withObject:nil];
        return;
    }
    
    
    if (self.associatingFacebook)
    {
        if (authorized)
            [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil];
    }
    else if (self.associatingTwitter)
    {
        if (authorized)
            [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil];
    }
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        if (authorized)
            [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil];
    }
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        if (authorized)
            [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil];
    }
}


- (void)requestDidFailed:(SessionRequestType)requestType error:(NSError*)error errorMessage:(NSString*)errorMessage
{
    // duplicate message, let's act it's no error, just let the dialog spinner die himself
//    NSRange range = [errorMessage rangeOfString:@"#506"];
//    if (range.location != NSNotFound)
//        return;

    if (requestType == SRequestInfoUser)
    {
        NSLog(@"requestDidFailed : could not get user info.");

        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@", [error description]);
        NSLog(@"%@", errorMessage);

        [self userInfoError];
        
        
        
        return;
    }
    
    

    if (requestType == SRequestPostMessage)
    {
        NSLog(@"requestDidFailed : could not post message.");
        
        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@", [error description]);
        NSLog(@"%@", errorMessage);
        
        if ((_postTarget != nil) && (_postAction != nil))
            [_postTarget performSelector:_postAction withObject:[NSNumber numberWithBool:NO]];
        return;
    }
}


- (void)requestDidLoad:(SessionRequestType)requestType data:(NSArray*)data;
{
    if (requestType == SRequestInfoUser)
    {
        [self requestInfoUserDidLoad:data];
        return;
    }


    if (requestType == SRequestPostMessage)
    {
        [self requestPostMessageDidLoad:data];
        return;
    }
}


- (void)sessionLoginFailed
{
    self.loginType = nil;
    [self loginError];
}

- (void)sessionLoginCanceled
{
  self.loginType = nil;
  [self loginCanceled];
}


- (void)sessionDidLogout
{
    // callback
    assert(_target);
    [_target performSelector:_action];
}









- (void)requestInfoUserDidLoad:(NSArray*)data
{
    if ([data count] == 0)
    {
        NSLog(@"requestDidLoad SRequestInfoUser error : no info.");
        [self userInfoError];
        return;
    }
    
    NSDictionary* dico = [data objectAtIndex:0];
    
    NSString* username = [dico valueForKey:DATA_FIELD_USERNAME];
    NSString* name = [dico valueForKey:DATA_FIELD_NAME];
    NSString* uid = [dico valueForKey:DATA_FIELD_ID];
    NSString* token = [dico valueForKey:DATA_FIELD_TOKEN];
    NSString* email = [dico valueForKey:DATA_FIELD_EMAIL];

    if (username == nil)
        username = name;
    
    if (email == nil)
        email = @"";

    NSLog(@"ready to request social login to the server with : ");
    NSLog(@"username '%@'", username);
    NSLog(@"name '%@'", name);
    NSLog(@"uid '%@'", uid);
    NSLog(@"token '%@'", token);
    NSLog(@"email '%@'", email);
    
//    // TAG ACTIVITY ALERT
//    if (![ActivityAlertView isRunning])
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    
    //
    // associating process
    //
    if (self.associatingFacebook)
    {
        NSLog(@"facebook social associating request");
        
        // request to yasound server
        [[YasoundDataProvider main] associateAccountFacebook:username type:LOGIN_TYPE_FACEBOOK uid:uid token:token email:email target:self action:@selector(associatingSocialValidated:)];
    }
    
    
    else if (self.associatingTwitter)
    {
        NSLog(@"twitter social associating request");


        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        // request to yasound server
        [[YasoundDataProvider main] associateAccountTwitter:username  type:LOGIN_TYPE_TWITTER uid:uid token:token tokenSecret:tokenSecret email:email target:self action:@selector(associatingSocialValidated:)];
    }
    
    //
    // login process
    //
    else if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        NSLog(@"facebook social login request");
//      NSString* n = username;
//      if (!n)
//        n = name;
        
        [[YasoundDataProvider main] loginFacebook:username type:@"facebook" uid:uid token:token email:email target:self action:@selector(loginSocialValidated:info:)];
    }
    
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        NSLog(@"twitter social login request");
        
        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        if (token == nil)
            NSLog(@"error Twitter token is nil!");
        if (tokenSecret == nil)
            NSLog(@"error Twitter tokenSecret is nil!");
        
        // don't bother asking the server if you don't the requested info at this point
        if ((token == nil) || (tokenSecret == nil))
        {
            // callback
            assert(_target);
            [_target performSelector:_action withObject:nil];

            return;
        }
        
        // ok, request login to server
        [[YasoundDataProvider main] loginTwitter:username type:@"twitter" uid:uid token:token tokenSecret:tokenSecret email:email target:self action:@selector(loginSocialValidated:info:)];
    }
}


- (void)requestPostMessageDidLoad:(NSArray*)data
{
    NSLog(@"the message has been post to your wall.");
    
    if ((_postTarget != nil) && (_postAction != nil))
        [_postTarget performSelector:_postAction withObject:[NSNumber numberWithBool:YES]];
}





















#pragma mark - accounts association


- (void)associateClean
{
    self.associatingFacebook = NO;
    self.associatingTwitter = NO;
    self.associatingYasound = NO;
    self.associatingAutomatic = NO;
}


// routine to "log in" all the associated accounts
// used when the user launches the apps and logs in automatically for instance
// => we need to login all the other accounts as well
- (void)associateAccountsAutomatic
{
    [self associateClean];
    
    if (![self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK]  && [self isAccountAssociated:LOGIN_TYPE_FACEBOOK])
    {
        NSLog(@"\n Automatic associating account Facebook.");
        [self associateAccountFacebook:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
    }

    if (![self.loginType isEqualToString:LOGIN_TYPE_TWITTER] && [self isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
        NSLog(@"\n Automatic associating account Twitter.");
        [self associateAccountTwitter:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
    }

    // don't need to do anything for yasound
//    if (![self.loginType isEqualToString:LOGIN_TYPE_YASOUND] && [self isAccountAssociated:LOGIN_TYPE_YASOUND])
//    {
//        NSLog(@"\n Automatic associating account Yasound.");
//        [self associateAccountYasound:[account objectForKey:@"email"] password:[account objectForKey:@"pword"] target:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
//    }
    
    
}


- (void)associateAccountsAutomaticReturned:(NSDictionary*)info
{
    NSLog(@"associateAccountsAutomaticReturned : info %@.", info);
}


- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword target:(id)target action:(SEL)action automatic:(BOOL)automatic
{
    _target = target;
    _action = action;

    if (!automatic)
        [self associateClean];

    self.associatingYasound = YES;
    
    // tell the server
    [[YasoundDataProvider main] associateAccountYasound:email password:pword target:self action:@selector(associateYasoundRequestDidReturn:)];

}





- (void)associateAccountFacebook:(id)target action:(SEL)selector automatic:(BOOL)automatic
{
    _target = target;
    _action = selector;
    
    if (!automatic)
        [self associateClean];
    
    self.associatingFacebook = YES;
    self.associatingAutomatic = automatic;

    // launch login dialog to get user info
    [[FacebookSessionManager facebook] setTarget:self];
    [[FacebookSessionManager facebook] login];    
}


- (void)associateAccountTwitter:(id)target action:(SEL)selector automatic:(BOOL)automatic
{
    _target = target;
    _action = selector;
    
    if (!automatic)
        [self associateClean];

    self.associatingTwitter = YES;
    self.associatingAutomatic = automatic;

    // launch login dialog to get user info
    [[TwitterSessionManager twitter] setTarget:self];
    [[TwitterSessionManager twitter] login];
}



- (void)dissociateAccount:(NSString*)accountTypeIdentifier  target:(id)target action:(SEL)selector
{
    _target = target;
    _action = selector;
    
    [self associateClean];

    if ([accountTypeIdentifier isEqualToString:LOGIN_TYPE_FACEBOOK])
        self.associatingFacebook = YES;
    else if ([accountTypeIdentifier isEqualToString:LOGIN_TYPE_TWITTER])
        self.associatingTwitter = YES;
    else if ([accountTypeIdentifier isEqualToString:LOGIN_TYPE_YASOUND])
        self.associatingYasound = YES;
    
    [[YasoundDataProvider main] dissociateAccount:accountTypeIdentifier  target:self action:@selector(dissociateRequestDidReturn:)];
}






#pragma mark - YasoundDataProvider actions


- (void)dissociateRequestDidReturn:(NSDictionary*)info
{
    NSLog(@"dissociateRequestDidReturn :%@", info);
    
    
    if (self.associatingFacebook)
    {
        [[FacebookSessionManager facebook] invalidConnexion];
    }
    else if (self.associatingTwitter)
    {
        [[TwitterSessionManager twitter] invalidConnexion];
    }
    else if (self.associatingYasound)
    {
    }
    
    
    // callback
    [_target performSelector:_action withObject:info];    
}






- (void) associateYasoundRequestDidReturn:(NSDictionary*)info
{
    NSLog(@"associateYasoundRequestDidReturnd :%@", info);
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    

    // callback
    [_target performSelector:_action withObject:info];    
}







#pragma mark - YasoundDataProvider actions

- (void) associatingSocialValidated:(NSDictionary*)info
{
    NSLog(@"associatingSocialValidated returned : %@", info);
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    
    
    if (self.associatingFacebook)
    {
        if (!succeeded)
            [[FacebookSessionManager facebook] invalidConnexion];
    }
    else if (self.associatingTwitter)
    {
        if (!succeeded)
            [[TwitterSessionManager twitter] invalidConnexion];
    }
    
    [self associateClean];

    // callback
    [_target performSelector:_action withObject:info];
}


         
 - (void) dissociatingSocialValidated:(NSDictionary*)info
{
    NSLog(@"dissociatingSocialValidated returned : %@", info);
    
    [self associateClean];
    
         
     // callback
     [_target performSelector:_action withObject:info];
 }
        
                 



#pragma mark - Account Manager routines


- (NSInteger)numberOfAssociatedAccounts
{
    User* user = [YasoundDataProvider main].user;
    
    NSInteger count = 0;
    if (user.facebook_uid != nil) count++;
    if (user.twitter_uid != nil) count++;
    if (user.yasound_email != nil) count++;
    
    return count;
}

- (BOOL)isAccountAssociated:(NSString*)accountIdentifier
{
    User* user = [YasoundDataProvider main].user;

    if ([accountIdentifier isEqualToString:LOGIN_TYPE_FACEBOOK])
        return (user.facebook_uid != nil);
    if ([accountIdentifier isEqualToString:LOGIN_TYPE_TWITTER])
        return (user.twitter_uid != nil);
    if ([accountIdentifier isEqualToString:LOGIN_TYPE_YASOUND])
        return (user.yasound_email != nil);
    
    return NO;
}



- (FacebookSessionManager*) getFacebookManager
{
  if ([self isAccountAssociated: LOGIN_TYPE_FACEBOOK])
    return [FacebookSessionManager facebook];
  return nil;
}

- (TwitterSessionManager*) getTwitterManager
{
  if ([self isAccountAssociated: LOGIN_TYPE_TWITTER])
    return [TwitterSessionManager twitter];
  return nil;
}



@end
