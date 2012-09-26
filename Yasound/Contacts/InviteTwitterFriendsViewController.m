//
//  InviteTwitterFriendsViewController.m
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "InviteTwitterFriendsViewController.h"

@interface InviteTwitterFriendsViewController ()

@end

@implementation InviteTwitterFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label.text = NSLocalizedString(@"InviteTwitterFriends.label", nil);
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

#pragma mark - Top bar delegate

- (BOOL)topBarSave
{
    return YES;
    //[APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)topBarCancel
{
    return YES;
}

- (BOOL)shouldShowActionButton
{
    return YES;
}

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"ContactListPicker.SendButton", nil);
}

- (NSString*)titleForCancelButton
{
    return NSLocalizedString(@"ContactListPicker.CancelButton", nil);
}

- (NSString*)topBarModalTitle
{
    return NSLocalizedString(@"ContactListPickerTitle", nil);
}


@end
