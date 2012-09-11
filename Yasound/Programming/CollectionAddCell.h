//
//  CollectionAddCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongLocal.h"
#import "Radio.h"

@interface CollectionAddCell : UITableViewCell
{
    UIAlertView* _wifiWarning;
    UIAlertView* _legalUploadWarning;
    UIAlertView* _addedGenreUpload;
    UIAlertView* _addedPlaylistUpload;
}

typedef enum {
    
    eGenreAdd,
    ePlaylistAdd
    
} SongAddMode;

@property (nonatomic) SongAddMode mode;

@property (nonatomic, assign) Radio* radio;
@property (nonatomic, retain) NSString* collection;

@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;

@property (nonatomic, retain) NSMutableArray* songsToUpload;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier genre:(NSString*)genre subtitle:(NSString*)subtitle forRadio:(Radio*)radio;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier playlist:(NSString*)playlist subtitle:(NSString*)subtitle forRadio:(Radio*)radio;

- (void)updateGenre:(NSString*)genre subtitle:(NSString*)subtitle;
- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle;

@end
