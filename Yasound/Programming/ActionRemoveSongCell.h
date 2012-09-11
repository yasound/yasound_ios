//
//  ActionRemoveSongCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "Radio.h"
#import "WebImageView.h"
@interface ActionRemoveSongCell : UITableViewCell
{
    UIAlertView* _wifiWarning;
    UIAlertView* _legalUploadWarning;
    UIAlertView* _addedUploadWarning;
    
}

@property (nonatomic, assign) Song* song;
@property (nonatomic, assign) Radio* radio;

@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(Song*)song forRadio:(Radio*)radio;

- (void)update:(Song*)song;

@end
