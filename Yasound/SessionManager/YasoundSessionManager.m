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









- (void)setRegistered:(BOOL)newRegistered
{
    [_dico setObject:[NSNumber numberWithBool:newRegistered] forKey:@"registered"];
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






- (void)loginForYasoundWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _error = NO;

    
    NSString* email = [_dico objectForKey:@"email"];
    NSString* pword = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:@"YasoundSessionManager" error:nil];

    // login request to server
    [[YasoundDataProvider main] login:email password:pword withCompletionBlock:^(User* u, NSError* error){
        DLog(@"YasoundSessionManager login returned : %@ %@", u, error);
        if (u == nil)
        {
            [self loginError];
            return;
        }
        
        DLog(@"YasoundSessionManager yasound login successful!");
        
        // callback
        assert(_target);
        [_target performSelector:_action withObject:u withObject:nil];
    }];
    
}

- (void)loginForFacebookWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _error = NO;
    
    self.loginType = LOGIN_TYPE_FACEBOOK;

    [[FacebookSessionManager facebook] setTarget:self];
    [[FacebookSessionManager facebook] login];    
}



- (void)loginForTwitterWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _error = NO;
    
    self.loginType = LOGIN_TYPE_TWITTER;

    [[TwitterSessionManager twitter] setTarget:self];
    [[TwitterSessionManager twitter] login];
}





//- (void) loginForYasoundRequestDidReturn:(User*)user info:(NSDictionary*)info
//{
//    DLog(@"YasoundSessionManager login returned : %@ %@", user, info);
//    
//    if (user == nil)
//    {
//        [self loginError];
//        return;
//    }
//    
//    DLog(@"YasoundSessionManager yasound login successful!");
//    
//    // callback
//    assert(_target);
//    [_target performSelector:_action withObject:user withObject:info];
//    
//}














#pragma mark - YasoundDataProvider actions

- (void)loginSocialValidated:(User*)user error:(NSError*)error
{
    if (error)
    {
        DLog(@"loginSocialValidated error: %d - %@", error.code, error.domain);
        [self loginError];
        return;
    }
    if (user == nil)
    {
        DLog(@"loginSocialValidated failed: user nil");
        [self loginError];
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
    [_target performSelector:_action withObject:user withObject:nil];
    _target = nil;
}







#pragma mark - UIAlertViewDelegate

- (void)loginError
{
    User* nilUser = nil;
    _error = YES;
    [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"Login" forKey:@"error"]];
    _target = nil;

}

- (void)loginCanceled
{
  User* nilUser = nil;
  _error = NO;
  [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"Cancel" forKey:@"error"]];
    _target = nil;

}

- (void)userInfoError
{
    User* nilUser = nil;
    _error = YES;
    [_target performSelector:_action withObject:nilUser withObject:[NSDictionary dictionaryWithObject:@"UserInfo" forKey:@"error"]];
}





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


- (void)postMessageForFacebook:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl link:(NSURL*)link target:(id)target action:(SEL)action
{
    _postTarget = target;
    _postAction = action;
    [[FacebookSessionManager facebook] requestPostMessage:message title:title picture:pictureUrl link:link];
}



- (void)postMessageForTwitter:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl target:(id)target action:(SEL)action
{
    _postTarget = target;
    _postAction = action;
    [[TwitterSessionManager twitter] requestPostMessage:message title:title picture:pictureUrl];
}


- (void)followTwitterUser:(NSString*)username
{
  [[TwitterSessionManager twitter] enableUpdatesFor:username];
}









#pragma mark - SessionDelegate

- (void)sessionDidLogin:(BOOL)authorized
{
    DLog(@"YasoundSessionManager::sessionDidLogin    authorized %d", authorized);
    
    if (self.associatingAutomatic)
    {
        DLog(@"associating automatic.");
        
        [self associateClean];

        [_target performSelector:_action withObject:nil];
        return;
    }
    
    
    if (self.associatingFacebook)
    {
        if (authorized)
            [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
        else
        {
            [self associateClean];
            [_target performSelector:_action withObject:nil];
        }
    }
    else if (self.associatingTwitter)
    {
        if (authorized)
            [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
        else
        {
            [self associateClean];
            [_target performSelector:_action withObject:nil];
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

    if (requestType == SRequestInfoUser)
    {
        DLog(@"requestDidFailed : could not get user info.");

        DLog(@"YasoundSessionManager requestDidFailed %@", [error localizedDescription]);
        DLog(@"YasoundSessionManager requestDidFailed %@", [error description]);
        DLog(@"YasoundSessionManager requestDidFailed %@", errorMessage);

        [self userInfoError];
        
        
        
        return;
    }
    
    

    if (requestType == SRequestPostMessage)
    {
        DLog(@"requestDidFailed : could not post message.");
        
        DLog(@"YasoundSessionManager requestDidFailed %@", [error localizedDescription]);
        DLog(@"YasoundSessionManager requestDidFailed %@", [error description]);
        DLog(@"YasoundSessionManager requestDidFailed %@", errorMessage);
        
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
    

    //
    // associating process
    //
    if (self.associatingFacebook)
    {
        DLog(@"facebook social associating request");
        
        NSString* expirationDate = [[UserSettings main] objectForKey:USKEYfacebookExpirationDateKey];
        
        // request to yasound server
        [[YasoundDataProvider main] associateAccountFacebook:username type:LOGIN_TYPE_FACEBOOK uid:uid token:token expirationDate:expirationDate email:email withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self socialAssociationReturnedWithStatus:status response:response error:error];
        }];
        
    }
    
    
    else if (self.associatingTwitter)
    {
        DLog(@"twitter social associating request");


        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        // request to yasound server        
        [[YasoundDataProvider main] associateAccountTwitter:username type:LOGIN_TYPE_TWITTER uid:uid token:token tokenSecret:tokenSecret email:email withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self socialAssociationReturnedWithStatus:status response:response error:error];
        }];
        
    }
    
    //
    // login process
    //
    else if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        DLog(@"facebook social login request");
        
        NSString* expirationDate = [[UserSettings main] objectForKey:USKEYfacebookExpirationDateKey];
        
        [[YasoundDataProvider main] loginFacebook:username type:@"facebook" uid:uid token:token expirationDate:expirationDate email:email withCompletionBlock:^(User* u, NSError* error){
            [self loginSocialValidated:u error:error];
        }];
        
    }
    
    
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        DLog(@"twitter social login request");
        
        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];

        if (token == nil)
            DLog(@"error Twitter token is nil!");
        if (tokenSecret == nil)
            DLog(@"error Twitter tokenSecret is nil!");
        
        // don't bother asking the server if you don't the requested info at this point
        if ((token == nil) || (tokenSecret == nil))
        {
            // callback
            assert(_target);
            [_target performSelector:_action withObject:nil withObject:nil];

            return;
        }
        
        // ok, request login to server
        [[YasoundDataProvider main] loginTwitter:username type:@"twitter" uid:uid token:token tokenSecret:tokenSecret email:email withCompletionBlock:^(User* u, NSError* error){
            [self loginSocialValidated:u error:error];
        }];
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
    [[YasoundDataProvider main] associateAccountYasound:email password:pword withCompletionBlock:^(int status, NSString* response, NSError* error){
        BOOL success = (error != nil) && (status == 20);
        if (!success)
            DLog(@"yasound association failed");
        
        [[YasoundDataProvider main] reloadUserWithCompletionBlock:^(User* u){
            [self userReloaded:u];
        }];
    }];

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
    
    [[YasoundDataProvider main] dissociateAccount:accountTypeIdentifier withCompletionBlock:^(int status, NSString* response, NSError* error){
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
        
        // reload the current user to update the associated accounts info
        [[YasoundDataProvider main] reloadUserWithCompletionBlock:^(User* u){
            [self userReloaded:u];
        }];
        
    }];
}






#pragma mark - YasoundDataProvider actions

- (void)userReloaded:(User*)u
{
    [self writeUserIdentity:u];
    // callback
    [_target performSelector:_action withObject:u];
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
    if (facebook_token != nil)
        [self importFacebookData:facebook_token facebook_expiration_date:facebook_expiration_date];
    
    // import twitter
    dico = [_dico objectForKey:@"twitter"];
    
    NSString* twitter_username = [dico objectForKey:@"twitter_username"];
    NSString* twitter_screen_name = [dico objectForKey:@"twitter_screen_name"];
    NSString* twitter_uid = [dico objectForKey:@"twitter_uid"];
    
    if ((twitter_username != nil) && (twitter_screen_name != nil) && (twitter_uid != nil)) {
        NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
        NSString* twitter_data = [SFHFKeychainUtils getPasswordForUsername:twitter_username andServiceName:BundleName error:nil];
        [self importTwitterData:twitter_username screen_name:twitter_screen_name uid:twitter_uid withData:twitter_data];
    }
    
    // import yasound
    dico = [_dico objectForKey:@"yasound"];
    NSString* yasound_email = [dico objectForKey:@"yasound_email"];
    if (yasound_email != nil)
        [self importYasoundData:yasound_email];
}


- (void)writeUserIdentity:(User*)user
{
    DLog(@"writeUserIdentity from user");
    if (user.facebook_token)
        [self importFacebookData:user.facebook_token facebook_expiration_date:user.facebook_expiration_date];
    if ((user.twitter_token != nil) && (user.twitter_token_secret != nil) && (user.twitter_uid != nil) && (user.twitter_username != nil)) {
        [self importTwitterData:user.twitter_token token_secret:user.twitter_token_secret user_id:user.twitter_uid screen_name:user.twitter_username];
    }
    if (user.yasound_email)
        [self importYasoundData:user.yasound_email];
    
    // store a local copy of the infos
    [self exportUserData:user];    
}


- (void)importFacebookData:(NSString*)facebook_token facebook_expiration_date:(NSString*)facebook_expiration_date
{
    [[UserSettings main] setObject:facebook_token forKey:USKEYfacebookAccessTokenKey];

    [[UserSettings main] setObject:facebook_expiration_date forKey:USKEYfacebookExpirationDateKey];

    DLog(@"importFacebookData  '%@' '%@'", facebook_token, facebook_expiration_date);
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
    
    NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* datestr = [dateFormatter stringFromDate:date];
    NSString* ts = [[NSString alloc] initWithString:datestr];

    return ts;
}


+ (NSDate*)stringToExpirationDate:(NSString*)string
{
    NSLog(@"%@", [string class]);
    
    NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* date = [dateFormatter dateFromString:string];
    
    //LBDEBUG anti-bug iOS 6
    NSString* verif = [dateFormatter stringFromDate:date];
    if ([verif isEqualToString:@"2001-01-01 01:00:00"]) {

        DLog(@"iOS6 NSDateFormatter antibug.");

        NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
        [comps setSecond:0];
        [comps setMinute:0];
        [comps setHour:1];
        [comps setDay:1];
        [comps setMonth:1];
        [comps setYear:4001];
        date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    }

    ////////////////////////
    
    
    [date retain];
    return date;
}






#pragma mark - YasoundDataProvider actions

- (void)socialAssociationReturnedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    BOOL succeeded = (error == nil) && (status == 200);
    
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
    
    // reload the current user to update the associated accounts info
    [[YasoundDataProvider main] reloadUserWithCompletionBlock:^(User* u){
        [self userReloaded:u];
    }];
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
