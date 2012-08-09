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
    BOOL _ownRadio;
    
    CGFloat _interactiveZoneSize;
    
    UIAlertView* _alertTrash;
    UIAlertView* _alertSpam;
    UIAlertView* _alertKick;
}


@property (nonatomic, retain) WallEvent* wallEvent;
@property (nonatomic, retain) NSIndexPath* indexPath;

@property (nonatomic, retain) UIView* cellView;
@property (nonatomic) CGFloat cellViewX;

@property (nonatomic, retain) WebImageView* avatar;
@property (nonatomic, retain) UIImageView* avatarMask;
@property (nonatomic, retain) InteractiveView* avatarInteractiveView;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UIView* messageBackground;
@property (nonatomic, retain) UILabel* message;
//@property (nonatomic, retain) UIImageView* separator;

@property (nonatomic, retain) UIView* cellEditView;

@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL actionAvatarClick;
@property (nonatomic) SEL actionEditing;
@property (nonatomic) SEL actionDelete;




- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

- (void)deactivateEditModeAnimated:(BOOL)animated;
- (void)deactivateEditModeAnimated:(BOOL)animated silent:(BOOL)silent;


@end
