//
//  RootViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MenuViewController.h"
#import "YaViewController.h"
#import "User.h"
#import "RadioSelectionViewController.h"

#define NOTIF_LAUNCH_RADIO @"NOTIF_LAUNCH_RADIO"
#define NOTIF_NEXTPAGE_CANCEL @"NOTIF_NEXTPAGE_CANCEL"

#define NOTIF_HD_CHANGED @"NOTIF_HD_CHANGED"

#define NOTIF_REFRESH_GUI @"NOTIF_REFRESH_GUI"

#define NOTIF_POP_AND_GOTO_UPLOADS @"NOTIF_POP_AND_GOTO_UPLOADS"

#define NOTIF_SEARCH_RADIO_SELECTED @"NOTIF_SEARCH_RADIO_SELECTED"
#define NOTIF_GENRE_SELECTED @"NOTIF_GENRE_SELECTED"

#define NOTIF_CONNECTION_TIMEOUT @"NOTIF_CONNECTION_TIMEOUT"

//#define NOTIF_CANCEL_WIZARD @"NOTIF_CancelWizard"
//#define NOTIF_WIZARD @"NOTIF_Wizard"
//#define NOTIF_POP_TO_MENU @"NOTIF_PopToMenu"
//#define NOTIF_PUSH_MENU @"NOTIF_PushMenu"
#define NOTIF_ERROR_COMMUNICATION_SERVER @"NOTIF_ErrorCommunicationServer"

#define NOTIF_DISMISS_MODAL @"NOTIF_DISMISS_MODAL"

#define NOTIF_PROGAMMING_SONG_ADDED @"NOTIF_SongAdded"
#define NOTIF_PROGAMMING_SONG_REMOVED @"NOTIF_SongRemoved"
#define NOTIF_PROGAMMING_SONG_UPDATED @"NOTIF_PROGAMMING_SONG_UPDATED"

#define NOTIF_PUSH_LOGIN @"NOTIF_PUSH_LOGIN"
#define NOTIF_GOTO_LOGIN @"NOTIF_GOTO_LOGIN"
#define NOTIF_DID_LOGIN @"NOTIF_DID_LOGIN"
#define NOTIF_DID_LOGOUT @"NOTIF_DID_LOGOUT"

#define NOTIF_GOTO_TWITTER_ASSOCIATION @"NOTIF_GOTO_TWITTER_ASSOCIATION"
#define NOTIF_GOTO_FACEBOOK_ASSOCIATION @"NOTIF_GOTO_FACEBOOK_ASSOCIATION"

#define NOTIF_GOTO_WEB_PAGE_VIEW @"NOTIF_GOTO_WEB_PAGE_VIEW"

#define NOTIF_GOTO_RADIO_PROGRAMMING @"NOTIF_GOTO_RADIO_PROGRAMMING"
#define NOTIF_GOTO_RADIO_STATS @"NOTIF_GOTO_RADIO_STATS"
#define NOTIF_GOTO_CREATE_RADIO @"NOTIF_GOTO_CREATE_RADIO"


//#define NOTIF_GOTO_MENU @"NOTIF_GOTO_MENU"
#define NOTIF_GOTO_SELECTION @"NOTIF_GOTO_SELECTION"
#define NOTIF_GOTO_FAVORITES @"NOTIF_GOTO_FAVORITES"
#define NOTIF_GOTO_MYRADIOS @"NOTIF_GOTO_MYRADIOS"
#define NOTIF_MYRADIO_DELETED @"NOTIF_MYRADIOS_DELETED"
#define NOTIF_MYRADIO_EDIT @"NOTIF_MYRADIO_EDIT"
#define NOTIF_MYRADIO_UNEDIT @"NOTIF_MYRADIO_UNEDIT"


#define NOTIF_GOTO_GIFTS @"NOTIF_GOTO_GIFTS"
#define NOTIF_GOTO_PROFIL @"NOTIF_GOTO_PROFIL"
#define NOTIF_GOTO_EDIT_PROFIL @"NOTIF_GOTO_EDIT_PROFIL"

#define NOTIF_PUSH_RADIO @"NOTIF_PUSH_RADIO"
#define NOTIF_GOTO_RADIO @"NOTIF_GOTO_RADIO"

#define NOTIF_INVITE_CONTACTS @"NOTIF_INVITE_CONTACTS"
#define NOTIF_INVITE_FACEBOOK @"NOTIF_INVITE_FACEBOOK"
#define NOTIF_INVITE_TWITTER @"NOTIF_INVITE_TWITTER"

#define NOTIF_HANDLE_IOS_NOTIFICATION @"NOTIF_HANDLE_IOS_NOTIFICATION"


@interface RootViewController : YaViewController
{
    BOOL _firstTime;
    
    UIAlertView* _alertWifiInterrupted;
}

@property (nonatomic, retain) User* user;
@property (nonatomic, assign) IBOutlet UIImageView* imageBackground;

//@property (nonatomic, retain) MenuViewController* menuView;
@property (nonatomic, retain) RadioSelectionViewController* radioSelectionViewController;

//+ (BOOL)menuIsCurrentScreen;

- (void)start;

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

