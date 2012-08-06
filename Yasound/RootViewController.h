//
//  RootViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "TestflightViewController.h"
#import "User.h"


#define NOTIF_PUSH_RADIO @"NOTIF_PushRadio"

#define NOTIF_POP_AND_GOTO_UPLOADS @"NOTIF_POP_AND_GOTO_UPLOADS"

#define NOTIF_CANCEL_WIZARD @"NOTIF_CancelWizard"
#define NOTIF_WIZARD @"NOTIF_Wizard"
#define NOTIF_POP_TO_MENU @"NOTIF_PopToMenu"
#define NOTIF_PUSH_MENU @"NOTIF_PushMenu"
#define NOTIF_ERROR_COMMUNICATION_SERVER @"NOTIF_ErrorCommunicationServer"

#define NOTIF_PROGAMMING_SONG_ADDED @"NOTIF_SongAdded"
#define NOTIF_PROGAMMING_SONG_REMOVED @"NOTIF_SongRemoved"

#define NOTIF_PUSH_LOGIN @"NOTIF_PUSH_LOGIN"
#define NOTIF_GOTO_LOGIN @"NOTIF_GOTO_LOGIN"


#define NOTIF_GOTO_MENU @"NOTIF_GOTO_MENU"
#define NOTIF_GOTO_SELECTION @"NOTIF_GOTO_SELECTION"
#define NOTIF_GOTO_FAVORITES @"NOTIF_GOTO_FAVORITES"
#define NOTIF_GOTO_MYRADIOS @"NOTIF_GOTO_MYRADIOS"
#define NOTIF_GOTO_GIFTS @"NOTIF_GOTO_GIFTS"
#define NOTIF_GOTO_PROFIL @"NOTIF_GOTO_PROFIL"
#define NOTIF_GOTO_RADIO @"NOTIF_GOTO_RADIO"
#define NOTIF_GOTO_MYRADIO @"NOTIF_goto_myRadio"
#define NOTIF_GOTO_CREATE_MYRADIO @"NOTIF_GOTO_CREATE_MYRADIO"

#define NOTIF_HANDLE_IOS_NOTIFICATION @"NOTIF_HANDLE_IOS_NOTIFICATION"


@interface RootViewController : TestflightViewController
{
    BOOL _firstTime;
    
    UIAlertView* _alertWifiInterrupted;
}

@property (nonatomic, retain) User* user;
@property (nonatomic, retain) MenuViewController* menuView;



@end


//LBDEBUG
//@interface NSArray (NSArrayDebug)
//- (id)objectForKey:(NSString*)key;
//@end
//
//@interface NSDictionary (NSDictionaryDebug)
//- (BOOL)isEqualToString:(NSString*)str;
//@end
//
//@interface NSString (NSStringDebug)
//- (NSString*) absoluteString;
//@end

