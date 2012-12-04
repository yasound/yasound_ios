//
//  ActionAddServerSongCell.m
//  Yasound
//
//  Created by mat on 19/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ActionAddServerSongCell.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "Song.h"
#import "SongRadioCatalog.h"


@implementation ActionAddServerSongCell

@synthesize song;
@synthesize radio;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;
@synthesize image;
@synthesize activityView;

#define COVER_SIZE 30


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(YasoundSong*)s forRadio:(YaRadio*)r
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.song = s;
        self.radio = r;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* background = [sheet makeImage];
        [self addSubview:background];
        
        // button "add to upload list"
        sheet = [[Theme theme] stylesheetForKey:@"Programming.add" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        CGFloat offset = self.button.frame.origin.x + self.button.frame.size.width;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* coverUrl = [[YasoundDataProvider main] urlForPicture:self.song.cover];
        self.image = [[WebImageView alloc] initWithImageAtURL:coverUrl];
        self.image.frame = [self rect:sheet.frame withOffset:offset];
        [self addSubview:self.image];
        
        if (coverUrl == nil)
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
        self.label.text = self.song.name;
        [self addSubview:self.label];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.detailedLabel = [sheet makeLabel];
        self.detailedLabel.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        self.detailedLabel.text = [NSString stringWithFormat:@"%@ - %@", self.song.album_name, self.song.artist_name];
        [self addSubview:self.detailedLabel];
        
        sheet = [[Theme theme] stylesheetForKey:@"ServerSongAddCell.activityIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.frame = sheet.frame;
        self.activityView.hidden = YES;
        [self addSubview:self.activityView];
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

- (void)setEnabled:(BOOL)enabled
{
    if (enabled)
    {
        self.button.enabled = YES;
        self.image.alpha = 1;
        self.label.alpha = 1;
        self.detailedLabel.alpha = 1;
    }
    else
    {
        self.button.enabled = NO;
        self.image.alpha = 0.5;
        self.label.alpha = 0.5;
        self.detailedLabel.alpha = 0.5;
    }
}

- (void)update:(YasoundSong*)aSong
{
    self.song = aSong;
    
    NSURL* coverUrl = [[YasoundDataProvider main] urlForPicture:self.song.cover];
    self.image.url = coverUrl;
    
    if (coverUrl == nil)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image.image = [sheet image];
    }
    
    self.label.text = self.song.name;
    self.detailedLabel.text = [NSString stringWithFormat:@"%@ - %@", self.song.album_name, self.song.artist_name];
    
    [self setEnabled:YES];
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

- (void)onButtonClicked:(id)sender
{
    [[YasoundDataProvider main] addSong:self.song inRadio:self.radio target:self action:@selector(addedSong:info:)];
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

- (void)addedSong:(Song*)songUpdated info:(NSDictionary*)info
{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    if (!songUpdated)
        return;
    
    [self setEnabled:NO];
    
    NSDictionary* status = [info valueForKey:@"status"];
    BOOL success = [[status valueForKey:@"success"] boolValue];
    BOOL created = [[status valueForKey:@"created"] boolValue];
    
    if (success && !created)
    {
        NSString* title = [NSString stringWithFormat:@"%@ - %@", self.song.artist_name, self.song.name];
        NSString* message = NSLocalizedString(@"AddServerSong.AlreadyInProgramming.Message", nil);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    DLog(@"success %d  created %d", success, created);
    
    // update the song catalogs
    [[SongRadioCatalog main] updateSongAddedToProgramming:songUpdated];

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
