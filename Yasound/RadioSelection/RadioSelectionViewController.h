//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
#import "YaViewController.h"
#import "WheelSelectorRadios.h"
#import "WheelRadiosSelector.h"
#import "RadioListTableViewController.h"
#import "TopBar.h"
#import "MenuViewController.h"
#import "RadioSearchViewController.h"
#import "WaitingView.h"
#import "YasoundDataProvider.h"

@interface RadioSelectionViewController : YaViewController<TopBarDelegate, RadioListDelegate> {
    
    NSInteger _wheelIndex;
    WaitingView* _waitingView;
    
}

@property (nonatomic, retain) NSString* nextPageUrl;
@property (nonatomic, retain) NSTimer* nextPageTimer;

@property (nonatomic) BOOL locked;

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) IBOutlet TopBar* topbar;

//@property (nonatomic) NSInteger nbFriends;
//@property (nonatomic, retain) NSMutableArray* friendsRadios;
@property (nonatomic, retain) NSArray* friends;

@property (nonatomic, retain) IBOutlet WheelSelectorRadios* wheelSelector;
@property (nonatomic, retain) IBOutlet UIView* listContainer;
@property (nonatomic, retain) UIViewController* contentsController;
@property (nonatomic, retain) UIView* contentsView;
@property (nonatomic, retain) RadioSearchViewController* searchview;

@property (nonatomic, retain) MenuViewController* menu;

@property (nonatomic, retain) NSString* currentGenre;

//@property (nonatomic, retain) ASIHTTPRequest* currentRequest;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withWheelIndex:(NSInteger)wheelIndex;


@end
