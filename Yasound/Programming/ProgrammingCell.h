//
//  ProgrammingCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"


@interface ProgrammingCell : UITableViewCell
{
    BOOL _editMode;
    
    id _deletingTarget;
    SEL _deletingAction; // (void)onDeleteRequestedL:(UITableViewCell*)cell forSong:(Song*)song
}

@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UIImageView* mask;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* sublabel;
@property (nonatomic, retain) UIButton* buttonDelete;
@property (nonatomic, retain) UILabel* buttonLabel;
@property (nonatomic, retain) UIActivityIndicatorView* buttonSpinner;
@property (nonatomic, retain) Song* song;
@property (nonatomic) NSInteger row;


// use title and subtitle from song
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSong:(Song*)aSong atRow:(NSInteger)row deletingTarget:(id)deletingTarget deletingAction:(SEL)deletingAction;

// use custom title and subtitle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier text:(NSString*)text detailText:(NSString*)detailText customImage:(UIImage*)customImage refSong:(Song*)aSong;

- (void)updateWithSong:(Song*)aSong atRow:(NSInteger)row;

- (void)updateWithText:(NSString*)text detailText:(NSString*)detailText customImage:(UIImage*)customImage refSong:(Song*)refSong;

@end
