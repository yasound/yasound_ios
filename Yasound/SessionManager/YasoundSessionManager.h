//
//  YasoundSessionManager.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundDataProvider.h"


#define LOGIN_TYPE_YASOUND @"yasound"
#define LOGIN_TYPE_FACEBOOK @"facebook"
#define LOGIN_TYPE_TWITTER @"twitter"


@interface YasoundSessionManager : NSObject
{
    NSMutableDictionary* _dico;
    id _target;
    SEL _action;

    id _postTarget;
    SEL _postAction;
    
    BOOL _associatingFacebook;
    BOOL _associatingTwitter;
    BOOL _associatingYasound;
}

@property (nonatomic) BOOL registered;
@property (nonatomic, retain) NSString* loginType;

+ (YasoundSessionManager*)main;

- (void)save;

// return YES if an account has already been created.
// ! LOCAL TEST ON THE DEVICE, NOT ON THE SERVER
- (BOOL)getAccount:(User*)user;

// register the user account LOCALLY, ON THE DEVICE
- (void)addAccount:(User*)user;


// return NO if no login information have been regitered yes => launch login dialog in this case
// return YES if login information have been registered => use them to log in automatically, and callback the given action when login process ends.
- (BOOL)loginForYasoundWithTarget:(id)target action:(SEL)action;
- (BOOL)loginForFacebookWithTarget:(id)target action:(SEL)action;
- (BOOL)loginForTwitterWithTarget:(id)target action:(SEL)action;
- (void)logoutWithTarget:(id)target action:(SEL)action;

// register login information
- (void)registerForYasound:(NSString*)email withPword:(NSString*)pword;
- (void)registerForFacebook; // login info are handle by SocialSessionManager
- (void)registerForTwitter; // login info are handle by SocialSessionManager


- (void)associateAccount:(NSString*)accountIdentifier withTarget:(id)target action:(SEL)action  associate:(BOOL)associate;
- (BOOL)isAccountAssociated:(NSString*)accountIdentifier;


- (BOOL)postMessageForFacebook:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl  link:(NSURL*)link target:(id)target action:(SEL)action;
- (BOOL)postMessageForTwitter:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl target:(id)target action:(SEL)action;

@end
