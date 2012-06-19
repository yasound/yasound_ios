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
@synthesize label;
@synthesize detailedLabel;
@synthesize button;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(Song*)aSong
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) 
    {
        self.song = aSong;
        
        // button "add to upload list"
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongAdd_addButton" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if ([song isUploading])
            self.button.enabled = NO;
    
        
    sheet = [[Theme theme] stylesheetForKey:@"SongAdd_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.label = [sheet makeLabel];
    self.label.text = aSong.name;
    [self addSubview:self.label];

        sheet = [[Theme theme] stylesheetForKey:@"SongAdd_detailedLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.detailedLabel = [sheet makeLabel];
        self.detailedLabel.text = [NSString stringWithFormat:@"%@ - %@", aSong.album, aSong.artist];
        [self addSubview:self.detailedLabel];
    
    }
    return self;
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


- (void)update:(Song*)aSong
{
    self.song = aSong;
    
    if ([song isUploading])
        self.button.enabled = NO;
    else
        self.button.enabled = YES;

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
    
   // add an upload job to the queue
    [[SongUploadManager main] addSong:song startUploadNow:startUploadNow];
    
    // and flag the current song as "uploading song"
    song.uploading = YES;
    [self update:song];
    
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
