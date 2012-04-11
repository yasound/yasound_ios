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
    [_target performSelector:_action withObject:user withObject:info];
    
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
    [_target performSelector:_action withObject:user withObject:info];
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
    if ([YasoundDataProvider main ].user.facebook_uid != nil)
    {
        _target = target;
        _action = action;
        [FacebookSessionManager facebook].delegate = self;
        [[FacebookSessionManager facebook] logout];
    }
    
    if ([YasoundDataProvider main ].user.twitter_uid != nil)
    {
        _target = target;
        _action = action;
        [TwitterSessionManager twitter].delegate = self;
        [[TwitterSessionManager twitter] logout];
    }
    
    if ([YasoundDataProvider main ].user.yasound_email != nil)
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


//deprecated
//
//- (void)logoutWithTarget:(id)target action:(SEL)action
//{
//    // do it for all, this way you're sure :)
//    if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
//    {
//        _target = target;
//        _action = action;
//        [FacebookSessionManager facebook].delegate = self;
//        [[FacebookSessionManager facebook] logout];
//    }
//    
//    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
//    {
//        _target = target;
//        _action = action;
//        [TwitterSessionManager twitter].delegate = self;
//        [[TwitterSessionManager twitter] logout];
//    }
//    
//    else if ([self.loginType isEqualToString:LOGIN_TYPE_YASOUND])
//    {
//        NSString* email = [_dico objectForKey:@"email"];
//        [SFHFKeychainUtils deleteItemForUsername:email andServiceName:@"YasoundSessionManager" error:nil];
//    }
//    
//
//    [_dico release];
//    _dico = nil;
//    _dico = [[NSMutableDictionary alloc] init];
//    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"YasoundSessionManager"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    // callback
//    [target performSelector:action];
//}



- (void)registerForYasound:(NSString*)email withPword:(NSString*)pword
{
    self.loginType = LOGIN_TYPE_YASOUND;
    self.registered = YES;
    
    // store email
    [_dico setObject:email forKey:@"email"];
    
    // store pword with security
    [SFHFKeychainUtils storeUsername:email andPassword:pword  forServiceName:@"YasoundSessionManager" updateExisting:YES error:nil];

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
        
        [self associateClean];

        [_target performSelector:_action withObject:nil withObject:nil];
        return;
    }
    
    
    if (self.associatingFacebook)
    {
        if (authorized)
            [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
        else
        {
            [self associateClean];
            [_target performSelector:_action withObject:nil withObject:nil];
        }
    }
    else if (self.associatingTwitter)
    {
        if (authorized)
            [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
        else
        {
            [self associateClean];
            [_target performSelector:_action withObject:nil withObject:nil];
        }
    }
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        if (authorized)
            [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil withObject:nil];
    }
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        if (authorized)
            [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
        else
            [_target performSelector:_action withObject:nil withObject:nil];
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
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];    
        NSString* expirationDate = [YasoundSessionManager expirationDateToString:[defaults objectForKey:@"FBExpirationDateKey"]];
        
        // request to yasound server
        [[YasoundDataProvider main] associateAccountFacebook:username type:LOGIN_TYPE_FACEBOOK uid:uid token:token expirationDate:expirationDate email:email target:self action:@selector(associatingSocialValidated:)];
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
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];    
        NSString* expirationDate = [YasoundSessionManager expirationDateToString:[defaults objectForKey:@"FBExpirationDateKey"]];

        
        [[YasoundDataProvider main] loginFacebook:username type:@"facebook" uid:uid token:token expirationDate:expirationDate email:email target:self action:@selector(loginSocialValidated:info:)];
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
            [_target performSelector:_action withObject:nil withObject:nil];

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
    
    NSLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];
}






- (void) associateYasoundRequestDidReturn:(NSDictionary*)info
{
    NSLog(@"associateYasoundRequestDidReturnd :%@", info);
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    
    NSLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];
}



- (void)onUserReloaded:(User*)user info:(NSDictionary*)info
{
    NSDictionary* userInfo = [info objectForKey:@"userData"];
    
    [self reloadUserData:user];
    
    // callback
    [_target performSelector:_action withObject:user withObject:info];    
}



- (void)exportUserData:(User*)user
{
    // reset
    [_dico removeObjectForKey:@"facebook"];
    [_dico removeObjectForKey:@"twitter"];
    [_dico removeObjectForKey:@"yasound"];

    
    /// export facebook
    NSMutableDictionary* facebook = [[NSMutableDictionary alloc] init];
    if (user.facebook_token)
    {
        [facebook setObject:user.facebook_token forKey:@"facebook_token"];
        if (user.facebook_expiration_date)
            [facebook setObject:user.facebook_expiration_date forKey:@"facebook_expiration_date"];
    
        [_dico setObject:facebook forKey:@"facebook"];
    }

    
    
    /// export twitter

    NSMutableDictionary* twitter = [[NSMutableDictionary alloc] init];
    if (user.twitter_username)
    {
        NSString* data = [TwitterOAuthSessionManager buildDataFromToken:user.twitter_token token_secret:user.twitter_token_secret user_id:user.twitter_uid screen_name:user.twitter_username];

        [twitter setObject:user.twitter_username forKey:@"twitter_username"];
        [twitter setObject:user.twitter_uid forKey:@"twitter_uid"];
        [twitter setObject:user.twitter_username forKey:@"twitter_screen_name"];

        NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
        // secret credentials are NOT saved in the UserDefaults, for security reason. Prefer KeyChain.
        [SFHFKeychainUtils storeUsername:user.twitter_username andPassword:data  forServiceName:BundleName updateExisting:YES error:nil];

        [_dico setObject:twitter forKey:@"twitter"];

    }
    
    
    
    /// export yasound    
    NSMutableDictionary* yasound = [[NSMutableDictionary alloc] init];
    if (user.yasound_email)
    {
        [yasound setObject:user.yasound_email forKey:@"yasound_email"];
        [_dico setObject:yasound forKey:@"yasound"];
    }
    
    
    
    [self save];
    
    [facebook release];
    [twitter release];
    [yasound release];
}


- (void)importUserData
{
    // import facebook
    NSDictionary* dico = [_dico objectForKey:@"facebook"];
    NSString* facebook_token = [dico objectForKey:@"facebook_token"];
    NSString* facebook_expiration_date = [dico objectForKey:@"facebook_expiration_date"];
    [self importFacebookData:facebook_token facebook_expiration_date:facebook_expiration_date];
    
    // import twitter
    dico = [_dico objectForKey:@"twitter"];
    
    NSString* twitter_username = [dico objectForKey:@"twitter_username"];
    NSString* twitter_screen_name = [dico objectForKey:@"twitter_screen_name"];
    NSString* twitter_uid = [dico objectForKey:@"twitter_uid"];
    
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    NSString* twitter_data = [SFHFKeychainUtils getPasswordForUsername:twitter_username andServiceName:BundleName error:nil];
    [self importTwitterData:twitter_username screen_name:twitter_screen_name uid:twitter_uid withData:twitter_data];
    
    // import yasound
    dico = [_dico objectForKey:@"yasound"];
    NSString* yasound_email = [dico objectForKey:@"yasound_email"];
    [self importYasoundData:yasound_email];
}


- (void)reloadUserData:(User*)user
{
    NSLog(@"reloadUserData from user");
    [self importFacebookData:user.facebook_token facebook_expiration_date:user.facebook_expiration_date];
    [self importTwitterData:user.twitter_token token_secret:user.twitter_token_secret user_id:user.twitter_uid screen_name:user.twitter_username];
    [self importYasoundData:user.yasound_email];
    
    // store a local copy of the infos
    [self exportUserData:user];    
}


- (void)importFacebookData:(NSString*)facebook_token facebook_expiration_date:(NSString*)facebook_expiration_date
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:facebook_token forKey:@"FBAccessTokenKey"];
    NSDate* date = [YasoundSessionManager stringToExpirationDate:facebook_expiration_date];
    
    [defaults setObject:date forKey:@"FBExpirationDateKey"];
    [defaults synchronize];  

    NSLog(@"importFacebookData  '%@' '%@'", [defaults objectForKey:@"FBAccessTokenKey"], [defaults objectForKey:@"FBExpirationDateKey"]);
}



- (void)importTwitterData:(NSString*)twitter_token token_secret:(NSString*)twitter_token_secret user_id:(NSString*)twitter_uid screen_name:(NSString*)twitter_username
{
    NSString* data = [TwitterOAuthSessionManager buildDataFromToken:twitter_token token_secret:twitter_token_secret user_id:twitter_uid screen_name:twitter_username];
    [self importTwitterData:twitter_username screen_name:twitter_username uid:twitter_uid withData:data];
}


- (void)importTwitterData:(NSString*)twitter_username screen_name:twitter_screen_name uid:(NSString*)twitter_uid withData:(NSString*)twitter_data
{
    [[NSUserDefaults standardUserDefaults] setValue:twitter_username forKey:OAUTH_USERNAME];
    [[NSUserDefaults standardUserDefaults] setValue:twitter_screen_name forKey:OAUTH_SCREENNAME];
    [[NSUserDefaults standardUserDefaults] setValue:twitter_uid forKey:OAUTH_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSError* error;
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    // secret credentials are NOT saved in the UserDefaults, for security reason. Prefer KeyChain.
    [SFHFKeychainUtils storeUsername:twitter_username andPassword:twitter_data  forServiceName:BundleName updateExisting:YES error:&error];
    
    NSLog(@"importTwitterData '%@'", twitter_data);
}



- (void)importYasoundData:(NSString*)yasound_email
{
    [[NSUserDefaults standardUserDefaults] setValue:yasound_email forKey:@"yasound_email"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSLog(@"importYasoundData '%@'", yasound_email);
}

    


+ (NSString*)expirationDateToString:(NSDate*)date
{
    NSLocale* enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* datestr = [dateFormatter stringFromDate:date];
    NSString* ts = [[NSString alloc] initWithString:datestr];

    [dateFormatter release];
    [enUSPOSIXLocale release];
    return ts;
}


+ (NSDate*)stringToExpirationDate:(NSString*)string
{
    NSLocale* enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* date = [dateFormatter dateFromString:string];
    [date retain];
    [dateFormatter release];
    [enUSPOSIXLocale release];
    return date;
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
    
    NSLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];  
}


         
 - (void) dissociatingSocialValidated:(NSDictionary*)info
{
    NSLog(@"dissociatingSocialValidated returned : %@", info);
    
    [self associateClean];
    
    NSLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];
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
    NSDictionary* dico = [_dico objectForKey:accountIdentifier];
    return (dico != nil);
}


//deprecated
//
//- (BOOL)isAccountAssociated:(NSString*)accountIdentifier
//{
//    User* user = [YasoundDataProvider main].user;
//    
//    //LBDEBUG
//    NSLog(@"/n[YasoundDataProvider main].user : ");
//    NSLog(@"facebook_username '%@'", user.facebook_username);
//    NSLog(@"facebook_uid '%@'", user.facebook_uid);
//    NSLog(@"facebook_token '%@'", user.facebook_token);
//    NSLog(@"facebook_expiration_date '%@'", user.facebook_expiration_date);
//    NSLog(@"facebook_email '%@'", user.facebook_email);
//    
//    NSLog(@"twitter_username '%@'", user.twitter_username);
//    NSLog(@"twitter_uid '%@'", user.twitter_uid);
//    NSLog(@"twitter_token '%@'", user.twitter_token);
//    NSLog(@"twitter_token_secret '%@'", user.twitter_token_secret);
//    NSLog(@"twitter_email '%@'", user.twitter_email);
//    
//    NSLog(@"yasound_email '%@'", user.yasound_email);
//
//    
//    if ([accountIdentifier isEqualToString:LOGIN_TYPE_FACEBOOK])
//        return (user.facebook_uid != nil );
//    if ([accountIdentifier isEqualToString:LOGIN_TYPE_TWITTER])
//        return (user.twitter_uid != nil);
//    if ([accountIdentifier isEqualToString:LOGIN_TYPE_YASOUND])
//        return (user.yasound_email != nil);
//    
//    return NO;
//}



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
