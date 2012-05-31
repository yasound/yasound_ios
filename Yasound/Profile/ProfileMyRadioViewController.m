//
//  ProfileMyRadioViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfileMyRadioViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "UserViewCell.h"
#import "RadioViewController.h"

typedef enum 
{
    eSectionCover = 0,
    eSectionSubscribersButton = 1,
    eSectionSubscribers = 2,
    eNbSections = 3
} ProfileSection;

@implementation ProfileMyRadioViewController


@synthesize radio;

#define BORDER 8
#define COVER_SIZE 96


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil radio:(Radio*)myRadio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = myRadio;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.title = NSLocalizedString(@"ProfileMyRadioView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (_subscribers) 
    {
        [_subscribers release];
        _subscribers = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_subscribers release];
    _subscribers = nil;
    
    //[[YasoundDataProvider main] userWithId:self.user.id target:self action:@selector(onUserInfo:info:)];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];
}




#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return eNbSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    if (section == eSectionCover)
        return 1;

    if (section == eSectionSubscribersButton)
        return 1;

    if (section == eSectionSubscribers)
        return [_subscribers count];
    
    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == eSectionCover)
        return (COVER_SIZE + 2*BORDER);
    
    return 62;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    if (section == eSectionSubscribers)
        return nil;

    
    NSString* title = nil;
    
    if (section == eSectionSubscribersButton)
    {
        title = NSLocalizedString(@"ProfileMyRadioView_section_subscribers", nil);
    }
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImage* image = [sheet image];
    CGFloat height = image.size.height;
    UIImageView* view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == eSectionCover)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainSongCardRow.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    else if (indexPath.section == eSectionSubscribersButton)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
        cell.backgroundView = view;
        [view release];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString* CellIdentifier = @"ProfileCellCover";
    static NSString *cellIdentifier1 = @"RadioSelectionTableViewCell_1";
    static NSString *cellIdentifier2 = @"RadioSelectionTableViewCell_2";
    

    if (indexPath.section == eSectionCover)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
            _imageView = [[WebImageView alloc] initWithImageAtURL:url];
            
            CGFloat size = COVER_SIZE;
            CGFloat height = (COVER_SIZE + 2*BORDER);
            CGRect frame = CGRectMake(BORDER, (height - size) / 2.f, size, size);
            _imageView.frame = frame;
            [cell addSubview:_imageView];
            [_imageView release];
            
            UIImageView* mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePhotoMask.png"]];
            mask.frame = frame;
            [cell addSubview:mask];
            [mask release];
            
            // name
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            [_name release];
            
            
        }
        else
        {
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
            [_imageView setUrl:url];
        }
        
        _name.text = self.radio.name;

        assert(cell != nil);
        return cell;
        
    }
    
    
    else if (indexPath.section == eSectionSubscribersButton)
    {
        NSString *cellIdentifier = cellIdentifier1;
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        
        cell.textLabel.text = NSLocalizedString(@"ProfileMyRadio_subscribers_button_label", nil);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        assert(cell != nil);
        return cell;
    }
    else if (indexPath.section == eSectionSubscribers)
    {
        UserViewCell* cell;
        
        cell = (UserViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil)
        {    
            cell = [[UserViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        
        if ((_subscribers == nil) || (_subscribers.count <= indexPath.row))
        {
            assert(0);
            NSLog(@"error with subscribers array.");
        }
        else
            cell.user = [_subscribers objectAtIndex:indexPath.row];

        assert(cell != nil);
        return cell;
    }
    else
    {
        assert(0);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eSectionSubscribersButton)
    {
        NSLog(@"TODO");
    }
}


#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nowPlayingClicked:(id)sender
{
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil]; 
}

////
//
//- (void)favoritesRadioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
//{
//    _favoriteRadios = radios;
//    [_favoriteRadios retain];
//    [_tableView reloadData];
//}
//


@end
