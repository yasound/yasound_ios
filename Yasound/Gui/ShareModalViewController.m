//
//  ShareModalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ShareModalViewController.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"

@interface ShareModalViewController ()

@end

#define NB_SECTIONS 2

#define SECTION_PUBLISH 0
#define SECTION_PUBLISH_NB_ROWS 3
#define ROW_PUBLISH_FACEBOOK 0
#define ROW_PUBLISH_TWITTER 1
#define ROW_PUBLISH_BUTTON 2

#define SECTION_EMAIL 1
#define SECTION_EMAIL_NB_ROWS 2
#define ROW_EMAIL_LABEL 0
#define ROW_EMAIL_BUTTON 1



@implementation ShareModalViewController

@synthesize song;
@synthesize artist;
@synthesize fullLink;
@synthesize pictureUrl;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(NSString*)aSong andArtist:(NSString*)anArtist target:(id)target action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        self.artist = anArtist;
        
        _target = target;
        _action = action;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    _cancel.title = NSLocalizedString(@"Navigation_cancel", nil);
    
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];

    _labelFacebook.text = NSLocalizedString(@"ShareModalView_facebook_label", nil);
    _labelTwitter.text = NSLocalizedString(@"ShareModalView_twitter_label", nil);
    _labelPublishButton.text = NSLocalizedString(@"ShareModalView_publish_button_label", nil);
    _labelEmail.text = NSLocalizedString(@"ShareModalView_email_label", nil);
    _labelEmailButton.text = NSLocalizedString(@"ShareModalView_email_button_label", nil);

    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareTextView.png"]];
    [_textFacebook addSubview:background];
    [_textFacebook sendSubviewToBack:background];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareTextView.png"]];
    [_textTwitter addSubview:background];
    [_textTwitter sendSubviewToBack:background];
    
//    _textFacebook.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ShareTextView.png"]];
//
//    _textTwitter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ShareTextView.png"]];


    // format messages
    Radio* currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* facebookFullMessage = [NSString stringWithFormat:message, self.song, self.artist, currentRadio.name];

    //
    self.pictureUrl = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];
    NSString* link = [APPDELEGATE getServerUrlWith:@"listen/%@"];
    self.fullLink = [[NSURL alloc] initWithString:[NSString stringWithFormat:link, currentRadio.uuid]];
    
    //
    NSString* twitterFullMessage = [NSString stringWithFormat:@"#yasound %@ %@ ", [fullLink absoluteString], facebookFullMessage];
    
    //
    NSString* emailFullMessage = facebookFullMessage;

    
    // message objects input
    _textFacebook.text = facebookFullMessage;
    _textTwitter.text = twitterFullMessage;

    
    // enable sharing
    BOOL enableFacebook = YES;
    BOOL enableTwitter = YES;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dico = [defaults objectForKey:@"Sharing"];
    NSNumber* nb = [dico objectForKey:@"facebook"];
    if (nb)
        enableFacebook = [nb boolValue];
    nb = [dico objectForKey:@"twitter"];
    if (nb)
        enableTwitter = [nb boolValue];
    
    _switchFacebook.on = enableFacebook;
    _switchTwitter.on = enableTwitter;
    
    
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








#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NB_SECTIONS;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_PUBLISH)
        return SECTION_PUBLISH_NB_ROWS;
    if (section == SECTION_EMAIL)
        return SECTION_EMAIL_NB_ROWS;
    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_FACEBOOK))
        return _cellFacebook.frame.size.height;
    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_TWITTER))
        return _cellTwitter.frame.size.height;
    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_BUTTON))
        return _cellPublishButton.frame.size.height;
    
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_LABEL))
        return _cellEmail.frame.size.height;
    
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_BUTTON))
        return _cellEmailButton.frame.size.height;
    
    return 44;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}





//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == 0)
//        return nil;
//    
//    if (section == SECTION_MONTHCHART)
//        title = NSLocalizedString(@"StatsView_monthselector_label", nil);
//    
//    else if (section == SECTION_LEADERBOARD)
//        title = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_LABEL))
    {
        UIImageView* view = nil;
        view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareSmallCellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    NSInteger nbRows;
    if (indexPath.section == SECTION_PUBLISH)
    {
        nbRows = SECTION_PUBLISH_NB_ROWS;
    }
    else if (indexPath.section == SECTION_EMAIL) 
    {
        nbRows = SECTION_EMAIL_NB_ROWS;
    }
    
    
    if (nbRows == 1)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareCellRowSingle.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == 0)
    {
        UIImageView* view = nil;
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareCellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == (nbRows -1))
    {
        UIImageView* view = nil;
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareCellRowLast.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else
    {
        UIImageView* view = nil;
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareCellRowInter.png"]];
        cell.backgroundView = view;
        [view release];
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_FACEBOOK))
        return _cellFacebook;

    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_TWITTER))
        return _cellTwitter;

    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_BUTTON))
        return _cellPublishButton;

    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_LABEL))
        return _cellEmail;

    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_BUTTON))
        return _cellEmailButton;
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}







#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_target == nil)
        return;
    
    [_target performSelector:_action];
}

- (IBAction)onSwitchFacebook:(id)sender
{
    if (_switchFacebook.on)
    {
        _textFacebook.editable = YES;
        _textFacebook.textColor = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1];
    }
    else 
    {
        _textFacebook.editable = NO;
        _textFacebook.textColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1];
    }
    
    _buttonPublish.enabled = (_switchFacebook.on || _switchTwitter.on);
}

- (IBAction)onSwitchTwitter:(id)sender
{
    if (_switchTwitter.on)
    {
        _textTwitter.editable = YES;
        _textTwitter.textColor = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1];
    }
    else 
    {
        _textTwitter.editable = NO;
        _textTwitter.textColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1];
    }
    
    _buttonPublish.enabled = (_switchFacebook.on || _switchTwitter.on);
}

- (IBAction)onPublishButton:(id)sender
{
    if (_target == nil)
        return;
    
    [_target performSelector:_action];
}

- (IBAction)onEmailButton:(id)sender
{
    if (_target == nil)
        return;
    
    [_target performSelector:_action];
    
}



@end
