//
//  SchedulingViewController.m
//  Yasound
//
//  Created by neywen on 11/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SchedulingViewController.h"
#import "YasoundDataProvider.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>
#import "ShowViewController.h"

@interface SchedulingViewController ()

@end

@implementation SchedulingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(YaRadio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = radio;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBar showAddItemWithTarget:self action:@selector(onAdd:)];
    
    [[YasoundDataProvider main] showsForRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        BOOL success = (error == nil) && (status == 200) && (response != nil);
        if (!success)
        {
            DLog(@"SchedulingViewController::showsReceived failed");
            return;
        }
        
        Container* container = [response jsonToContainer:[Show class]];
        self.shows = container.objects;
        [self.tableview reloadData];
    }];
    
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


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shows.count;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    cell.backgroundView = view;
    [view autorelease];
}


 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifierShow = @"cellShow";
    
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifierShow];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifierShow];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor colorWithRed:166.f/255.f green:177.f/255.f blue:185.f/255.f alpha:1];
        cell.textLabel.layer.shadowColor = [UIColor blackColor];
        cell.textLabel.layer.shadowOffset = CGSizeMake(0, -1);
        cell.textLabel.layer.shadowRadius = 0.5;
        cell.textLabel.layer.shadowOpacity = 0.75;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* di = [sheet makeImage];
        [cell addSubview:di];
        [di release];
    }
    
    return cell;
}






#pragma mark - TopBarDelegate

- (void)onAdd:(id)sender
{
        ShowViewController* view = [[ShowViewController alloc] initWithNibName:@"ShowViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
}




@end
