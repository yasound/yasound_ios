//
//  RootViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDynamicViewController.h"
#import "TestflightViewController.h"
#import "User.h"


#define NOTIF_PUSH_RADIO @"NOTIF_PushRadio"
#define NOTIF_CANCEL_WIZARD @"NOTIF_CancelWizard"
#define NOTIF_LOGIN_SCREEN @"NOTIF_LoginScreen"
#define NOTIF_WIZARD @"NOTIF_Wizard"
#define NOTIF_POP_TO_MENU @"NOTIF_PopToMenu"
#define NOTIF_PUSH_MENU @"NOTIF_PushMenu"
#define NOTIF_ERROR_COMMUNICATION_SERVER @"NOTIF_ErrorCommunicationServer"

#define NOTIF_PROGAMMING_SONG_ADDED @"NOTIF_SongAdded"

#define NOTIF_GOTO_MYRADIO @"NOTIF_goto_myRadio"
#define NOTIF_GOTO_CREATE_MYRADIO @"NOTIF_GOTO_CREATE_MYRADIO"


@interface RootViewController : TestflightViewController
{
    BOOL _firstTime;
    
    MenuDynamicViewController* _menuView;
    UIAlertView* _alertWifiInterrupted;
}

@property (nonatomic, retain) User* user;


@end


//LBDEBUG
//@interface NSDictionary (NSDictionaryDebug)
//- (BOOL)isEqualToString:(NSString*)str;
//@end
//
//@interface NSString (NSStringDebug)
//- (NSString*) absoluteString;
//@end

