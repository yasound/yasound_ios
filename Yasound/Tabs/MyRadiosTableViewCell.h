//
//  MyRadiosTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaRadio.h"
#import "WebImageView.h"
#import "WallEvent.h"

@protocol MyRadiosTableViewCellDelegate <NSObject>
- (void)myRadioRequestedPlay:(YaRadio*)radio;
- (void)myRadioRequestedStats:(YaRadio*)radio;
- (void)myRadioRequestedProgramming:(YaRadio*)radio;
- (void)myRadioRequestedBroadcast:(YaRadio*)radio;
- (void)myRadioRequestedSettings:(YaRadio*)radio;
@end



@interface MyRadiosTableViewCell : UITableViewCell
{
}

@property (nonatomic, retain) id<MyRadiosTableViewCellDelegate> delegate;
@property (nonatomic, retain) YaRadio* radio;

@property (nonatomic) CGFloat offset;
@property (nonatomic, retain) IBOutlet UIView* container;

@property (nonatomic, retain) IBOutlet WebImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* subscribers;
@property (nonatomic, retain) IBOutlet UILabel* listeners;
@property (nonatomic, retain) IBOutlet UILabel* metric1;
@property (nonatomic, retain) IBOutlet UILabel* metric2;
@property (nonatomic, retain) IBOutlet UILabel* metric1sub;
@property (nonatomic, retain) IBOutlet UIImageView* metric2Background;

@property (nonatomic, retain) IBOutlet UIButton* buttonDelete;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)reuseIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

- (void)updateWithRadio:(YaRadio*)radio target:(id)target editing:(BOOL)editing;

- (IBAction)onRadioClicked:(id)sender;
- (IBAction)onStatsClicked:(id)sender;
- (IBAction)onSettingsClicked:(id)sender;
- (IBAction)onProgrammingClicked:(id)sender;
- (IBAction)onMessageClicked:(id)sender;
- (IBAction)onDeleteClicked:(id)sender;

@end
