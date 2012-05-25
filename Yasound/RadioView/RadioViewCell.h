//
//  RadioViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "InteractiveView.h"

@class WallEvent;

#define THE_REST_OF_THE_CELL_HEIGHT 50

@interface RadioViewCell : UITableViewCell
{
    id _myTarget;
    SEL _myAction;
    
    BOOL _ownRadio;
    
    CGFloat _interactiveZoneSize;
}


@property (nonatomic, retain) WallEvent* wallEvent;


@property (nonatomic, retain) UIView* cellView;
@property (nonatomic) CGFloat cellViewX;

@property (nonatomic, retain) WebImageView* avatar;
@property (nonatomic, retain) InteractiveView* avatarMask;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UIView* messageBackground;
@property (nonatomic, retain) UILabel* message;
@property (nonatomic, retain) UIImageView* separator;

@property (nonatomic, retain) UIView* cellEditView;



- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath target:(id)target action:(SEL)action;

- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

@end
