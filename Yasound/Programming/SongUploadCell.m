//
//  SongUploadCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUploadCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "RootViewController.h"
#import "YasoundReachability.h"
#import "SongUploading.h"
#import "WebImageView.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"

@implementation SongUploadCell

@synthesize item;
@synthesize image;
@synthesize label;
@synthesize labelStatus;
@synthesize progressView;
@synthesize progressLabel;

#define COVER_SIZE 30

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(SongUploadItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.item = item;
        self.item.delegate = self;
        self.progressView = nil;
        self.progressLabel = nil;
        self.labelStatus = nil;


        // track image
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        SongUploading* songup = self.item.song;
        
        self.isSongLocal = [songup.songLocal isKindOfClass:[SongLocal class]];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image.frame = sheet.frame;
        
        if (self.isSongLocal)
        {
            UIImage* coverImage = [songup.songLocal.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)];
            self.image = [[UIImageView alloc] initWithImage:coverImage];
            self.image.frame = sheet.frame;

            if (coverImage == nil)
            {
                sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                self.image = [[UIImageView alloc] initWithImage:[sheet image]];
                self.image.frame = sheet.frame;
            }
        }
        else
        {
            NSURL* url = [[YasoundDataProvider main] urlForPicture:songup.songLocal.cover];
            self.image = [[WebImageView alloc] initWithImageAtURL:url];
        }

        [self addSubview:self.image];
        
        
        // track image mask
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImageMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* mask = [sheet makeImage];
        [self addSubview:mask];
        
        
        // button "delete"
        sheet = [[Theme theme] stylesheetForKey:@"Programming.delUpload" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIButton* button = [sheet makeButton];
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    
        
    sheet = [[Theme theme] stylesheetForKey:@"Uploads.name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.label = [sheet makeLabel];
    self.label.text = [NSString stringWithFormat:@"%@ - %@", songup.songLocal.name, songup.songLocal.artist];
    [self addSubview:self.label];
        
        
        // status label
        sheet = [[Theme theme] stylesheetForKey:@"Uploads.progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.labelStatus = [sheet makeLabel];
        self.labelStatus.text = @"";
        [self addSubview:self.labelStatus];
        // don't show it now, show it when you need it
        self.labelStatus.hidden = YES;


        if (self.progressView == nil)
        {
            sheet = [[Theme theme] stylesheetForKey:@"Uploads.progress" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            self.progressView.frame = sheet.frame;
            [self addSubview:self.progressView];
            
            sheet = [[Theme theme] stylesheetForKey:@"Uploads.progressLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.progressLabel = [sheet makeLabel];
            self.progressLabel.text = NSLocalizedString(@"SongUpload_progress_prepare", nil);
            [self addSubview:self.progressLabel];
            
        }

        if (item.status == SongUploadItemStatusUploading)
        {
            self.progressView.hidden = NO;
            self.progressLabel.hidden = NO;
            self.labelStatus.hidden = YES;
            self.progressView.progress = self.item.currentProgress;
            self.progressLabel.text = [SongUploadCell sizeToStr:self.item.currentSize];
        }
        else if (item.status == SongUploadItemStatusPending)
        {
            if ([SongUploadManager main].isRunning)
                self.labelStatus.text = NSLocalizedString(@"SongUpload_pending", nil);    
            else if ([YasoundReachability main].networkStatus != ReachableViaWiFi)
                self.labelStatus.text = NSLocalizedString(@"SongUpload_waitingForWifi", nil);   
            else 
                self.labelStatus.text = NSLocalizedString(@"SongUpload_pending_not_running", nil);   

            self.progressView.hidden = YES;
            self.progressLabel.hidden = YES;
            self.labelStatus.hidden = NO;
        }
        else if (item.status == SongUploadItemStatusCompleted)
        {
            if (self.item.detailedInfo != nil)
                self.labelStatus.text = [NSString stringWithFormat:@"%@ - %@", 
                                         NSLocalizedString(@"SongUpload_progressCompleted", nil), NSLocalizedString(self.item.detailedInfo, nil)];
            else
                self.labelStatus.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
            self.progressView.hidden = YES;
            self.progressLabel.hidden = YES;
            self.labelStatus.hidden = NO;
        }
        else if (item.status == SongUploadItemStatusFailed)
        {
            if (self.item.detailedInfo != nil)
                self.labelStatus.text = [NSString stringWithFormat:@"%@ - %@", 
                                         NSLocalizedString(@"SongUpload_progressFailed", nil), NSLocalizedString(self.item.detailedInfo, nil)];
            else
                self.labelStatus.text = NSLocalizedString(@"SongUpload_progressFailed", nil);   
            self.progressView.hidden = YES;
            self.progressLabel.hidden = YES;
            self.labelStatus.hidden = NO;
        }
        
    
    }
    return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        if (self.item != nil)
            self.item.delegate = nil;
    }
}


- (void)update:(SongUploadItem*)mediaItem
{
    self.item = mediaItem;
    self.item.delegate = self;
    
    self.label.text = [NSString stringWithFormat:@"%@ - %@", mediaItem.song.songLocal.name, mediaItem.song.songLocal.artist];
    
    SongUploading* songup = self.item.song;
    
    self.isSongLocal = [songup.songLocal isKindOfClass:[SongLocal class]];
    
    if (self.isSongLocal)
    {
        UIImage* coverImage = [songup.songLocal.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)];
        
        if (coverImage == nil)
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.image.image = [sheet image];
        }
        else
            self.image.image = coverImage;

    }
    else
    {
        NSURL* url = [[YasoundDataProvider main] urlForPicture:songup.songLocal.cover];
        self.image = [[WebImageView alloc] initWithImageAtURL:url];
    }

    
    if (self.item.status == SongUploadItemStatusUploading)
    {
        self.progressView.progress = self.item.currentProgress;
        self.progressView.hidden = NO;
        self.progressLabel.hidden = NO;
        self.labelStatus.hidden = YES;
    }
    else if (self.item.status == SongUploadItemStatusPending) 
    {
        self.progressView.hidden = YES;
        self.progressLabel.hidden = YES;
        self.labelStatus.hidden = NO;
        
        if ([SongUploadManager main].isRunning)
            self.labelStatus.text = NSLocalizedString(@"SongUpload_pending", nil);    
        else if ([YasoundReachability main].networkStatus != ReachableViaWiFi)
            self.labelStatus.text = NSLocalizedString(@"SongUpload_waitingForWifi", nil);        
    }
    else if (self.item.status == SongUploadItemStatusCompleted)
    {
        self.progressView.hidden = YES;
        self.progressLabel.hidden = YES;
        self.labelStatus.hidden = NO;
        if (self.item.detailedInfo != nil)
            self.labelStatus.text = [NSString stringWithFormat:@"%@ - %@", 
                                     NSLocalizedString(@"SongUpload_progressCompleted", nil), NSLocalizedString(self.item.detailedInfo, nil)];
        else
            self.labelStatus.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
    }
    else if (self.item.status == SongUploadItemStatusFailed)
    {
        self.progressView.hidden = YES;
        self.progressLabel.hidden = YES;
        self.labelStatus.hidden = NO;
        
        if (self.item.detailedInfo != nil)
            self.labelStatus.text = [NSString stringWithFormat:@"%@ - %@", 
                                     NSLocalizedString(@"SongUpload_progressFailed", nil), NSLocalizedString(self.item.detailedInfo, nil)];
        else
            self.labelStatus.text = NSLocalizedString(@"SongUpload_progressFailed", nil);   
        
    }

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)onButtonClicked:(id)sender
{
    [self.item cancelUpload];
}



#pragma mark - SongUploadItemDelegate

- (void)songUploadDidStart:(SongUploading*)song
{
    [self update:self.item];
}


- (void)songUploadDidInterrupt:(SongUploading*)song
{
    [self update:self.item];
}

- (void)songUploadProgress:(SongUploading*)song progress:(CGFloat)progress  bytes:(NSUInteger)bytes
{
    self.progressView.progress = progress;
    self.progressLabel.text = [SongUploadCell sizeToStr:bytes];
}



+ (NSString*)sizeToStr:(NSUInteger)bytes
{
    static NSUInteger BYTES_1o = 1024;
    static NSUInteger BYTES_1Ko = 1024*1024;
    static NSUInteger BYTES_1Mo = 1024*1024*1024;
    
    if (bytes == 0)
        return NSLocalizedString(@"SongUpload_progress_prepare", nil);


    NSString* sizeStr;
    if (bytes < BYTES_1o)
        sizeStr = [NSString stringWithFormat:@"%d o", bytes];
    else if (bytes < BYTES_1Ko)
        sizeStr = [NSString stringWithFormat:@"%.2f Ko", (CGFloat)bytes / (CGFloat)BYTES_1o];
    else if (bytes < BYTES_1Mo)
        sizeStr = [NSString stringWithFormat:@"%.2f Mo", (CGFloat)bytes / (CGFloat)BYTES_1Ko];
    else
        sizeStr = [NSString stringWithFormat:@"%.2f Go", (CGFloat)bytes / (CGFloat)BYTES_1Mo];
    
    return sizeStr;
    
}


- (void)songUploadDidFinish:(SongUploading*)song info:(NSDictionary*)info
{
    DLog(@"songUploadDidFinish : info %@", info);

    BOOL succeeded = NO;
    succeeded = [[info objectForKey:@"succeeded"] boolValue];
        
    
    // update the GUI, using the same item
    [self update:self.item];

    // update the song catalogs
    [[SongRadioCatalog main] updateSongAddedToProgramming:song.songLocal];
    [[SongLocalCatalog main] updateSongAddedToProgramming:song.songLocal];
}


@end
