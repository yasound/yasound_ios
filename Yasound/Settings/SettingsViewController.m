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
#import "ActivityAlertView.h"


#define SECTION_CONFIG 0
#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_GENRE 1
#define ROW_CONFIG_KEYWORDS 2

#define SECTION_IMAGE 1
#define ROW_IMAGE 0

#define SECTION_THEME 2
#define ROW_THEME 0





@implementation SettingsViewController


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard radio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _wizard = wizard;
        _radio = radio;
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
    
    _titleLabel.text = NSLocalizedString(@"SettingsView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    if (_wizard)
    {
        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];
        NSMutableArray* items = [NSMutableArray arrayWithArray:_toolbar.items];
        [items removeObjectAtIndex:0]; // remove back button
        [items addObject:_nextBtn];
        [_toolbar setItems:items animated:NO];
    }


    _settingsTitleLabel.text = NSLocalizedString(@"SettingsView_row_title_label", nil);
    
    // set radio title
    NSString* radioTitle = _radio.name;
    if ((radioTitle == nil) || (radioTitle.length == 0))
        radioTitle = [NSString stringWithFormat:@"%@'s Yasound", [[UIDevice currentDevice] name]];
    _settingsTitleTextField.text = radioTitle;
    _settingsTitleTextField.delegate = self;
    

    // image gui
    _settingsImageLabel.text = NSLocalizedString(@"SettingsView_row_image_label", nil);
    [_settingsImageImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsImageImage.layer setBorderWidth: 1];    
    
    // set radio image
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:_radio.picture];
    if (imageURL != nil)
        [_settingsImageImage setUrl:imageURL];
    
    // theme 
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
    
    
    if ([ActivityAlertView isRunning])
        [ActivityAlertView close];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (!_wizard)
        self.navigationController.navigationBarHidden = YES;
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
    //LBDEBUG
//    return 3;
    return 2;
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
        NSString* style = _radio.genre;

        //LBDEBUG TODO CLEAN
        // [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundGenre"];
        
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
    _changed = YES;
    
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
        [self pickImageDialog];
        return;
    }
    
    
    if ((indexPath.section == SECTION_THEME) && (indexPath.row == ROW_THEME))
    {
//        _settingsThemeTitle.textColor = [UIColor whiteColor];
        [self openThemeSelector];
        return;
    }
}






#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    _changed = YES;
    
    // set radio title
    _radio.name = textField.text;
    
    return FALSE;
}





- (void)pickImageDialog
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _pickImageQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_pickImage_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_pickImage_image", nil), 
                                     NSLocalizedString(@"SettingsView_pickImage_camera", nil), nil];
        _pickImageQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [_pickImageQuery showInView:self.view];
    }
    else
    {
        UIImagePickerController* picker =  [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
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
    
    // set radio genre
    _radio.genre = style;
    
    
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
    [self dismissModalViewControllerAnimated:YES];
    [Picker release];
    
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (image == nil)
        return;
    if (![image isKindOfClass:[UIImage class]])
        return;
    
    [_settingsImageImage setImage:image];
}





#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    // save or cancel
    if (!_wizard && _changed)
    {
        _saveQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SettingsView_saveOrCancel_title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_saveOrCancel_save", nil), NSLocalizedString(@"SettingsView_saveOrCancel_dontsave", nil), nil];
        
        _saveQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [_saveQuery showInView:self.view];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)onNext:(id)sender
{
    [self save];
}




#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    if (actionSheet == _saveQuery)
    {
        if (buttonIndex == 0)
            [self save];
        else if (buttonIndex == 1)
            [self.navigationController popViewControllerAnimated:YES];        
        
        [_saveQuery release];
        _saveQuery = nil;
        return;
    }
    
    
    if (actionSheet == _pickImageQuery)
    {
        UIImagePickerController* picker =  [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        if (buttonIndex == 0)
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        else if (buttonIndex == 1)
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
        [_pickImageQuery release];
        _pickImageQuery = nil;

        [self presentModalViewController:picker animated:YES];
        
        return;
    }
}






- (void) save
{
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SettingsView_submit_title", nil)];

    
    //LBDEBUG TODO CLEAN
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
    
    [[YasoundDataProvider main] updateRadio:_radio target:self action:@selector(onRadioUpdated:)];
}

- (void)onRadioUpdated:(id)obj
{
    [ActivityAlertView close];
    
     if (_wizard)
     {
        PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:YES];
        [self.navigationController pushViewController:view animated:YES];
        [view release];    
     }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//LBDEBUG TODO CLEAN
//- (void)onFakeSubmitAction:(NSTimer*)timer
//{
//    [ActivityAlertView close];
//    
//    PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:YES];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];    
//}







@end
