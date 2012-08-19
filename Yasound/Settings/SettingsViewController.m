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

#define NB_SECTIONS 3


#define SECTION_CONFIG 0
#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_GENRE 1
#define ROW_CONFIG_KEYWORDS 2

#define SECTION_IMAGE 1
#define ROW_IMAGE 0

#define SECTION_PROG 2
#define ROW_PROG 0
#define ROW_SHOWS 1





@implementation SettingsViewController

@synthesize radio;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil forRadio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = radio;
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
    

    _settingsTitleLabel.text = NSLocalizedString(@"Settings.radio.title.label", nil);
    
    // set radio title
    NSString* radioTitle = self.radio.name;
    if ((radioTitle == nil) || (radioTitle.length == 0))
        radioTitle = [NSString stringWithFormat:@"%@'s Yasound", [[UIDevice currentDevice] name]];
    _settingsTitleTextField.text = radioTitle;
    _settingsTitleTextField.delegate = self;
    

    // image gui
    _settingsImageLabel.text = NSLocalizedString(@"Settings.radio.image.label", nil);
    [_settingsImageImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsImageImage.layer setBorderWidth: 1];    
    _settingsImageChanged = NO;
    
    // set radio image
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    if (imageURL != nil)
        [_settingsImageImage setUrl:imageURL];    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    // update GUI
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
    // update keywords
    NSArray* keywords = [self.radio tagsArray];

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

    if (section == SECTION_PROG)
        return 2;


    return 0;
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
//


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == SECTION_CONFIG)
//        title = NSLocalizedString(@"Settings.section.config", nil);
//    
//    else if (section == SECTION_IMAGE)
//        title = NSLocalizedString(@"Settings.section.image", nil);
//    
//    else if (section == SECTION_ACCOUNTS)
//        title = NSLocalizedString(@"Settings.section.accounts", nil);
//
//    else if (section == SECTION_NOTIFS)
//        title = NSLocalizedString(@"Settings.section.notifs", nil);
//
//#ifdef DEBUG
//    else if (section == SECTION_CACHE)
//        title = @"Cache";
//#endif
//
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}
//    





//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    NSInteger nbRows;
//    if (indexPath.section == SECTION_CONFIG)
//        nbRows =  3;
//    
//    else if (indexPath.section == SECTION_IMAGE)
//        nbRows =  1;
//    
//    else if (indexPath.section == SECTION_ACCOUNTS)
//        nbRows =  SECTION_ACCOUNTS_NB_ROWS;
//
//    else if (indexPath.section == SECTION_NOTIFS)
//        nbRows =  SECTION_NOTIFS_NB_ROWS;
//
//#ifdef DEBUG
//    else if (indexPath.section == SECTION_CACHE)
//        nbRows =  SECTION_CACHE_NB_ROWS;
//#endif
//    
//    if (nbRows == 1)
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else if (indexPath.row == 0)
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else if (indexPath.row == (nbRows -1))
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//}


//
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    UIView* view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor redColor];
//    cell.backgroundView = view;
//}
//


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SECTION_CONFIG)
        return NSLocalizedString(@"Settings", nil);
    else if(section == SECTION_IMAGE)
        return NSLocalizedString(@"Picture", nil);
    else
        return NSLocalizedString(@"Programming", nil);
}

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
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:88.f/255.f green:107.f/255.f blue:119.f/255.f alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.genre.label", nil);
        NSString* style = self.radio.genre;
        cell.detailTextLabel.text = NSLocalizedString(style, nil);
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_KEYWORDS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.keywords.label", nil);
        cell.detailTextLabel.text = _keywords;

    }
    else if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_PROG))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.prog.label", nil);
        cell.detailTextLabel.text = @"";
    }
    else if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_SHOWS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Settings.shows.label", nil);
        cell.detailTextLabel.text = @"";
    }
    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
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

    if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_PROG))
    {
        //LBDEBUG
        NSLog(@"CALL PROG FOR RADIO :%@", self.radio.name);
        
        ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:self.radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }

    if ((indexPath.section == SECTION_PROG) && (indexPath.row == ROW_SHOWS))
    {        
        SchedulingViewController* view = [[SchedulingViewController alloc] initWithNibName:@"SchedulingViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    
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

- (IBAction)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onSave:(id)sender
{
    [self save];
    [self.navigationController popViewControllerAnimated:YES];
}




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
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Settings.submit", nil)];

    // empty the cache for radios (to let the change on name / genre appear)
    [[YasoundDataCache main] clearRadiosAll];

    DLog(@"send update request for radio '%@'", self.radio.name);
    
    [[YasoundDataProvider main] updateRadio:self.radio target:self action:@selector(onRadioUpdated:info:)];
}

- (void)onRadioUpdated:(Radio*)radio info:(NSDictionary*)info
{
    DLog(@"onRadioUpdated '%@', info %@", radio.name, info);
    
    if (_settingsImageChanged)
    {
        [[YasoundDataProvider main] setPicture:_settingsImageImage.image forRadio:radio target:self action:@selector(onRadioImageUpdate:info:)];
    }
    else
        [self onRadioImageUpdate:nil info:nil];

}

- (void)onRadioImageUpdate:(NSString*)msg info:(NSDictionary*)info
{
    DLog(@"onRadioImageUpdate info %@", info);
    
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

  
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - TopBarSaveOrCancelDelegate

- (void)topBarCancel
{

}

- (void)topBarSave
{
    [self save];
}



@end
