//
//  ProfileViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfileViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "RadioSelectionTableViewCell.h"


@implementation ProfileViewController


@synthesize user;

#define SECTION_COVER               0
#define SECTION_OWN_RADIO           1
#define SECTION_CURRENT_RADIO       2
#define SECTION_FAVORITE_RADIOS     3
#define SECTION_COUNT               4

#define BORDER 8
#define COVER_SIZE 96




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)aUser
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = aUser;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProfileView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (_favoriteRadios) 
    {
        [_favoriteRadios release];
        _favoriteRadios = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YasoundDataProvider main] userWithId:self.user.id target:self action:@selector(onUserInfo:info:)];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];
    
}




#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case SECTION_COVER:
        case SECTION_CURRENT_RADIO:
        case SECTION_OWN_RADIO:
            return 1;
            break;
        case SECTION_FAVORITE_RADIOS:
            if (_favoriteRadios) {
                return [_favoriteRadios count];
            }
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == SECTION_COVER)
        return (COVER_SIZE + 2*BORDER);
    
    return 44;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_COVER)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainSongCardRow.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger rowIndex = indexPath.row;
    NSInteger sectionIndex = indexPath.section;

    if (sectionIndex == SECTION_COVER)
    {
        static NSString* CellIdentifier = @"CellCover";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
      
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
            _imageView = [[WebImageView alloc] initWithImageAtURL:url];

            CGFloat size = COVER_SIZE;
            CGFloat height = (COVER_SIZE + 2*BORDER);
             _imageView.frame = CGRectMake(BORDER, (height - size) / 2.f, size, size);

            [cell addSubview:_imageView];
            // name
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];

            
        }
        else
        {
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
            [_imageView setUrl:url];
        }
        
        _name.text = user.name;
        return cell;
        
    }
    
    static NSString *cellIdentifier1 = @"RadioSelectionTableViewCell_1";
    static NSString *cellIdentifier2 = @"RadioSelectionTableViewCell_2";
    static NSString *cellIdentifier3 = @"RadioSelectionTableViewCell_3";
    
    
    NSString *cellIdentifier = cellIdentifier1;
    Radio* radio = nil;
    if (sectionIndex == SECTION_OWN_RADIO)
    {
        cellIdentifier = cellIdentifier1;
        
        radio = self.user.own_radio;
        if (!radio) 
        {
            return nil;
        }
    }
    else if (sectionIndex == SECTION_CURRENT_RADIO)
    {
        cellIdentifier = cellIdentifier2;

        radio = self.user.current_radio;
        if (!radio) 
        {
            return nil;
        }
    }
    else if (sectionIndex == SECTION_FAVORITE_RADIOS)
    {
        cellIdentifier = cellIdentifier3;

        NSArray* radios = _favoriteRadios;
        if (!radios) 
        {
            return nil;
        }
        
        radio = [radios objectAtIndex:rowIndex];
        if (!radio) 
        {
            return nil;
        }
    }

    RadioSelectionTableViewCell* cell;
    
    cell = (RadioSelectionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {    
        cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    }
    else
    {
        [cell updateWithRadio:radio rowIndex:rowIndex];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

- (void)onUserInfo:(User*)aUser info:(NSDictionary*)info
{
    self.user = aUser;
    [_tableView reloadData];
    [_favoriteRadios release];
    _favoriteRadios = nil;
    
    [[YasoundDataProvider main] favoriteRadiosForUser:self.user withTarget:self action:@selector(favoritesRadioReceived:withInfo:)];
    
}


- (void)favoritesRadioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    _favoriteRadios = radios;
    [_favoriteRadios retain];
    [_tableView reloadData];
}



@end
