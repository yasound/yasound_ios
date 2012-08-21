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
#import "RootViewController.h"

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
        NSDictionary* dico = [[UserSettings main] objectForKey:USKEYuserSessionDictionary];
        if (dico != nil)
            _dico = [[NSMutableDictionary alloc] initWithDictionary:dico];
        else
            _dico = [[NSMutableDictionary alloc] init];
        
        DLog(@"import dico %@", _dico);
        
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
     
    NSArray* array = [[UserSettings main] objectForKey:USKEYuserSessionAccounts];
                      
    for (int i = 0; i < array.count; i++)
    {
        NSNumber* userID = [array objectAtIndex:i];
        if ([userID isEqualToNumber:user_id])
            return YES;
    }
    
    return NO;
}


// register the user account LOCALLY, ON THE DEVICE
- (void)addAccount:(User*)user
{
    NSMutableArray* newArray = [[UserSettings main] mutableArrayForKey:USKEYuserSessionAccounts];
    
    int userID = [user.id intValue];
    [newArray addObject:[NSNumber numberWithInt:userID]];
    [[UserSettings main] setObject:newArray forKey:USKEYuserSessionAccounts];
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
    DLog(@"save : %@", _dico);
    
    [[UserSettings main] setObject:_dico forKey:USKEYuserSessionDictionary];
}






- (BOOL)loginForYasoundWithTarget:(id)target action:(SEL)action
{
//    if (!self.registered)
//        return NO;
//    if (![self.loginType isEqualToString:LOGIN_TYPE_YASOUND])
//        return NO;
    
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
    DLog(@"YasoundSessionManager login returned : %@ %@", user, info);
    
    if (user == nil)
    {
        [self loginError];
        return;
    }
    
    DLog(@"YasoundSessionManager yasound login successful!");
    
    // callback
    assert(_target);
    [_target performSelector:_action withObject:user withObject:info];
    
}














#pragma mark - YasoundDataProvider actions

- (void) loginSocialValidated:(User*)user info:(NSDictionary*)info
{
    if (_error)
    {
        DLog(@"loginSocialValidated returned but canceled because error");
        return;
    }

    DLog(@"loginSocialValidated returned : %@ %@", user, info);
    
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
    
    [[UserSettings main] clearSession];
    [[YasoundDataProvider main] resetUser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DID_LOGOUT object:nil];

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
    
    [self save];

    // warn the object that may need to know you are now login (topbar for instance)
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DID_LOGIN object:nil];
}


- (void)registerForFacebook
{
    self.loginType = LOGIN_TYPE_FACEBOOK;
    self.registered = YES;
    
    // local account manager is handle in the SocialSessionManager delegate
    
    DLog(@"registerForFacebook self.loginType %@", self.loginType);
    
    [self save];

    // warn the object that may need to know you are now login (topbar for instance)
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DID_LOGIN object:nil];
}

- (void)registerForTwitter
{
    self.loginType = LOGIN_TYPE_TWITTER;
    self.registered = YES;
    
    DLog(@"registerForTwitter self.loginType %@", self.loginType);
    
    // local account manager is handle in the SocialSessionManager delegate

    [self save];

    // warn the object that may need to know you are now login (topbar for instance)
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DID_LOGIN object:nil];
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
    DLog(@"YasoundSessionManager::sessionDidLogin    authorized %d", authorized);
    
    if (self.associatingAutomatic)
    {
        DLog(@"associating automatic.");
        
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
        DLog(@"requestDidFailed : could not get user info.");

        DLog(@"%@", [error localizedDescription]);
        DLog(@"%@", [error description]);
        DLog(@"%@", errorMessage);

        [self userInfoError];
        
        
        
        return;
    }
    
    

    if (requestType == SRequestPostMessage)
    {
        DLog(@"requestDidFailed : could not post message.");
        
        DLog(@"%@", [error localizedDescription]);
        DLog(@"%@", [error description]);
        DLog(@"%@", errorMessage);
        
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
        DLog(@"requestDidLoad SRequestInfoUser error : no info.");
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

    DLog(@"ready to request social login to the server with : ");
    DLog(@"username '%@'", username);
    DLog(@"name '%@'", name);
    DLog(@"uid '%@'", uid);
    DLog(@"token '%@'", token);
    DLog(@"email '%@'", email);
    
//    // TAG ACTIVITY ALERT
//    if (![ActivityAlertView isRunning])
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    
    //
    // associating process
    //
    if (self.associatingFacebook)
    {
        DLog(@"facebook social associating request");
        
        NSDate* date = [[UserSettings main] objectForKey:USKEYfacebookExpirationDateKey];
        NSString* expirationDate = [YasoundSessionManager expirationDateToString:date];
        
        // request to yasound server
        [[YasoundDataProvider main] associateAccountFacebook:username type:LOGIN_TYPE_FACEBOOK uid:uid token:token expirationDate:expirationDate email:email target:self action:@selector(associatingSocialValidated:)];
    }
    
    
    else if (self.associatingTwitter)
    {
        DLog(@"twitter social associating request");


        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        // request to yasound server
        [[YasoundDataProvider main] associateAccountTwitter:username  type:LOGIN_TYPE_TWITTER uid:uid token:token tokenSecret:tokenSecret email:email target:self action:@selector(associatingSocialValidated:)];
    }
    
    //
    // login process
    //
    else if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        DLog(@"facebook social login request");
//      NSString* n = username;
//      if (!n)
//        n = name;
        
        NSDate* date = [[UserSettings main] objectForKey:USKEYfacebookExpirationDateKey];
        NSString* expirationDate = [YasoundSessionManager expirationDateToString:date];
        
        [[YasoundDataProvider main] loginFacebook:username type:@"facebook" uid:uid token:token expirationDate:expirationDate email:email target:self action:@selector(loginSocialValidated:info:)];
    }
    
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        DLog(@"twitter social login request");
        
        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        if (token == nil)
            DLog(@"error Twitter token is nil!");
        if (tokenSecret == nil)
            DLog(@"error Twitter tokenSecret is nil!");
        
        assert(token != nil);
        
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
    DLog(@"the message has been post to your wall.");
    
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
        DLog(@"\n Automatic associating account Facebook.");
        [self associateAccountFacebook:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
    }

    if (![self.loginType isEqualToString:LOGIN_TYPE_TWITTER] && [self isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
        DLog(@"\n Automatic associating account Twitter.");
        [self associateAccountTwitter:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
    }
    

    // don't need to do anything for yasound
//    if (![self.loginType isEqualToString:LOGIN_TYPE_YASOUND] && [self isAccountAssociated:LOGIN_TYPE_YASOUND])
//    {
//        DLog(@"\n Automatic associating account Yasound.");
//        [self associateAccountYasound:[account objectForKey:@"email"] password:[account objectForKey:@"pword"] target:self action:@selector(associateAccountsAutomaticReturned:) automatic:YES];
//    }
    
    
}


- (void)associateAccountsAutomaticReturned:(NSDictionary*)info
{
    DLog(@"associateAccountsAutomaticReturned : info %@.", info);
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
    DLog(@"dissociateRequestDidReturn :%@", info);
    
    
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
    
    DLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];
}






- (void) associateYasoundRequestDidReturn:(NSDictionary*)info
{
    DLog(@"associateYasoundRequestDidReturnd :%@", info);
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    
    DLog(@"call reloadUserWithUserData");
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
        // secret credentials are NOT saved in the User Settings, for security reason. Prefer KeyChain.
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
    DLog(@"reloadUserData from user");
    [self importFacebookData:user.facebook_token facebook_expiration_date:user.facebook_expiration_date];
    [self importTwitterData:user.twitter_token token_secret:user.twitter_token_secret user_id:user.twitter_uid screen_name:user.twitter_username];
    [self importYasoundData:user.yasound_email];
    
    // store a local copy of the infos
    [self exportUserData:user];    
}


- (void)importFacebookData:(NSString*)facebook_token facebook_expiration_date:(NSString*)facebook_expiration_date
{
    [[UserSettings main] setObject:facebook_token forKey:USKEYfacebookAccessTokenKey];

    NSDate* date = [YasoundSessionManager stringToExpirationDate:facebook_expiration_date];
    
    [[UserSettings main] setObject:date forKey:USKEYfacebookExpirationDateKey];

    DLog(@"importFacebookData  '%@' '%@'", facebook_token, date);
}



- (void)importTwitterData:(NSString*)twitter_token token_secret:(NSString*)twitter_token_secret user_id:(NSString*)twitter_uid screen_name:(NSString*)twitter_username
{
    NSString* data = [TwitterOAuthSessionManager buildDataFromToken:twitter_token token_secret:twitter_token_secret user_id:twitter_uid screen_name:twitter_username];
    [self importTwitterData:twitter_username screen_name:twitter_username uid:twitter_uid withData:data];
}


- (void)importTwitterData:(NSString*)twitter_username screen_name:twitter_screen_name uid:(NSString*)twitter_uid withData:(NSString*)twitter_data
{
    [[UserSettings main] setObject:twitter_username forKey:USKEYtwitterOAuthUsername];
    [[UserSettings main] setObject:twitter_screen_name forKey:USKEYtwitterOAuthScreenname];
    [[UserSettings main] setObject:twitter_uid forKey:USKEYtwitterOAuthUserId];

    NSError* error;
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    // secret credentials are NOT saved in the User Settings, for security reason. Prefer KeyChain.
    [SFHFKeychainUtils storeUsername:twitter_username andPassword:twitter_data  forServiceName:BundleName updateExisting:YES error:&error];
    
    DLog(@"importTwitterData '%@'", twitter_data);
}



- (void)importYasoundData:(NSString*)yasound_email
{
    [[UserSettings main] setObject:yasound_email forKey:USKEYyasoundEmail];

    DLog(@"importYasoundData '%@'", yasound_email);
}

    


+ (NSString*)expirationDateToString:(NSDate*)date
{
    assert(date != nil);
    if (date == nil)
    {
        DLog(@"expirationDateToString : date is nil!");
        return nil;
    }
    
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
    DLog(@"associatingSocialValidated returned : %@", info);
    
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
    
    DLog(@"call reloadUserWithUserData");
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithUserData:info withTarget:self action:@selector(onUserReloaded:info:)];  
}


         
 - (void) dissociatingSocialValidated:(NSDictionary*)info
{
    DLog(@"dissociatingSocialValidated returned : %@", info);
    
    [self associateClean];
    
    DLog(@"call reloadUserWithUserData");
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
