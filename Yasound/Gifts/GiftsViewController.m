//
//  GiftsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "GiftsViewController.h"
#import "TopBar.h"
#import "AudioStreamManager.h"
#import "Gift.h"
#import "YasoundDataProvider.h"
#import "GiftCell.h"

#define SECTION_COUNT 1
#define SECTION_GIFTS 0


@interface GiftsViewController ()

@end

@implementation GiftsViewController

@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTabSelected:TabIndexGifts];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    
    // ask for gifts
    [[YasoundDataProvider main] giftsWithTarget:self action:@selector(onGiftsReceived:success:)];
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



- (void)onGiftsReceived:(ASIHTTPRequest*)request success:(BOOL)succeeded
{
    if (!succeeded)
        return;
    
    self.gifts = [request responseObjectsWithClass:[Gift class]].objects;
    [self.tableView reloadData];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_GIFTS)
        if (!self.gifts)
            return 0;
        return [self.gifts count];
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gift* gift = [self.gifts objectAtIndex:indexPath.row];
    static NSString* cellIdentifier = @"GiftTableViewCell";
    
    if (indexPath.section == SECTION_GIFTS)
    {
        GiftCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        }
        cell.gift = gift;
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gift* gift = [self.gifts objectAtIndex:indexPath.row];
    if (![gift canBeWon])
        return;
    [gift doAction];
}


#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}

@end
