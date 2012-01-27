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
#define NOTIF_PUSH_RADIO_SELECTION @"NOTIF_PushRadioSelection"
#define NOTIF_LOGIN_SCREEN @"NOTIF_LoginScreen"
#define NOTIF_WIZARD @"NOTIF_Wizard"
#define NOTIF_MENU @"NOTIF_Menu"
#define NOTIF_ERROR_COMMUNICATION_SERVER @"NOTIF_ErrorCommunicationServer"
#define NOTIF_ERROR_CONNECTION_LOST @"NOTIF_ErrorConnectionLost"
#define NOTIF_ERROR_CONNECTION_NO @"NOTIF_ErrorConnectionNo"



@interface RootViewController : TestflightViewController
{
    BOOL _firstTime;
    
    MenuViewController* _menuView;
}

@end
