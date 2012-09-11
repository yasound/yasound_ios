//
//  ActionAddSongCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongLocal.h"
#import "Radio.h"

@interface ActionAddSongCell : UITableViewCell
{
    UIAlertView* _wifiWarning;
    UIAlertView* _legalUploadWarning;
    UIAlertView* _addedUploadWarning;
    
}

@property (nonatomic, assign) SongLocal* song;
@property (nonatomic, assign) Radio* radio;

@property (nonatomic, retain) UIImageView* image;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(SongLocal*)song forRadio:(Radio*)radio;

- (void)update:(SongLocal*)song;

@end
