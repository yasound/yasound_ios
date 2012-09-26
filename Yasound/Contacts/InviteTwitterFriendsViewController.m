//
//  InviteTwitterFriendsViewController.m
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "InviteTwitterFriendsViewController.h"
#import "YasoundDataProvider.h"
#import "YasoundAppDelegate.h"

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
    [[YasoundDataProvider main] inviteTwitterFriendsWithTarget:self action:@selector(friendsInvited:success:)];
    return NO;
}

- (void)friendsInvited:(ASIHTTPRequest*)req success:(BOOL)success
{
    NSDictionary* resp = [req responseDict];
    NSNumber* ok = [resp valueForKey:@"success"];
    if (!success || ok == nil || [ok boolValue] == NO)
    {
        DLog(@"twitter friends invitation failed   error: %@", [resp valueForKey:@"error"]);
    }
    
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
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
