//
//  ProfilTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"


@interface ProfilTableViewCell : UITableViewCell
{
    NSInteger _selectedIndex;
    
    CGFloat _containerPosXMin;
    CGFloat _containerPosXMax;
    CGFloat _containerStartPosX;
    CGFloat _containerLastTranslation;
    CGFloat _containerDeltaTranslation;
    
    UIPanGestureRecognizer* _pgr;
}


@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) NSMutableArray* userObjects;

@property (nonatomic, retain) UIView* container;
@property (nonatomic) CGFloat translationX;
@property (nonatomic) CGFloat containerPosX;


@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

@property (nonatomic) BOOL displayRadios;
@property (nonatomic) BOOL displayUsers;

@property (nonatomic, retain) NSTimer* timer;



- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier items:(NSArray*)items target:(id)target action:(SEL)action;
- (void)updateWithItems:(NSArray*)items;

@end
