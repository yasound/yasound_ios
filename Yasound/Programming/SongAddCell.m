//
//  SongAddCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongAddCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadManager.h"
#import "SongCatalog.h"
#import "ActivityAlertView.h"
#import "YasoundReachability.h"


@implementation SongAddCell

@synthesize song;
@synthesize radio;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;
@synthesize image;


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


#define COVER_SIZE 30


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(SongLocal*)aSong forRadio:(Radio*)radio
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    BOOL isSongLocal = [aSong isKindOfClass:[SongLocal class]];
    assert(isSongLocal);
    
    if (self) 
    {
        self.song = aSong;
        self.radio = radio;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // button "add to upload list"
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.add" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        CGFloat offset = self.button.frame.origin.x + self.button.frame.size.width;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImage* coverImage = [self.song.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)];
        self.image = [[UIImageView alloc] initWithImage:coverImage];
        self.image.frame = [self rect:sheet.frame withOffset:offset];
        [self addSubview:self.image];
        
        if (coverImage == nil)
        {
            sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.image.image = [sheet image];
        }
        

        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImageMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* mask = [sheet makeImage];
        mask.frame = [self rect:sheet.frame withOffset:offset];
        [self addSubview:mask];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        self.label.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        self.label.text = aSong.name;
        [self addSubview:self.label];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.detailedLabel = [sheet makeLabel];
        self.detailedLabel.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        self.detailedLabel.text = [NSString stringWithFormat:@"%@ - %@", aSong.album, aSong.artist];
        [self addSubview:self.detailedLabel];
        
        
//        if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
        if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.catalogKey forRadio:self.radio] != nil))
        {
            self.button.enabled = NO;
            self.image.alpha = 0.5;
            self.label.alpha = 0.5;
            self.detailedLabel.alpha = 0.5;
        }

    }
    return self;
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


- (void)update:(SongLocal*)aSong
{
    self.song = aSong;
    
//    if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
    if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.catalogKey forRadio:self.radio] != nil))
    {
        self.button.enabled = NO;
        self.image.alpha = 0.5;
        self.label.alpha = 0.5;
        self.detailedLabel.alpha = 0.5;
    }
    else
    {
        self.button.enabled = YES;
        self.image.alpha = 1;
        self.label.alpha = 1;
        self.detailedLabel.alpha = 1;
    }

    UIImage* coverImage = [self.song.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)];
    self.image.image = coverImage;
    
    if (coverImage == nil)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image.image = [sheet image];
    }

    
    self.label.text = aSong.name;
    self.detailedLabel.text = [NSString stringWithFormat:@"%@ - %@", aSong.album, aSong.artist];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)onButtonClicked:(id)sender
{
    BOOL can = [[SongUploader main] canUploadSong:song];
    if (!can)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongAddView_cant_add_title", nil) message:NSLocalizedString(@"SongAddView_cant_add_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    BOOL error;
    BOOL warning = [[UserSettings main] boolForKey:USKEYuploadLegalWarning error:&error];
    if (error || warning)
    {
        _legalUploadWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongUpload_warning_title", nil) message:NSLocalizedString(@"SongUpload_warning_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:NSLocalizedString(@"Button_iAgree", nil),nil ];
        [_legalUploadWarning show];
        [_legalUploadWarning release];
    }
    else
        [self requestUpload];

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
    BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
    
    
    BOOL startUploadNow = isWifi;
    
    SongUploading* songUploading = [SongUploading new];
    songUploading.songLocal = self.song;
    songUploading.radio_id = self.radio.id;
    
    // add an upload job to the queue
    [[SongUploadManager main] addSong:songUploading startUploadNow:startUploadNow];
    
    // refresh gui
    [self update:self.song];
    
    //    // and flag the current song as "uploading song"
    //    [song setProgrammed
    //    [self update:song];
    
    if (!isWifi && ![SongUploadManager main].notified3G)
    {
        [SongUploadManager main].notified3G = YES;
        
        _wifiWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundUpload_add_WIFI_title", nil) message:NSLocalizedString(@"YasoundUpload_add_WIFI_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_wifiWarning show];
        [_wifiWarning release];
        return;
    }
    else
    {
        BOOL error;
        BOOL warning = [[UserSettings main] boolForKey:USKEYuploadAddedWarning error:&error];
        if (error || warning)
        {
            _addedUploadWarning = [[UIAlertView alloc] initWithTitle:@"Yasound" message:NSLocalizedString(@"SongAddView_added", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_OK", nil) otherButtonTitles:NSLocalizedString(@"Button_dontShowAgain", nil),nil ];
            [_addedUploadWarning show];
            [_addedUploadWarning release];
        }
        
        // [ActivityAlertView showWithTitle:NSLocalizedString(@"", nil) closeAfterTimeInterval:1];
    }
    
}









@end
