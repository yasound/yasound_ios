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
#import "ActivityAlertView.h"

@implementation YasoundSessionManager

@synthesize registered;

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
    
    NSString* email = [_dico objectForKey:@"email"];
    NSString* pword = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:@"YasoundSessionManager" error:nil];

    // login request to server
    [[YasoundDataProvider main] login:email password:pword target:self action:@selector(loginForYasoundRequestDidReturn:info:)];
}

- (BOOL)loginForFacebookWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    
    self.loginType = LOGIN_TYPE_FACEBOOK;

    [[FacebookSessionManager facebook] setTarget:self];
    [[FacebookSessionManager facebook] login];    
}



- (BOOL)loginForTwitterWithTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    
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
    NSLog(@"loginSocialValidated returned : %@ %@", user, info);
    
    if (user == nil)
    {
        [self loginError];
        // callback
        assert(_target);
        [_target performSelector:_action withObject:nil];        
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

//    // call root to launch the Radio
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIF_PushRadio" object:nil];
}







#pragma mark - UIAlertViewDelegate

- (void)loginError
{
    [ActivityAlertView close];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:NSLocalizedString(@"YasoundSessionManager_login_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // refers to (user == nil) in loginRequestDidReturn
    
    // callback
    assert(_target);
    [_target performSelector:_action withObject:nil];
}







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

    [self save];
}


- (void)registerForFacebook
{
    self.loginType = LOGIN_TYPE_FACEBOOK;
    self.registered = YES;
    
    //LBDEBUG
    NSLog(@"dico %@", _dico);
    
    NSLog(@"registerForFacebook self.loginType %@", self.loginType);
    
    [self save];

}

- (void)registerForTwitter
{
    self.loginType = LOGIN_TYPE_TWITTER;
    self.registered = YES;
    [self save];

}




#pragma mark - post Messages


- (BOOL)postMessageForFacebook:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl target:(id)target action:(SEL)action
{
    _postTarget = target;
    _postAction = action;
    [[FacebookSessionManager facebook] requestPostMessage:message title:title picture:pictureUrl];
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
    NSLog(@"self.loginType %@", self.loginType);
    
    if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUser];
    }
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUser];
    }
}


- (void)requestDidFailed:(SessionRequestType)requestType error:(NSError*)error errorMessage:(NSString*)errorMessage
{
    if (requestType == SRequestInfoUser)
    {
        NSLog(@"requestDidFailed : could not get user info.");

        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@", [error description]);
        NSLog(@"%@", errorMessage);

        self.loginType = nil;
        [self loginError];
        return;
    }
    
    
    if (requestType == SRequestPostMessage)
    {
        NSLog(@"requestDidFailed : could not post message.");
        
        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@", [error description]);
        NSLog(@"%@", errorMessage);
        
        // duplicate message, let's act it's no error, just let the dialog spinner die himself
        NSRange range = [errorMessage rangeOfString:@"#506"];
        if (range.location != NSNotFound)
            return;
        
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
        self.loginType = nil;
        [self loginError];
        return;
    }
    
    NSDictionary* dico = [data objectAtIndex:0];
    
    NSString* username = [dico valueForKey:DATA_FIELD_USERNAME];
    NSString* uid = [dico valueForKey:DATA_FIELD_ID];
    NSString* token = [dico valueForKey:DATA_FIELD_TOKEN];
    NSString* email = [dico valueForKey:DATA_FIELD_EMAIL];
    
    NSLog(@"ready to request social login to the server with : ");
    NSLog(@"username '%@'", username);
    NSLog(@"uid '%@'", uid);
    NSLog(@"token '%@'", token);
    NSLog(@"email '%@'", email);
    
    // TAG ACTIVITY ALERT
    if (![ActivityAlertView isRunning])
        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    
    if ([self.loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        NSLog(@"facebook social login request");
        
        [[YasoundDataProvider main] loginFacebook:username type:@"facebook" uid:uid token:token email:email target:self action:@selector(loginSocialValidated:info:)];
    }
    else if ([self.loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        NSLog(@"twitter social login request");
        
        NSString* tokenSecret = [dico valueForKey:DATA_FIELD_TOKEN_SECRET];
        
        [[YasoundDataProvider main] loginTwitter:username type:@"twitter" uid:uid token:token tokenSecret:tokenSecret email:email target:self action:@selector(loginSocialValidated:info:)];
    }
}


- (void)requestPostMessageDidLoad:(NSArray*)data
{
    NSLog(@"the message has been post to your wall.");
    
    if ((_postTarget != nil) && (_postAction != nil))
        [_postTarget performSelector:_postAction withObject:[NSNumber numberWithBool:YES]];
}






@end
