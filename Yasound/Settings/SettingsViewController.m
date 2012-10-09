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
#import "ProgrammingViewController.h"
#import "SchedulingViewController.h"
#import "YasoundAppDelegate.h"

#define NB_SECTIONS 2


#define SECTION_CONFIG 0
#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_GENRE 1
#define ROW_CONFIG_KEYWORDS 2

#define SECTION_IMAGE 1
#define ROW_IMAGE 0

//#define SECTION_PROG 2
//#define ROW_PROG 0
//#define ROW_SHOWS 1





@implementation SettingsViewController

@synthesize radio;
@synthesize radioBackup;
@synthesize createMode;
@synthesize topbar;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil forRadio:(Radio*)radio createMode:(BOOL)createMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = radio;
        self.radioBackup = radio;
        self.createMode = createMode;
    }
    
    return self;
}

//- (id) createWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self)
//    {
//        self.radio = nil;
//        self.createMode = YES;
//    }
//    
//    return self;
//}
//
//



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
    
    _settingsTitleLabel.text = NSLocalizedString(@"Settings.radio.title.label", nil);
    _settingsTitleTextField.placeholder = NSLocalizedString(@"Settings.radio.title.placeholder", nil);

    if (self.createMode) {
        [self.topbar hideCancelButton];
    }
    else {
        
    }
    
    _settingsTitleTextField.delegate = self;
    

    // image gui
    _settingsImageLabel.text = NSLocalizedString(@"Settings.radio.image.label", nil);
    _settingsImageChanged = NO;
    
    [self update];
    
}



- (void)update
{
    // set radio title
    if (self.radio && !self.createMode) {
        _settingsTitleTextField.text = self.radio.name;
    }
    

    
    
    // set radio image
    NSURL* imageURL = nil;
    if (self.radio)
        imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    if (imageURL != nil)
        [_settingsImageImage setUrl:imageURL];
    
    
    
    
    // update keywords
    NSArray* keywords = nil;
    if (self.radio)
        keywords = [self.radio tagsArray];
    
    if (_keywords)
        [_keywords release];
    
    if ((keywords == nil) || ([keywords count] == 0))
    {
        _keywords = [NSString stringWithString:NSLocalizedString(@"Settings.keywords.empty", nil)];
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

}

- (void) viewWillAppear:(BOOL)animated
{
    // update GUI
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
    [self update];
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

//    if (section == SECTION_PROG)
//        return 2;


    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if(section == SECTION_CONFIG)
        title = NSLocalizedString(@"Settings.section.settings", nil);
    else if(section == SECTION_IMAGE)
        title = NSLocalizedString(@"Settings.section.picture", nil);
    else
        title = NSLocalizedString(@"Settings.section.programming", nil);
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)];
    view.backgroundColor = [UIColor clearColor];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.viewForHeader" retainStylesheet:YES overwriteStylesheet:YES error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}






- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger nbRows = [tableView numberOfRowsInSection:indexPath.section];
    
    if (nbRows == 1)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowSingle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else if (indexPath.row == 0)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowFirst" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else if (indexPath.row == (nbRows -1))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowLast" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowInter" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_TITLE))
    {
        return _settingsTitleCell;
    }
    
    if ((indexPath.section == SECTION_IMAGE) && (indexPath.row == ROW_IMAGE))
    {
        return _settingsImageCell;
    }
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:88.f/255.f green:107.f/255.f blue:119.f/255.f alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.genre.label", nil);
        NSString* style = nil;
        if (self.radio)
            style = self.radio.genre;
        cell.detailTextLabel.text = NSLocalizedString(style, nil);
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.keywords.label", nil);
        cell.detailTextLabel.text = _keywords;

    }
//    else if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_PROG))
//    {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.textLabel.text = NSLocalizedString(@"Settings.prog.label", nil);
//        cell.detailTextLabel.text = @"";
//    }
//    else if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_SHOWS))
//    {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.textLabel.text = NSLocalizedString(@"Settings.shows.label", nil);
//        cell.detailTextLabel.text = @"";
//        
////        //LBDEBUG TEMPORARLY CODE
//        cell.textLabel.alpha = 0.5;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
//    //LBDEBUG TEMPORARLY CODE
//    if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_SHOWS))
//    {
//        return;
//    }

    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        _changed = YES;
        [self openStyleSelector];
        return;
    }

    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        _changed = YES;
        KeywordsViewController* view = [[KeywordsViewController alloc] initWithNibName:@"KeywordsViewController" bundle:nil radio:self.radio];
        
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

//    if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_PROG))
//    {
//        //LBDEBUG
//        NSLog(@"CALL PROG FOR RADIO :%@", self.radio.name);
//        
//        ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//        return;
//    }

//    if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_SHOWS))
//    {        
//        SchedulingViewController* view = [[SchedulingViewController alloc] initWithNibName:@"SchedulingViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//        return;
//    }
    
    
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
//        _keywords = [NSString stringWithString:NSLocalizedString(@"Settings.keywords.empty", nil)];
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
    self.radio.name = textField.text;
    
    DLog(@"Radio name has changed for '%@'", self.radio.name);
}



- (void)pickImageDialog
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _pickImageQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Settings.pickImage.cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Settings.pickImage.image", nil), 
                                     NSLocalizedString(@"Settings.pickImage.camera", nil), nil];
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
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil currentStyle:self.radio.genre target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (void)didSelectStyle:(NSString*)style
{
    DLog(@"didSelectStyle : %@", style);
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_CONFIG_GENRE inSection:SECTION_CONFIG]];
    cell.detailTextLabel.text = NSLocalizedString(style, nil);
    
    // set radio genre
    self.radio.genre = style;
    
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
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
    [Picker release];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
    [Picker release];
    
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (image == nil)
        return;
    if (![image isKindOfClass:[UIImage class]])
        return;
    

    
    _settingsImageImage.image = image;
    
    // wait for "save" action to upload the image to the server
    _settingsImageChanged = YES;
}





#pragma mark - IBActions

//- (IBAction)onCancel:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//
//- (IBAction)onSave:(id)sender
//{
//    [self save];
//}
//



#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];

    
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
    
}






- (void) save
{
    self.radio.name = _settingsTitleTextField.text;
    
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Settings.submit", nil)];

    // empty the cache for radios (to let the change on name / genre appear)
    [[YasoundDataCache main] clearRadiosAll];

    DLog(@"send update request for radio '%@'", self.radio.name);
    
    DLog(@"settings clicked for radio : %@", [self.radio toString]);

    
    [[YasoundDataProvider main] updateRadio:self.radio target:self action:@selector(onRadioUpdated:info:)];
}

- (void)onRadioUpdated:(Radio*)radio info:(NSDictionary*)info
{
    DLog(@"onRadioUpdated '%@', info %@", radio.name, info);
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    BOOL success = [nb boolValue];
    
    if (!success)
    {
        [ActivityAlertView close];
        DLog(@"radio update failed.");
        
        // backup
        self.radio = self.radioBackup;
        [self update];
        [_tableView reloadData];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings.update.failed.title", nil) message:NSLocalizedString(@"Settings.update.failed.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    self.radio = radio;
    
    
    //LBDEBUG : TODO :l voir le bug de changement de photo
    if (_settingsImageChanged)
    {
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
        DLog(@"receivedUserRadioAfterPictureUpdate BEFORE pictureUrl %@", imageURL);
        
        [[YasoundDataProvider main] setPicture:_settingsImageImage.image forRadio:self.radio target:self action:@selector(onRadioImageUpdate:info:)];
    }
    else
        [self onRadioImageUpdate:nil info:nil];

}

- (void)onRadioImageUpdate:(NSString*)msg info:(NSDictionary*)info
{
    DLog(@"onRadioImageUpdate info %@", info);
    
  // be sure to get updated radio (with correct picture)
  [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receivedUserRadioAfterPictureUpdate:withInfo:)];
}

- (void)receivedUserRadioAfterPictureUpdate:(Radio*)r withInfo:(NSDictionary*)info
{
  [ActivityAlertView close];
    
    self.radio = r;

    // clean image cache
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    DLog(@"receivedUserRadioAfterPictureUpdate AFTER pictureUrl %@", imageURL);

    [[YasoundDataCacheImageManager main] clearItem:imageURL];

//    imageURL = [[YasoundDataProvider main] urlForPicture:r.creator.picture];
//    [[YasoundDataCacheImageManager main] clearItem:imageURL];
    
    

  
    // if the settings have been called through a "radio creation" process, go directly to the new radio's wall.
    if (self.createMode)
    {
        DLog(@"radio '%@' created. Go to the Wall now.", self.radio.name);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:self.radio];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REFRESH_GUI object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}












#pragma mark - TopBarSaveOrCancelDelegate

- (BOOL)topBarCancel
{
    return YES;
}

- (BOOL)topBarSave
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* title = [_settingsTitleTextField.text stringByTrimmingCharactersInSet:space];
    if (title.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings.radio.title.missing.title", nil) message:NSLocalizedString(@"Settings.radio.title.missing.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }

    [self save];
    return NO;
}



@end
