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
@synthesize progressView;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(SongUploadManagerItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.item = item;
        self.item.delegate = self;
        
        
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
    
    sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progress" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = sheet.frame;
    [self addSubview:self.progressView];
    
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


- (void)update:(SongUploadManagerItem*)mediaItem
{
    self.item = mediaItem;
    self.item.delegate = self;
    
    self.label.text = [NSString stringWithFormat:@"%@ - %@", mediaItem.song.name, mediaItem.song.artist];
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



#pragma mark - SongUploadManagerItemDelegate

- (void)songUploadDidStart:(Song*)song
{
    
}

- (void)songUploadProgress:(Song*)song progress:(CGFloat)progress
{
    self.progressView.progress = progress;
}

- (void)songUploadDidFinish:(Song*)song
{
    [self.progressView removeFromSuperview];
    [self.progressView release];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongUpload_progressCompletedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = NSLocalizedString(@"SongUpload_progressCompleted", nil);
    [self addSubview:label];

}


@end
