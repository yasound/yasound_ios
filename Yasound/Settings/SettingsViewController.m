//
//  SettingsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SettingsViewController.h"
#import "StyleSelectorViewController.h"
#import "Theme.h"
#import "KeywordsViewController.h"
#import "PlaylistsViewController.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"
#import "AccountFacebookViewController.h"
#import "AccountTwitterViewController.h"
#import "AccountYasoundViewController.h"
#import "NotificationViewController.h"
#import "YasoundDataCache.h"
#import "YasoundDataCacheImage.h"

#define NB_SECTIONS 4



#define SECTION_CONFIG 0
#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_GENRE 1
#define ROW_CONFIG_KEYWORDS 2

#define SECTION_IMAGE 1
#define ROW_IMAGE 0

#define SECTION_ACCOUNTS 2
#define SECTION_ACCOUNTS_NB_ROWS 3
#define ROW_ACCOUNTS_FACEBOOK 0
#define ROW_ACCOUNTS_TWITTER 1
#define ROW_ACCOUNTS_YASOUND 2

#define SECTION_NOTIFS 3
#define SECTION_NOTIFS_NB_ROWS 1
#define ROW_NOTIFS 0

#ifdef DEBUG
#undef NB_SECTIONS
#define NB_SECTIONS 5
#define SECTION_CACHE 4
#define SECTION_CACHE_NB_ROWS 1
#define ROW_CACHE 0
#endif




@implementation SettingsViewController


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard radio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _wizard = wizard;
        _myRadio = radio;
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

//        NSMutableArray* items = [NSMutableArray arrayWithArray:_toolbar.items];
//        [items removeObjectAtIndex:0]; // remove back button

        NSMutableArray* items = [[NSMutableArray alloc] init];

        
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];

        UIBarButtonItem* space=  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];

        //        [items addObject:_backBtn];
        [items addObject:backBtn];
        [items addObject:space];
        [items addObject:_nextBtn];
        
        [_toolbar setItems:items animated:NO];
//        [space release];
    }


    _settingsTitleLabel.text = NSLocalizedString(@"SettingsView_row_title_label", nil);
    
    // set radio title
    NSString* radioTitle = _myRadio.name;
    if ((radioTitle == nil) || (radioTitle.length == 0))
        radioTitle = [NSString stringWithFormat:@"%@'s Yasound", [[UIDevice currentDevice] name]];
    _settingsTitleTextField.text = radioTitle;
    _settingsTitleTextField.delegate = self;
    

    // image gui
    _settingsImageLabel.text = NSLocalizedString(@"SettingsView_row_image_label", nil);
    [_settingsImageImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsImageImage.layer setBorderWidth: 1];    
    _settingsImageChanged = NO;
    
    // set radio image
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:_myRadio.picture];
    if (imageURL != nil)
        [_settingsImageImage setUrl:imageURL];    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    // update GUI
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
    // update keywords
    NSArray* keywords = [_myRadio tagsArray];

    if (_keywords)
        [_keywords release];
    
    if ((keywords == nil) || ([keywords count] == 0))
    {
        _keywords = [NSString stringWithString:NSLocalizedString(@"SettingsView_keywords_empty", nil)];
    }
    else
    {
        _keywords = [NSString stringWithString:[keywords objectAtIndex:0]];
        for (int i = 1; i < [keywords count]; i++)
        {
            NSString* aKeyword = [keywords objectAtIndex:i];
            _keywords = [_keywords stringByAppendingFormat:@", %@", aKeyword];
        }
    }
    
    [_keywords retain];
    [_tableView reloadData];
    
    
    if ([ActivityAlertView isRunning])
        [ActivityAlertView close];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
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
    return NB_SECTIONS;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_CONFIG)
        return 3;
    
    if (section == SECTION_IMAGE)
        return 1;

    if (section == SECTION_ACCOUNTS)
        return SECTION_ACCOUNTS_NB_ROWS;

    if (section == SECTION_NOTIFS)
        return SECTION_NOTIFS_NB_ROWS;

#ifdef DEBUG
    if (section == SECTION_CACHE)
        return SECTION_CACHE_NB_ROWS;
#endif

    return 0;
}






- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 22;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if (section == SECTION_CONFIG)
        title = NSLocalizedString(@"SettingsView_section_config", nil);
    
    else if (section == SECTION_IMAGE)
        title = NSLocalizedString(@"SettingsView_section_image", nil);
    
    else if (section == SECTION_ACCOUNTS)
        title = NSLocalizedString(@"SettingsView_section_accounts", nil);

    else if (section == SECTION_NOTIFS)
        title = NSLocalizedString(@"SettingsView_section_notifs", nil);

#ifdef DEBUG
    else if (section == SECTION_CACHE)
        title = @"Cache";
#endif

    
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
    NSInteger nbRows;
    if (indexPath.section == SECTION_CONFIG)
        nbRows =  3;
    
    else if (indexPath.section == SECTION_IMAGE)
        nbRows =  1;
    
    else if (indexPath.section == SECTION_ACCOUNTS)
        nbRows =  SECTION_ACCOUNTS_NB_ROWS;

    else if (indexPath.section == SECTION_NOTIFS)
        nbRows =  SECTION_NOTIFS_NB_ROWS;

#ifdef DEBUG
    else if (indexPath.section == SECTION_CACHE)
        nbRows =  SECTION_CACHE_NB_ROWS;
#endif
    
    if (nbRows == 1)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == 0)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == (nbRows -1))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
        cell.backgroundView = view;
        [view release];
    }
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
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SettingsView_row_genre_label", nil);
        NSString* style = _myRadio.genre;
        cell.detailTextLabel.text = NSLocalizedString(style, nil);
        
        cell.detailTextLabel.textColor = [UIColor colorWithRed:182.f/255.f green:212.f/255.f blue:1 alpha:1];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SettingsView_row_keywords_label", nil);
        cell.detailTextLabel.text = _keywords;

        cell.detailTextLabel.textColor = [UIColor colorWithRed:182.f/255.f green:212.f/255.f blue:1 alpha:1];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    else if (indexPath.section == SECTION_ACCOUNTS)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
        if (indexPath.row == ROW_ACCOUNTS_FACEBOOK)
        {
            cell.textLabel.text = @"Facebook";  
            cell.detailTextLabel.text = @"";
        }
        else if (indexPath.row == ROW_ACCOUNTS_TWITTER)
        {
            cell.textLabel.text = @"Twitter";
            cell.detailTextLabel.text = @"";
        }
        else if (indexPath.row == ROW_ACCOUNTS_YASOUND)
        {
            cell.textLabel.text = @"Yasound";
            cell.detailTextLabel.text = @"";
        }
    }
    
    else if (indexPath.section == SECTION_NOTIFS)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SettingsView_section_notifs", nil);
        
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.text = @"";
    }

#ifdef DEBUG
    else if (indexPath.section == SECTION_CACHE)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Empty the cache";
        
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.text = @"";
    }
#endif
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        _changed = YES;
        [self openStyleSelector];
        return;
    }

    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        _changed = YES;
        KeywordsViewController* view = [[KeywordsViewController alloc] initWithNibName:@"KeywordsViewController" bundle:nil radio:_myRadio];
        
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    
    if ((indexPath.section == SECTION_IMAGE) && (indexPath.row == ROW_IMAGE))
    {
        _changed = YES;

        [self pickImageDialog];
        return;
    }
    
    
    else if (indexPath.section == SECTION_ACCOUNTS)
    {
        if (indexPath.row == ROW_ACCOUNTS_FACEBOOK)
        {
            AccountFacebookViewController* view = [[AccountFacebookViewController alloc] initWithNibName:@"AccountFacebookViewController" bundle:nil];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_ACCOUNTS_TWITTER)
        {
            AccountTwitterViewController* view = [[AccountTwitterViewController alloc] initWithNibName:@"AccountTwitterViewController" bundle:nil];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_ACCOUNTS_YASOUND)
        {
            AccountYasoundViewController* view = [[AccountYasoundViewController alloc] initWithNibName:@"AccountYasoundViewController" bundle:nil];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
    
    else if (indexPath.section == SECTION_NOTIFS)
    {
        NotificationViewController* view = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }

#ifdef DEBUG
    else if (indexPath.section == SECTION_CACHE)
    {
        _cacheQuery = [[UIActionSheet alloc] initWithTitle:@"Empty the cache?" delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Empty the cache", nil];
        _cacheQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [_cacheQuery showInView:self.view];
        [_cacheQuery release];
    }
#endif
    
}




#pragma mark - KeywordsDelegate
//
//- (void)onKeywordsChanged:(NSArray*)keywords
//{
//    if (_keywords)
//        [_keywords release];
//    
//    if ((keywords == nil) || ([keywords count] == 0))
//    {
//        _keywords = [NSString stringWithString:NSLocalizedString(@"SettingsView_keywords_empty", nil)];
//    }
//    else
//    {
//        _keywords = [NSString stringWithString:[keywords objectAtIndex:0]];
//        for (int i = 1; i < [keywords count]; i++)
//        {
//            NSString* aKeyword = [keywords objectAtIndex:i];
//            _keywords = [_keywords stringByAppendingFormat:@", %@", aKeyword];
//        }
//    }
//    
//    [_keywords retain];
//    
//    [_tableView reloadData];
//
//}



#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    
    return FALSE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _changed = YES;
    
    // set radio title
    _myRadio.name = textField.text;
    
    NSLog(@"Radio name has changed for '%@'", _myRadio.name);
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
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil currentStyle:_myRadio.genre target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (void)didSelectStyle:(NSString*)style
{
    NSLog(@"didSelectStyle : %@", style);
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_CONFIG_GENRE inSection:SECTION_CONFIG]];
    cell.detailTextLabel.text = NSLocalizedString(style, nil);
    
    // set radio genre
    _myRadio.genre = style;
    
    /*
     [self.navigationController dismissModalViewControllerAnimated:YES];
     _settingsGenreTitle.text = NSLocalizedString(style, nil);
     */
}

- (void)closeSelectStyleController
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
    
    // wait for "save" action to upload the image to the server
    _settingsImageChanged = YES;
}





#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_wizard)
    {
        // call root to launch the Radio
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CANCEL_WIZARD object:nil];
        return;
    }
    
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
      UIImagePickerControllerSourceType sourceType;
        
        if (buttonIndex == 0)
            sourceType = UIImagePickerControllerSourceTypeCamera;
        else if (buttonIndex == 1)
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      else
        return;
      
        [_pickImageQuery release];
        _pickImageQuery = nil;

      UIImagePickerController* picker =  [[UIImagePickerController alloc] init];
      picker.delegate = self;
      picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
        
        return;
    }
    
#ifdef DEBUG
    if (actionSheet == _cacheQuery)
    {
        // be careful!
        if (buttonIndex == 0)
        {
            [[YasoundDataCache main] clearRadiosAll];
            [[YasoundDataCache main] clearCurrentSongs];
            [[YasoundDataCache main] clearFriends];
            
            [[YasoundDataCacheImageManager main] clear];

            [ActivityAlertView showWithTitle:@"ok" closeAfterTimeInterval:1];
        }
        return;
    }
#endif
}






- (void) save
{
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SettingsView_submit_title", nil)];

    // empty the cache for radios (to let the change on name / genre appear)
    [[YasoundDataCache main] clearRadiosAll];

    NSLog(@"send update request for radio '%@'", _myRadio.name);
    
    [[YasoundDataProvider main] updateRadio:_myRadio target:self action:@selector(onRadioUpdated:info:)];
}

- (void)onRadioUpdated:(Radio*)radio info:(NSDictionary*)info
{
    NSLog(@"onRadioUpdated '%@', info %@", radio.name, info);
    
    if (_settingsImageChanged)
    {
        [[YasoundDataProvider main] setPicture:_settingsImageImage.image forRadio:radio target:self action:@selector(onRadioImageUpdate:info:)];
    }
    else
        [self onRadioImageUpdate:nil info:nil];

}

- (void)onRadioImageUpdate:(NSString*)msg info:(NSDictionary*)info
{
    NSLog(@"onRadioImageUpdate info %@", info);
    
  // be sure to get updated radio (with correct picture)
  [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(receivedUserRadioAfterPictureUpdate:withInfo:)];
}

- (void)receivedUserRadioAfterPictureUpdate:(Radio*)r withInfo:(NSDictionary*)info
{
  [ActivityAlertView close];

    // clean image cache
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:r.picture];
    [[YasoundDataCacheImageManager main] clearItem:imageURL];

    imageURL = [[YasoundDataProvider main] urlForPicture:r.creator.picture];
    [[YasoundDataCacheImageManager main] clearItem:imageURL];

  
  if (_wizard)
  {
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil]; 
  }
  else
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
}






@end
