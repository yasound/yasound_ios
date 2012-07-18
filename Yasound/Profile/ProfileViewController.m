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
#import "RadioViewController.h"

typedef enum 
{
    eSectionCover = 0,
    eSectionOwnRadio = 1,
    eSectionCurrentRadio = 2,
    eSectionFavoriteRadios = 3,
} ProfileSection;

@implementation ProfileViewController


@synthesize user;

#define BORDER 8
#define COVER_SIZE 96


- (NSInteger)sectionCount
{
    NSInteger count = 1;
    if (self.user && self.user.own_radio && [self.user.own_radio.ready boolValue])
        count++;
    if (self.user && self.user.current_radio && [self.user.current_radio.ready boolValue])
        count++;
    if (_favoriteRadios && _favoriteRadios.count > 0) 
        count++;
    return count;
}

- (NSInteger)indexForSection:(ProfileSection)section
{
    if (section == eSectionCover)
        return 0;
    if (section == eSectionOwnRadio)
    {
        if (!self.user || !self.user.own_radio || ![self.user.own_radio.ready boolValue])
            return -1;
        return 1;
    }
    if (section == eSectionCurrentRadio)
    {
        if (!self.user || !self.user.current_radio || ![self.user.current_radio.ready boolValue])
            return -1;
        
        return 2;
    }
    if (section == eSectionFavoriteRadios)
    {
        if (!_favoriteRadios || _favoriteRadios.count == 0)
            return -1;
        
        NSInteger index = 1;
        if (self.user && self.user.own_radio && [self.user.own_radio.ready boolValue])
            index++;
        if (self.user && self.user.current_radio && [self.user.current_radio.ready boolValue])
            index++;
        return index;
    }
    return -1;
}



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
    
    _titleLabel.title = NSLocalizedString(@"ProfileView_title", nil);
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
    
    [_favoriteRadios release];
    _favoriteRadios = nil;
    
    DLog(@"%@", self.user.username);
    
    [[YasoundDataProvider main] userWithUsername:self.user.username target:self action:@selector(onUserInfo:success:)];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];
}




#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    if (section == [self indexForSection:eSectionCover])
    {
        return 1;
    }
    else if (section == [self indexForSection:eSectionOwnRadio])
    {
        if (self.user != nil && self.user.own_radio && [self.user.own_radio.ready boolValue]) 
            return 1;
    }
    else if (section == [self indexForSection:eSectionCurrentRadio])
    {
        if (self.user != nil && self.user.current_radio && [self.user.current_radio.ready boolValue]) 
            return 1;
    }
    else if (section == [self indexForSection:eSectionFavoriteRadios])
    {
        if (_favoriteRadios)
            return [_favoriteRadios count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSInteger indexCover = [self indexForSection:eSectionCover];
    if (indexPath.section == indexCover)
        return (COVER_SIZE + 2*BORDER);
    
    return 62;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    NSString* title = nil;
    
    if (section == [self indexForSection:eSectionOwnRadio])
    {
        title = NSLocalizedString(@"ProfileView_section_own_radio", nil);
    }
    else if (section == [self indexForSection:eSectionCurrentRadio])
    {
        title = NSLocalizedString(@"ProfileView_section_current_radio", nil);
    }
    else if (section == [self indexForSection:eSectionFavoriteRadios])
    {
        title = NSLocalizedString(@"ProfileView_section_favorite_radios", nil);
    }
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImage* image = [sheet image];
    CGFloat height = image.size.height;
    UIImageView* view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
    
    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger indexCover = [self indexForSection:eSectionCover];
    if (indexPath.section == indexCover)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainSongCardRow.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    NSInteger rowIndex = indexPath.row;
    NSInteger sectionIndex = indexPath.section;
    
    if (sectionIndex == [self indexForSection:eSectionCover])
    {
        static NSString* CellIdentifier = @"ProfileCellCover";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
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
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            [_name release];
            
            
        }
        else
        {
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
            [_imageView setUrl:url];
        }
        
        _name.text = self.user.name;
        return cell;
        
    }
    
    static NSString *cellIdentifier1 = @"RadioSelectionTableViewCell_1";
    static NSString *cellIdentifier2 = @"RadioSelectionTableViewCell_2";
    static NSString *cellIdentifier3 = @"RadioSelectionTableViewCell_3";
    
    
    NSString *cellIdentifier = cellIdentifier1;
    Radio* radio = nil;
    if (sectionIndex == [self indexForSection:eSectionOwnRadio])
    {
        cellIdentifier = cellIdentifier1;
        
        radio = self.user.own_radio;
        if (!radio && ![radio.ready boolValue]) 
        {
            return nil;
        }
    }
    else if (sectionIndex == [self indexForSection:eSectionCurrentRadio])
    {
        cellIdentifier = cellIdentifier2;
        
        radio = self.user.current_radio;
        if (!radio && ![radio.ready boolValue]) 
        {
            return nil;
        }
    }
    else if (sectionIndex == [self indexForSection:eSectionFavoriteRadios])
    {
        cellIdentifier = cellIdentifier3;
        
        NSArray* radios = _favoriteRadios;
        if (!radios) 
        {
            return nil;
        }
        
        radio = [radios objectAtIndex:rowIndex];
        if (!radio && ![radio.ready boolValue]) 
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
    // Displays selected radio
    Radio* radio = nil;
    if (indexPath.section == [self indexForSection:eSectionCover])
    {
        return;
    }
    else if (indexPath.section == [self indexForSection:eSectionOwnRadio])
    {
        radio = self.user.own_radio;
    }
    else if (indexPath.section == [self indexForSection:eSectionCurrentRadio])
    {
        radio = self.user.current_radio;
    }
    else if (indexPath.section == [self indexForSection:eSectionFavoriteRadios])
    {
        radio = [_favoriteRadios objectAtIndex:indexPath.row];
    }
    
    if (radio) 
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];  
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

- (void)onUserInfo:(ASIHTTPRequest*)req success:(BOOL)success
{
    int resCode = req.responseStatusCode;
    NSDictionary* response = [req responseDict];
    BOOL asuccess = resCode == 200 && response != nil;
    
    self.user = (User*)[req responseObjectWithClass:[User class]];
    
    
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
