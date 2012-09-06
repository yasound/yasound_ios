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

#define SECTION_COUNT 1
#define SECTION_GIFTS 0


@interface GiftsViewController ()

@end

@implementation GiftsViewController

@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTabSelected:TabIndexGifts];
    
    // ask for gifts
    //#TODO: send request to get gifts
    [[YasoundDataProvider main] giftsWithTarget:self action:@selector(onGiftsReceived:success:)];
    
    NSString *stringURL = @"music:";
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
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
            return 5; //#TODO: 5 for test purpose, valid value is 0
        return [self.gifts count];
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"GiftTableViewCell";
    
    if (indexPath.section == SECTION_GIFTS)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"Gift %d", indexPath.row];
        return cell;
    }
    
    return nil;
}



#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}

@end
