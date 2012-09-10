//
//  CollectionAddCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "CollectionAddCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadManager.h"
#import "SongCatalog.h"
#import "ActivityAlertView.h"
#import "YasoundReachability.h"


@implementation CollectionAddCell

@synthesize mode;
@synthesize radio;
@synthesize collection;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;


//
//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview)
//    {
//        if (self.image)
//            [self.image releaseCache];
//    }
//}
//




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier genre:(NSString*)genre subtitle:(NSString*)subtitle forRadio:(Radio*)radio {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = eGenreAdd;
        self.radio = radio;
        self.collection = genre;
        
        [self commitInit];
        [self updateGenre:genre subtitle:subtitle];
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier playlist:(NSString*)playlist subtitle:(NSString*)subtitle forRadio:(Radio*)radio {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = ePlaylistAdd;
        self.radio = radio;
        self.collection = playlist;
        
        [self commitInit];
        [self updatePlaylist:playlist subtitle:subtitle];
    }
    return self;
}


- (void)commitInit {

        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
    
    
        // button "add to upload list"
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.add" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
//    CGFloat offset = self.button.frame.origin.x + self.button.frame.size.width;
    CGFloat offset = 0;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        self.label.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        [self addSubview:self.label];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.detailedLabel = [sheet makeLabel];
        self.detailedLabel.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        [self addSubview:self.detailedLabel];
        
        
//        if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
//        {
//            self.button.enabled = NO;
//            self.image.alpha = 0.5;
//            self.label.alpha = 0.5;
//            self.detailedLabel.alpha = 0.5;
//        }

}



                      
- (CGRect)rect:(CGRect)frame withOffset:(CGFloat)offset 
{
    CGRect newframe = CGRectMake(frame.origin.x + offset, frame.origin.y, frame.size.width, frame.size.height);
    return newframe;
}

- (CGRect)updateToRect:(CGRect)frame withOffset:(CGFloat)offset withInset:(CGFloat)inset
{
    CGRect newframe = CGRectMake(frame.origin.x + offset, frame.origin.y, frame.size.width - inset, frame.size.height);
    return newframe;
}

//
//- (void)willMoveToSuperview:(UIView *)newSuperview 
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview) 
//    {
//        self.item.delegate = nil;
//    }
//}


- (void)updateGenre:(NSString*)genre subtitle:(NSString*)subtitle
{
    self.mode = eGenreAdd;
    self.collection = genre;
    
    self.label.text = genre;
    self.detailedLabel.text = subtitle;
    
    
//    if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
//    {
//        self.button.enabled = NO;
//        self.image.alpha = 0.5;
//        self.label.alpha = 0.5;
//        self.detailedLabel.alpha = 0.5;
//    }
//    else
//    {
//        self.button.enabled = YES;
//        self.image.alpha = 1;
//        self.label.alpha = 1;
//        self.detailedLabel.alpha = 1;
//    }
}


- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle
{
    self.mode = ePlaylistAdd;
    self.collection = playlist;
    
    self.label.text = playlist;
    self.detailedLabel.text = subtitle;
    
    
    //    if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
    //    {
    //        self.button.enabled = NO;
    //        self.image.alpha = 0.5;
    //        self.label.alpha = 0.5;
    //        self.detailedLabel.alpha = 0.5;
    //    }
    //    else
    //    {
    //        self.button.enabled = YES;
    //        self.image.alpha = 1;
    //        self.label.alpha = 1;
    //        self.detailedLabel.alpha = 1;
    //    }
}











- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)onButtonClicked:(id)sender
{
//    BOOL can = [[SongUploader main] canUploadSong:song];
//    if (!can)
//    {
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongAddView_cant_add_title", nil) message:NSLocalizedString(@"SongAddView_cant_add_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [av release];  
//        return;
//    }
//
//    BOOL error;
//    BOOL warning = [[UserSettings main] boolForKey:USKEYuploadLegalWarning error:&error];                    
//    if (error || warning)
//    {
//        _legalUploadWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongUpload_warning_title", nil) message:NSLocalizedString(@"SongUpload_warning_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:NSLocalizedString(@"Button_iAgree", nil),nil ];
//        [_legalUploadWarning show];
//        [_legalUploadWarning release];  
//    }
//    else
//    [self requestUpload];

}




#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView == _legalUploadWarning) && (buttonIndex == 1))
    {
        [[UserSettings main] setBool:NO forKey:USKEYuploadLegalWarning];
        [self requestUpload];
        return;
    }

    
    if ((alertView == _addedUploadWarning) && (buttonIndex == 1))
    {
        [[UserSettings main] setBool:NO forKey:USKEYuploadAddedWarning];
        return;
    }
}

- (void)requestUpload
{
//    BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
//    
//        
//    BOOL startUploadNow = isWifi;
//    
//    SongUploading* songUploading = [SongUploading new];
//    songUploading.songLocal = self.song;
//    songUploading.radio_id = self.radio.id;
//    
//   // add an upload job to the queue
//    [[SongUploadManager main] addSong:songUploading startUploadNow:startUploadNow];
//    
//    // refresh gui
//    [self update:self.song];
//    
////    // and flag the current song as "uploading song"
////    [song setProgrammed
////    [self update:song];
//    
//    if (!isWifi && ![SongUploadManager main].notified3G)
//    {
//        [SongUploadManager main].notified3G = YES;
//        
//        _wifiWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundUpload_add_WIFI_title", nil) message:NSLocalizedString(@"YasoundUpload_add_WIFI_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [_wifiWarning show];
//        [_wifiWarning release];  
//        return; 
//    }
//    else
//    {
//        BOOL error;
//        BOOL warning = [[UserSettings main] boolForKey:USKEYuploadAddedWarning error:&error];
//        if (error || warning)
//        {
//            _addedUploadWarning = [[UIAlertView alloc] initWithTitle:@"Yasound" message:NSLocalizedString(@"SongAddView_added", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_OK", nil) otherButtonTitles:NSLocalizedString(@"Button_dontShowAgain", nil),nil ];
//            [_addedUploadWarning show];
//            [_addedUploadWarning release];  
//        }
//
//        // [ActivityAlertView showWithTitle:NSLocalizedString(@"", nil) closeAfterTimeInterval:1];
//    }
    
}




@end
