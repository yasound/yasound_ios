//
//  RootViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOTIF_PUSH_RADIO @"NOTIF_PushRadio"
#define NOTIF_PUSH_RADIO_SELECTION @"NOTIF_PushRadioSelection"
#define NOTIF_LOGIN_SCREEN @"NOTIF_LoginScreen"
#define NOTIF_WIZARD @"NOTIF_Wizard"

@interface RootViewController : UIViewController
{
    BOOL _firstTime;
}

@end
