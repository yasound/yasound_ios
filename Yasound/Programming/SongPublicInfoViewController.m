//
//  SongPublicInfoViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongPublicInfoViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "SongCatalog.h"
#import "YasoundReachability.h"
#import "SongUploadManager.h"
#import "ProgrammingUploadViewController.h"
#import <MessageUI/MessageUI.h>
#import "YasoundSessionManager.h"
#import "ShareModalViewController.h"
#import "ShareTwitterModalViewController.h"
#import "YasoundAppDelegate.h"


@implementation SongPublicInfoViewController


@synthesize song;
@synthesize radio;

#define NB_SECTIONS 1

#define SECTION_COVER 0


#define BORDER 8
#define COVER_SIZE 320




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong onRadio:(YaRadio*)aRadio showNowPlaying:(BOOL)showNowPlaying
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        self.radio = aRadio;
        _showNowPlaying = showNowPlaying;
        _ownSong = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}




#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return gIndexMap.count;
    return NB_SECTIONS;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 432;
}


- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.backgroundView = view;
    
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_COVER)
    {
        static NSString* CellIdentifier = @"SongInfoCellCover";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor blackColor];
            
            
            if (self.song.large_cover)
            {
                NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.large_cover];
                _imageView = [[WebImageView alloc] initWithImageAtURL:url];
            }
            else
            {
                // fake image
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy320" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _imageView = [[WebImageView alloc] initWithImage:[sheet image]];
            }
            
            CGFloat size = COVER_SIZE;
             _imageView.frame = CGRectMake(cell.frame.size.width/2.f - size/2.f, 0 , size, size);
            
            [cell addSubview:_imageView];
            
            // name, artist, album
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView.SongPublicView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongPublicView_artist" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _artist = [sheet makeLabel];
            [cell addSubview:_artist];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongPublicView_album" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _album = [sheet makeLabel];
            [cell addSubview:_album];

        }
        
        else
        {
          NSURL* url = [[YasoundDataProvider main] urlForSongCover:self.song];
          [_imageView setUrl:url];
        }
        
        _name.text = song.name;
        _artist.text = song.artist;
        _album.text = song.album;

        
        return cell;
        
    }

    
    
    return nil;
}


- (void)trackInteractionViewLikeButtonCliked
{
    int nbLikes = [_likesLabel.text intValue];
    nbLikes++;
    _likesLabel.text = [NSString stringWithFormat:@"%d", nbLikes];

}


- (void)receivedCurrentSongStatus:(SongStatus*)status withInfo:(NSDictionary*)info
{
    NSInteger nbLikes = [status.likes intValue];
    _likesLabel.text = [NSString stringWithFormat:@"%d", nbLikes];
    self.song.likes = [NSNumber numberWithInteger:nbLikes];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
    




- (NSString*) dateToString:(NSDate*)d
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSDate* now = [NSDate date];
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
    NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:d];
    
    if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
    {
        // today: show time
        [dateFormat setDateFormat:@"dd/MM, HH:mm"];
    }
    else
    {
        // not today: show date
        [dateFormat setDateFormat:@"dd/MM, HH:mm"];
    }
    
    NSString* s = [dateFormat stringFromDate:d];
    [dateFormat release];
    return s;
}











#pragma mark - IBActions






- (void)onTrackShare:(id)sender
{
    _queryShare = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:NSLocalizedString(@"Settings.saveOrCancel.cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
        [_queryShare addButtonWithTitle:@"Facebook"];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
        [_queryShare addButtonWithTitle:@"Twitter"];
    
    [_queryShare addButtonWithTitle:NSLocalizedString(@"ShareModalView_email_label", nil)];
    
    _queryShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [_queryShare showInView:self.view];
    
}


#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    
    // share query result
    if (actionSheet == _queryShare)
    {
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:@"Facebook"])
        {
            ShareModalViewController* view = [[ShareModalViewController alloc] initWithNibName:@"ShareModalViewController" bundle:nil forSong:self.song onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:@"Twitter"])
            
        {
            ShareTwitterModalViewController* view = [[ShareTwitterModalViewController alloc] initWithNibName:@"ShareTwitterModalViewController" bundle:nil forSong:self.song onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"ShareModalView_email_label", nil)])
        {
            [self shareWithMail];
        }
        
        return;
    }
}



- (void)onShareModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}




- (void)shareWithMail
{
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, self.song.name, self.song.artist, self.radio.name];
    NSString* fullLink = [[NSURL alloc] initWithString:self.radio.web_url];
    
    NSString* body = [NSString stringWithFormat:@"%@\n\n%@", fullMessage, [fullLink absoluteString]];
    
	MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject: NSLocalizedString(@"Yasound_share", nil)];
    
    [mailViewController setMessageBody:body isHTML:NO];
    
	mailViewController.mailComposeDelegate = self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
#endif
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{	
	[APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result) 
    {
		case MFMailComposeResultSent: 
        {
            [[YasoundDataProvider main] radioHasBeenShared:self.radio with:@"email" withCompletionBlock:^(int status, NSString* response, NSError* error){
                if (error)
                {
                    DLog(@"radio share with email error: %d - %@", error.code, error. domain);
                    return;
                }
                if (status != 200)
                {
                    DLog(@"radio share with email error: response status %d", status);
                    return;
                }
            }];
            break;
        }
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}	
}












@end
