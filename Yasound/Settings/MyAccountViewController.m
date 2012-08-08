//
//  MyAccountViewController.m
//  Yasound
//
//  Created by neywen on 07/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MyAccountViewController.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"


@interface MyAccountViewController ()

@end

@implementation MyAccountViewController

@synthesize tableview;
@synthesize user;
@synthesize username;
@synthesize userImage;
@synthesize city;



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

        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
        self.userImage = [[WebImageView alloc] initWithImageAtURL:url];
        self.userImage.frame = sheet.frame;
        [cell addSubview:self.userImage];

        sheet = [[Theme theme] stylesheetForKey:@"TableView.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* value = [sheet makeLabel];
        [cell addSubview:value];
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
        cell.detailTextLabel.text = NSLocalizedString(@"M", nil);
        
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
        
        self.city.text = @"";
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
        cell.detailTextLabel.text = @"";
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
        controller.date = [NSDate date];
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
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}












#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _changed = YES;

    [textField resignFirstResponder];
    
    return YES;
}








#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked:(TopBarItemId)itemId
{
    if (_changed || _imageChanged)
        [self save];
    
    if (itemId == TopBarItemBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else if (itemId == TopBarItemNotif)
    {
        
    }
    
    else if (itemId == TopBarItemNowPlaying)
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}



#pragma mark - DateViewDelegate

- (void)takeNewDate:(NSDate *)newDate
{
    _changed = YES;

    //myObject.date = newDate;
}

- (UINavigationController *)navController
{
    return self.navigationController;
}


#pragma mark - ImagePicker

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
}



//- (void)updateUser:(User*)user target:(id)target action:(SEL)selector; // - (void)didUpdateUser:(ASIHTTPRequest*)req success:(BOOL)success
//- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector;


- (void)save
{
    // empty the cache for radios (to let the change on name / genre appear)
    [[YasoundDataCache main] clearRadiosAll];
    
    [[YasoundDataProvider main] updateUser:self.user target:self action:@selector(didUpdateUser:success:)];
}

- (void)didUpdateUser:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (_imageChanged)
    {
        [[YasoundDataProvider main] setPicture:self.userImage.image forUser:self.user target:self action:@selector(onRadioImageUpdate:info:)];
    }
    else
        [self onRadioImageUpdate:nil info:nil];
    
}


// TODO  : cleaner les types et objets (radio => user)

- (void)onRadioImageUpdate:(NSString*)msg info:(NSDictionary*)info
{
    DLog(@"onRadioImageUpdate info %@", info);
    
    // be sure to get updated radio (with correct picture)
    [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(receivedUserRadioAfterPictureUpdate:withInfo:)];
}

// TODO  : cleaner les types et objets (radio => user)

- (void)receivedUserRadioAfterPictureUpdate:(Radio*)r withInfo:(NSDictionary*)info
{
//    [ActivityAlertView close];
    
    // clean image cache
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:r.picture];
    [[YasoundDataCacheImageManager main] clearItem:imageURL];
    
    imageURL = [[YasoundDataProvider main] urlForPicture:r.creator.picture];
    [[YasoundDataCacheImageManager main] clearItem:imageURL];
    
    
//    if (_wizard)
//    {
//        // call root to launch the Radio
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil];
//    }
//    else
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }

    [self.navigationController popViewControllerAnimated:YES];
}



@end
