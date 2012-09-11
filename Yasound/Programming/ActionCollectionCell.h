//
//  ActionCollectionCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongLocal.h"
#import "Radio.h"
#import "SongCatalog.h"

@interface ActionCollectionCell : UITableViewCell
{
    UIAlertView* _wifiWarning;
    UIAlertView* _legalUploadWarning;
    UIAlertView* _addedGenreUpload;
    UIAlertView* _addedPlaylistUpload;
}

typedef enum {
    
    eGenreAdd,
    ePlaylistAdd,
    eArtistAdd,
    eAlbumAdd
    
} SongAddMode;

@property (nonatomic) SongAddMode mode;

@property (nonatomic, assign) Radio* radio;
@property (nonatomic, assign) SongCatalog* catalog;
@property (nonatomic, retain) NSString* collection;

@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;

@property (nonatomic, retain) NSMutableArray* songsToUpload;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier genre:(NSString*)genre subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier playlist:(NSString*)playlist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier artist:(NSString*)artist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier album:(NSString*)album subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog;

- (void)updateGenre:(NSString*)genre subtitle:(NSString*)subtitle;
- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle;
- (void)updateArtist:(NSString*)artist subtitle:(NSString*)subtitle;

@end
