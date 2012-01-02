//
//  LegalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LegalViewController.h"

@implementation LegalViewController

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _wizard = wizard;
        _legalText = NSLocalizedString(@"LegalView_legal_text", nil);
        [_legalText retain];
        _legalFont = [UIFont systemFontOfSize:10];
        [_legalFont retain];

        // compute the size of the text => will allow to update the cell's height dynamically
        CGSize suggestedSize = [_legalText sizeWithFont:_legalFont constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        _legalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, suggestedSize.height)];
        _legalLabel.text = _legalText;
        _legalLabel.font = _legalFont;
        [_legalLabel setNumberOfLines:0];            
        [_legalLabel retain];
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
    [_legalLabel release];
    [_legalText release];
    [_legalFont release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"LegalView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);

    // next button in toolbar
    //LBDEBUG
//    if (_wizard)
//    {
        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];
        NSMutableArray* items = [NSMutableArray arrayWithArray:_toolbar.items];
        [items addObject:_nextBtn];
        [_toolbar setItems:items animated:NO];
    
        _nextBtn.enabled = NO;
//    }
    
    
    _cellAgreementLabel.text = NSLocalizedString(@"LegalView_agreement_label", nil);
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


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    if (tableView == _settingsTableView)
//        return [self titleInSettingsTableViewForHeaderInSection:section];
//    
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == 0))
        return 44;
    
    return _legalLabel.frame.size.height;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
//    if ((indexPath.section == 0) && (indexPath.row == 0))
//    {
//        cell.backgroundView.backgroundColor = [UIColor clearColor];
//        cell.contentView.backgroundColor = [UIColor clearColor];
//        cell.backgroundView.opaque = NO;
//        cell.contentView.opaque = NO;
//    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == 1) && (indexPath.row == 0))
        return _cellAgreement;
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
    
    _legalLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:_legalLabel];
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}







#pragma mark - IBActions

//UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SettingsView_saveOrCancel_title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_saveOrCancel_save", nil), nil];
//
//popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//[popupQuery showInView:self.view];
//[popupQuery release];


- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onNext:(id)sender
{
}


-(IBAction)onSwitch:(id)sender 
{
    UISwitch* switchControl = sender;
    
    if(switchControl.on)
    {
        _nextBtn.enabled = YES;
    }
    else
    {
        _nextBtn.enabled = NO;
    }
}



#pragma mark - ActionSheet Delegate


//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
//{
//    if (buttonIndex == 0)
//        [self save];
//    else
//        [self.navigationController popViewControllerAnimated:YES];        
//}












@end
