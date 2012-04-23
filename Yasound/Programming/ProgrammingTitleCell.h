//
//  ProgrammingTitleCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface ProgrammingTitleCell : UITableViewCell
{
    BOOL _editMode;
}

@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* sublabel;
@property (nonatomic, retain) UIButton* buttonDelete;
@property (nonatomic, retain) Song* song;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSong:(Song*)aSong;

- (void)updateWithSong:(Song*)aSong;

@end
