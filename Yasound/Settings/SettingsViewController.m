//
//  SettingsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SettingsViewController.h"
#import "StyleSelectorViewController.h"
#import "ThemeSelectorViewController.h"
#import "Theme.h"
#import "KeywordsViewController.h"
#import "PlaylistsViewController.h"


#define SECTION_CONFIG 0
#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_GENRE 1
#define ROW_CONFIG_KEYWORDS 2

#define SECTION_IMAGE 1
#define ROW_IMAGE 0

#define SECTION_THEME 2
#define ROW_THEME 0





@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"SettingsView_title", nil);
        
        // "next" button
        UIBarButtonItem* nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsView_navigation_next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onNext:)];
        self.navigationItem.rightBarButtonItem = nextBtn;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_keywords release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _settingsTitleLabel.text = NSLocalizedString(@"SettingsView_row_title_label", nil);
    _settingsTitleTextField.text = [NSString stringWithFormat:@"%@'s Yasound", [[UIDevice currentDevice] name]];

    _settingsImageLabel.text = NSLocalizedString(@"SettingsView_row_image_label", nil);
    [_settingsImageImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsImageImage.layer setBorderWidth: 1];    
    
    
    NSString* themeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundTheme"];
    if (themeId == nil)
    {
        themeId = @"theme_default";
        [[NSUserDefaults standardUserDefaults] setObject:themeId forKey:@"MyYasoundTheme"];
    }
    
    Theme* theme = [[Theme alloc] initWithThemeId:themeId];
    _settingsThemeTitle.text = NSLocalizedString(themeId, nil);
    [_settingsThemeImage setImage:theme.icon];
    [theme release];
    
    [_settingsThemeImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsThemeImage.layer setBorderWidth: 1];    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    // update GUI
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
    // update keywords
    NSArray* keywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundKeywords"];

    if (_keywords)
        [_keywords release];
    
    if ([keywords count] == 0)
    {
        _keywords = [NSString stringWithString:NSLocalizedString(@"SettingsView_keywords_empty", nil)];
    }
    else
    {
        _keywords = [NSString stringWithString:[keywords objectAtIndex:0]];
        for (int i = 1; i < [keywords count]; i++)
        {
            NSString* aKeyword = [keywords objectAtIndex:i];
            _keywords = [_keywords stringByAppendingFormat:@" - %@", aKeyword];
        }
    }
    
    [_keywords retain];
    [_tableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == SECTION_CONFIG)
        return NSLocalizedString(@"SettingsView_section_config", nil);
    
    if (section == SECTION_IMAGE)
        return NSLocalizedString(@"SettingsView_section_image", nil);
    
    if (section == SECTION_THEME)
        return NSLocalizedString(@"SettingsView_section_theme", nil);
    
    return nil;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_CONFIG)
        return 3;
    
    if (section == SECTION_IMAGE)
        return 1;

    if (section == SECTION_THEME)
        return 1;

    return 0;
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if (tableView == _settingsTableView)
//        [self willDisplayCellInSettingsTableView:cell forRowAtIndexPath:indexPath];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_TITLE))
        return _settingsTitleCell;
    
    if ((indexPath.section == SECTION_IMAGE) && (indexPath.row == ROW_IMAGE))
        return _settingsImageCell;
    
    if ((indexPath.section == SECTION_THEME) && (indexPath.row == ROW_THEME))
        return _settingsThemeCell;

    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SettingsView_row_genre_label", nil);
        NSString* style = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundGenre"];
        cell.detailTextLabel.text = NSLocalizedString(style, nil);
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SettingsView_row_keywords_label", nil);
        cell.detailTextLabel.text = _keywords;
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
//        _settingsGenreLabel.textColor = [UIColor whiteColor];
        [self openStyleSelector];
        return;
    }

    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        KeywordsViewController* view = [[KeywordsViewController alloc] init];
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_back", nil) style:UIBarButtonItemStylePlain target:view action:@selector(onBack:)];
        [[self navigationItem] setBackBarButtonItem: backBtn];
        [backBtn release];

        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    
    if ((indexPath.section == SECTION_IMAGE) && (indexPath.row == ROW_IMAGE))
    {
        _settingsImageLabel.textColor = [UIColor whiteColor];
        UIImagePickerController* picker =  [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        
        //      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        //      {
        //        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //      }
        //      else
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentModalViewController:picker animated:YES];
        return;
    }
    
    
    if ((indexPath.section == SECTION_THEME) && (indexPath.row == ROW_THEME))
    {
//        _settingsThemeTitle.textColor = [UIColor whiteColor];
        [self openThemeSelector];
        return;
    }
}







#pragma mark - StyleSelectorDelegate


- (void)openStyleSelector
{
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (void)didSelectStyle:(NSString*)style
{
    NSLog(@"didSelectStyle : %@", style);
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:style forKey:@"MyYasoundGenre"];
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_CONFIG_GENRE inSection:SECTION_CONFIG]];
    cell.detailTextLabel.text = NSLocalizedString(style, nil);
    
    /*
     [self.navigationController dismissModalViewControllerAnimated:YES];
     
     
     _settingsGenreTitle.text = NSLocalizedString(style, nil);
     */
}

- (void)cancelSelectStyle
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark - ThemeSelectorDelegate

- (void)openThemeSelector
{
    ThemeSelectorViewController* view = [[ThemeSelectorViewController alloc] initWithNibName:@"ThemeSelectorViewController" bundle:nil];
    view.delegate = self;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)themeSelected:(NSString*)themeId
{
    /*
     [self.navigationController popViewControllerAnimated:YES];
     
     // set user defaults
     [[NSUserDefaults standardUserDefaults] setObject:themeId forKey:@"MyYasoundTheme"];
     
     // set GUI cell for selected theme
     Theme* theme = [[Theme alloc] initWithThemeId:themeId];
     _settingsThemeTitle.text = NSLocalizedString(themeId, nil);
     [_settingsThemeImage setImage:theme.icon];
     [theme release];
     
     // set the global theme object
     [Theme setTheme:themeId];
     */
}

- (void)themeSelectionCanceled
{
    [self.navigationController popViewControllerAnimated:YES];
}







#pragma mark - ImagePicker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker
{
    [self dismissModalViewControllerAnimated:YES];
    [Picker release];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /*
     _settingsImageImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
     [self dismissModalViewControllerAnimated:YES];
     [Picker release];
     */
}





#pragma mark - IBActions

- (IBAction) onNext:(id)sender
{
    PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_back", nil) style:UIBarButtonItemStylePlain target:view action:@selector(onBack:)];
    [[self navigationItem] setBackBarButtonItem: backBtn];
    [backBtn release];
    
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}







@end