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
    [[YasoundDataProvider main] inviteTwitterFriendsWithTarget:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"invite twitter friends error: %d - %@", error.code, error.domain);
        }
        if (status != 200)
        {
            DLog(@"invite twitter friends error: response status %d", status);
        }
        NSDictionary* dict = [response jsonToDictionary];
        if (dict == nil)
        {
            DLog(@"invite twitter friends error: cannot parse response %@", response);
        }
        NSNumber* ok = [dict valueForKey:@"success"];
        if (ok == nil)
        {
            DLog(@"invite twitter friends error: bad response %@", response);
        }
        if ([ok boolValue] == NO)
        {
            DLog(@"invite twitter friends failed: error %@", [dict valueForKey:@"error"]);
        }
        [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
    }];
    return NO;
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
