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

#define NOTIF_PUSH_RADIO @"NOTIF_PushRadio"
#define NOTIF_CANCEL_WIZARD @"NOTIF_CancelWizard"
#define NOTIF_LOGIN_SCREEN @"NOTIF_LoginScreen"
#define NOTIF_WIZARD @"NOTIF_Wizard"
#define NOTIF_POP_TO_MENU @"NOTIF_PopToMenu"
#define NOTIF_PUSH_MENU @"NOTIF_PushMenu"
#define NOTIF_ERROR_COMMUNICATION_SERVER @"NOTIF_ErrorCommunicationServer"
#define NOTIF_ERROR_CONNECTION_LOST @"NOTIF_ErrorConnectionLost"
#define NOTIF_ERROR_CONNECTION_NO @"NOTIF_ErrorConnectionNo"

#define NOTIF_PROGAMMING_SONG_ADDED @"NOTIF_SongAdded"


@interface RootViewController : TestflightViewController
{
    BOOL _firstTime;
    
    MenuViewController* _menuView;
}

@end
