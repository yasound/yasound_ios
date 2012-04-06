//
//  NotificationViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationManager.h"
#import "NotificationViewCell.h"
#import "YasoundDataProvider.h"



@interface NotificationViewController ()

@end

@implementation NotificationViewController










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

    _titleItem.title = NSLocalizedString(@"NotificationView_title", nil);
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
  [[YasoundDataProvider main] apnsPreferencesWithTarget:self action:@selector(receivedAPNsPreferences:withInfo:)];
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



- (void)receivedAPNsPreferences:(APNsPreferences*)prefs withInfo:(NSDictionary*)info
{
  if (!prefs)
    return;
  
  [[NotificationManager main] updateWithAPNsPreferences:prefs];
  [_tableView reloadData];
}










#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [NotificationManager main].notifications.count;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger nbRows = [NotificationManager main].notifications.count;
    
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"CellNotif";

    NSArray* keys = [[NotificationManager main].notifications allKeys];
    NSString* notifIdentifier = [keys objectAtIndex:indexPath.row];
                                 
    NotificationViewCell* cell = (NotificationViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[NotificationViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier notifIdentifier:notifIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
        [cell update:notifIdentifier];
    
    return cell;
}















- (IBAction)onBack:(id)sender
{
  APNsPreferences* prefs = [[NotificationManager main] APNsPreferences];
  [[YasoundDataProvider main] setApnsPreferences:prefs target:nil action:nil];
  
    [self.navigationController popViewControllerAnimated:YES];
}

@end
