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



@implementation SongUploadCell

@synthesize item;
@synthesize label;
@synthesize labelStatus;
@synthesize progressView;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(SongUploadItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.item = item;
        self.item.delegate = self;
        self.progressView = nil;
        self.labelStatus = nil;

        
        
        // button "delete"
        UIImage* image = [UIImage imageNamed:@"CellButtonDel.png"];
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - image.size.width, 0, image.size.width, image.size.height)];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    
        
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.label = [sheet makeLabel];
    self.label.text = [NSString stringWithFormat:@"%@ - %@", item.song.name, item.song.artist];
    [self addSubview:self.label];
    
        if ((item.status == SongUploadItemStatusPending) || (item.status == SongUploadItemStatusUploading))
        {
            if (self.progressView == nil)
            {
                sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progress" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
                self.progressView.frame = sheet.frame;
                [self addSubview:self.progressView];
            }
            self.progressView.progress = self.item.currentProgress;
        }
        else if (item.status == SongUploadItemStatusCompleted)
        {
            if (self.labelStatus == nil)
            {
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                self.labelStatus = [sheet makeLabel];
                [self addSubview:self.labelStatus];
            }
            self.labelStatus.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
        }
        else if (item.status == SongUploadItemStatusFailed)
        {
            if (self.labelStatus == nil)
            {
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                self.labelStatus = [sheet makeLabel];
                [self addSubview:self.labelStatus];
            }
            self.labelStatus.text = NSLocalizedString(@"SongUpload_progressFailed", nil);   
        }
        
    
    }
    return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        self.item.delegate = nil;
    }
}


- (void)update:(SongUploadItem*)mediaItem
{
    self.item = mediaItem;
    self.item.delegate = self;
    
    self.label.text = [NSString stringWithFormat:@"%@ - %@", mediaItem.song.name, mediaItem.song.artist];
    
    
    if ((self.item.status == SongUploadItemStatusPending) || (self.item.status == SongUploadItemStatusUploading))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progress" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = sheet.frame;
        self.progressView.progress = self.item.currentProgress;
        [self addSubview:self.progressView];
    }
    else if (self.item.status == SongUploadItemStatusCompleted)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.labelStatus = [sheet makeLabel];
        [self addSubview:self.labelStatus];
        self.labelStatus.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
    }
    else if (self.item.status == SongUploadItemStatusFailed)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.labelStatus = [sheet makeLabel];
        [self addSubview:self.labelStatus];
        self.labelStatus.text = NSLocalizedString(@"SongUpload_progressFailed", nil);   
    }

    self.progressView.progress = self.item.currentProgress;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)onButtonClicked:(id)sender
{
    
}



#pragma mark - SongUploadItemDelegate

- (void)songUploadDidStart:(Song*)song
{
    
}

- (void)songUploadProgress:(Song*)song progress:(CGFloat)progress
{
    self.progressView.progress = progress;
}

- (void)songUploadDidFinish:(Song*)song info:(NSDictionary*)info
{
    NSLog(@"songUploadDidFinish : info %@", info);
    [self.progressView removeFromSuperview];
    [self.progressView release];
    
    BOOL succeeded = NO;
    succeeded = [[info objectForKey:@"succeeded"] boolValue];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    [self addSubview:label];
    
    if (succeeded)
        label.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
    else
        label.text = NSLocalizedString(@"SongUpload_progressFailed", nil);
    
//    if (!succeeded)
// changer le bouton LBDEBUG TODO        

}


@end
