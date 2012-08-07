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
#import "WebImageView.h"

@interface MyAccountViewController ()

@end

@implementation MyAccountViewController

@synthesize tableview;



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
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];

    if ((indexPath.section == SECTION_INFOS) && (indexPath.row == ROW_USERNAME))
    {
        label.text = NSLocalizedString(@"MyAccount.username.label", nil);

        sheet = [[Theme theme] stylesheetForKey:@"TableView.textfield" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UITextField* textfield = [[UITextField alloc] initWithFrame:sheet.frame];
        textfield.placeholder =  NSLocalizedString(@"MyAccount.username.placeholder", nil);
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.delegate = self;
        
        [sheet applyToLabel:textfield class:@"default"];

        
        [cell addSubview:textfield];
        
        textfield.text = self.user.name;
    }
    

    else if ((indexPath.section == SECTION_INFOS) && (indexPath.row == ROW_PICTURE))
    {
        label.text = NSLocalizedString(@"MyAccount.picture.label", nil);
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
        WebImageView* image = [[WebImageView alloc] initWithImageAtURL:url];
        image.frame = sheet.frame;
        [cell addSubview:image];

        sheet = [[Theme theme] stylesheetForKey:@"TableView.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImage* mask = [sheet makeImage];
        [cell addSubview:mask];
    }

    
    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_AGE))
    {
        label.text = NSLocalizedString(@"MyAccount.age.label", nil);

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* value = [sheet makeLabel];
        [cell addSubview:value];
    }
    
    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_SEXE))
    {
        label.text = NSLocalizedString(@"MyAccount.sexe.label", nil);
    }

    else if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_CITY))
    {
        label.text = NSLocalizedString(@"MyAccount.city.label", nil);
    }
    
    else if ((indexPath.section == SECTION_BIO) && (indexPath.row == ROW_BIO))
    {
        label.text = NSLocalizedString(@"MyAccount.bio.label", nil);
    }
    
    

    [cell addSubview:label];
    
    
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_PROFIL) && (indexPath.row == ROW_AGE))
    {
        DateViewController *controller = [[DateViewController alloc] init];
        controller.delegate = self;
        controller.date = [NSDate date];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}












#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}








#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked:(TopBarItemId)itemId
{
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
    //myObject.date = newDate;
}

- (UINavigationController *)navController
{
    return self.navigationController;
}



@end
