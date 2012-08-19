//
//  MyAccountViewController.m
//  Yasound
//
//  Created by neywen on 07/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MyAccountViewController.h"
#import "AudioStreamManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "ActivityAlertView.h"

@interface MyAccountViewController ()

@end

@implementation MyAccountViewController

@synthesize tableview;
@synthesize user;
@synthesize username;
@synthesize userImage;
@synthesize city;
@synthesize age;

@synthesize itemId;


enum MyAccountDescription
{
    SECTION_INFOS,
    SECTION_PROFIL,
    SECTION_BIO,
    NB_SECTIONS
};

enum SectionInfos
{
    ROW_USERNAME,
    ROW_PICTURE,
    INFOS_NB_ROWS
};

enum SectionProfil
{
    ROW_AGE,
    ROW_SEXE,
    ROW_CITY,
    PROFIL_NB_ROWS
};

enum SectionBio
{
    ROW_BIO,
    BIO_NB_ROWS
};




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.user = [YasoundDataProvider main].user;
        _imageChanged = NO;
        _changed = NO;
        
        self.itemId = TopBarItemNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    if (section == SECTION_INFOS)
        return INFOS_NB_ROWS;
    if (section == SECTION_PROFIL)
        return PROFIL_NB_ROWS;
    if (section == SECTION_BIO)
        return BIO_NB_ROWS;
    return 0;
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
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    if ((indexPath.section == SECTION_INFOS) && (indexPath.row == ROW_USERNAME))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyAccount.username.label", nil);
        [cell addSubview:label];

        sheet = [[Theme theme] stylesheetForKey:@"TableView.textfield" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.username = [[UITextField alloc] initWithFrame:sheet.frame];
        self.username.placeholder =  NSLocalizedString(@"MyAccount.username.placeholder", nil);
        self.username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.username.delegate = self;
        
        [sheet applyToLabel:self.username class:@"default"];

        //LBDEBUG
        //NSLog(@"%.2f  x %.2f", cell.frame.size.width, cell.frame.size.height);
        
        [cell addSubview:self.username];
        
        self.username.text = self.user.name;
        
    }
    

    else if ((indexPath.section == SECTION_INFOS) && (indexPath.row == ROW_PICTURE))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyAccount.picture.label", nil);
        [cell addSubview:label];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        
        sheet = [[Theme theme] stylesheetForKey:@"MyAccount.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
        self.userImage = [[WebImageView alloc] initWithImageAtURL:url];
        self.userImage.frame = sheet.frame;
        [cell addSubview:self.userImage];

        sheet = [[Theme theme] stylesheetForKey:@"MyAccount.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImage* mask = [sheet makeImage];
        [cell addSubview:mask];
    }

    
    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_AGE))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyAccount.age.label", nil);
        [cell addSubview:label];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        NSString* age = [self.user.age stringValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MyAccount.age.value", nil), [self.user.age integerValue]];
        if (age.length == 0)
            cell.detailTextLabel.text = @"-";

        sheet = [[Theme theme] stylesheetForKey:@"TableView.value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.detailTextLabel.textColor = [sheet fontTextColor];

        //        sheet = [[Theme theme] stylesheetForKey:@"TableView.value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        self.age = [sheet makeLabel];
//        self.age.text = [self.user.age stringValue];
//        if (self.age.text.length == 0)
//            self.age.text = @"-";
//        [cell addSubview:self.age];
    }
    
    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_SEXE))
    {
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        UILabel* label = [sheet makeLabel];
//        label.text = NSLocalizedString(@"MyAccount.sexe.label", nil);
//        [cell addSubview:label];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.textLabel.text = NSLocalizedString(@"MyAccount.sexe.label", nil);
        NSString* gender = self.user.gender;
        if (!gender)
            gender=  @"-";
        cell.detailTextLabel.text = NSLocalizedString(gender, nil);
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.detailTextLabel.textColor = [sheet fontTextColor];

        
    }

    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_CITY))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyAccount.city.label", nil);
        [cell addSubview:label];
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textfield" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.city = [[UITextField alloc] initWithFrame:sheet.frame];
        self.city.placeholder =  NSLocalizedString(@"MyAccount.city.placeholder", nil);
        self.city.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.city.delegate = self;
        
        [sheet applyToLabel:self.city class:@"default"];
        
        
        [cell addSubview:self.city];
        
        self.city.text = self.user.city;
    }
    
    else if ((indexPath.section == SECTION_BIO) && (indexPath.row == ROW_BIO))
    {
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        UILabel* label = [sheet makeLabel];
//        label.text = NSLocalizedString(@"MyAccount.bio.label", nil);
//        [cell addSubview:label];
//        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;        

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.textLabel.text = NSLocalizedString(@"MyAccount.bio.label", nil);
        cell.detailTextLabel.text = self.user.bio_text;
    }
    
    

    
    
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_AGE))
    {
        DateViewController *controller = [[DateViewController alloc] init];
        controller.delegate = self;
        controller.date = self.user.birthday;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    else if ((indexPath.section == SECTION_INFOS) && (indexPath.row == ROW_PICTURE))
    {
        [self pickImageDialog];
    }
    
    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_SEXE))
    {
        GenderPickerViewController* view = [[GenderPickerViewController alloc] initWithNibName:@"GenderPickerViewController" bundle:nil currentItem:@"M" target:self];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController presentModalViewController:view animated:YES];    
    }
    
    else if ((indexPath.section == SECTION_BIO) && (indexPath.row == ROW_BIO))
    {
        BioViewController* view = [[BioViewController alloc] initWithNibName:@"BioViewController" bundle:nil forUser:self.user target:self];
        view.delegate = self;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}












#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.city)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        self.tableview.contentOffset = CGPointMake(0, 88);
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _changed = YES;

    [textField resignFirstResponder];
    
    if (textField == self.username)
    {
        self.user.name = self.username.text;
    }
    else if (textField == self.city)
    {
        self.user.city = textField.text;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        self.tableview.contentOffset = CGPointMake(0, 0);
        [UIView commitAnimations];        
    }
    
    return YES;
}








#pragma mark - TopBarDelegate

- (BOOL)topBarItemClicked:(TopBarItemId)itemId
{
    if (_changed || _imageChanged)
    {
        self.itemId = itemId;
        [self save];
        return NO;
    }
   
    return YES;
}



#pragma mark - DateViewDelegate

- (void)takeNewDate:(NSDate *)newDate
{
    _changed = YES;
    self.user.birthday = newDate;
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:newDate toDate:now options:0];
    NSInteger age = [ageComponents year];
    self.user.age = [NSNumber numberWithInt:age];

    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_AGE inSection:SECTION_PROFIL]];

    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MyAccount.age.value", nil), age];
}

- (UINavigationController *)navController
{
    return self.navigationController;
}


#pragma mark - ImagePicker

- (void)pickImageDialog
{
    [self.username resignFirstResponder];
    [self.city resignFirstResponder];
    
    
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
    
    [self.userImage setImage:image];
    
    // wait for "save" action to upload the image to the server
    _imageChanged = YES;
    _changed = YES;
}



#pragma mark - GenderPickerDelegate

- (void)genderDidSelect:(NSString*)gender
{
    _changed = YES;

    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_SEXE inSection:SECTION_PROFIL]];
    cell.detailTextLabel.text = NSLocalizedString(gender, nil);
    self.user.gender = gender;
}

- (UINavigationController *)genderNavController
{
    return self.navigationController;
}



#pragma mark - BioDelegate

- (void)bioDidReturn:(NSString*)bio
{
    _changed = YES;
    
    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_BIO inSection:SECTION_BIO]];
    cell.detailTextLabel.text = NSLocalizedString(bio, nil); 
    self.user.bio_text = bio;
}








#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
    
    
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











#pragma mark - save


- (void)save
{
    [ActivityAlertView showWithTitle:nil];

    [[YasoundDataProvider main] updateUser:self.user target:self action:@selector(didUpdateUser:success:)];
}

- (void)didUpdateUser:(ASIHTTPRequest*)req success:(BOOL)success
{
    // update the YasoundDataProvider's user
    //LBDEBUG
  //  [YasoundDataProvider main].user = self.user;
    
    if (_imageChanged)
    {
        [[YasoundDataProvider main] setPicture:self.userImage.image forUser:self.user target:self action:@selector(onUserImageUpdate:info:)];
    }
    else
        [self onUserImageUpdate:nil info:nil];
    
}

- (void)onUserImageUpdate:(NSString*)msg info:(NSDictionary*)info
{
    DLog(@"onUserImageUpdate info %@", info);
    
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    [[YasoundDataCacheImageManager main] clearItem:imageURL];

    // reload user
    [[YasoundDataProvider main] reloadUserWithUserData:nil withTarget:self action:@selector(didReloadUser:info:)];
}

- (void)didReloadUser:(User*)u info:(id)info
{
    self.user = u;
    
    [ActivityAlertView close];
    
    if (self.itemId != TopBarItemNone)
        [self.topbar runItem:self.itemId];
}












@end
