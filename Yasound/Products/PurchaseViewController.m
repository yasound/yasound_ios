//
//  PurchaseViewController.m
//  Yasound
//
//  Created by neywen on 23/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "PurchaseViewController.h"
#import "Theme.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

@synthesize productIdentifierList;
@synthesize productDetailsList;
@synthesize tableview;


static NSString* CellIdentifier = @"PurchaseTableViewCell";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.cellLoader = [UINib nibWithNibName:CellIdentifier bundle:[NSBundle mainBundle]];
    }
    return self;
}


-(void)dealloc
{
    [self.cellLoader release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    productDetailsList    = [[NSMutableArray alloc] init];
    productIdentifierList = [[NSMutableArray alloc] init];
    
    [productIdentifierList addObject:@"yaHD1m"];
    [productIdentifierList addObject:@"yaHD1y"];
    [productIdentifierList addObject:@"yaHD1ysp"];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifierList]];
    
    request.delegate = self;
    [request start];
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






-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self.productDetailsList addObjectsFromArray: response.products];
    [self.tableview reloadData];
}

-(void)requestDidFinish:(SKRequest *)request
{
    [request release];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
}






#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productDetailsList count];
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
    SKProduct* product = [self.productDetailsList objectAtIndex:indexPath.row];

    PurchaseTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }
    
    [cell updateForProduct:product];

    
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: GenericTableIdentifier];
//
//    if (cell == nil)
//    {
//        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier: GenericTableIdentifier] autorelease];
//    }
//    
//    if (indexPath.row == 1)
//        cell.imageView.image = [UIImage imageNamed:@"productIconBest.png"];
//    else
//        cell.imageView.image = [UIImage imageNamed:@"productIconDefault.png"];
//    
//    NSUInteger row = [indexPath row];
//    SKProduct *thisProduct = [productDetailsList objectAtIndex:row];
//    [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@", thisProduct.localizedTitle, thisProduct.price]];
//    
    return cell;
}




@end
