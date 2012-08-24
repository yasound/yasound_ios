//
//  PurchaseViewController.m
//  Yasound
//
//  Created by neywen on 23/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "PurchaseViewController.h"
#import "Theme.h"
#import "ActivityAlertView.h"
#import "YasoundDataProvider.h"
#import "Subscription.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

@synthesize subscriptions;
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
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
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

    self.productDetailsList    = [[NSMutableArray alloc] init];
    self.productIdentifierList = [[NSMutableArray alloc] init];
    
    [ActivityAlertView showWithTitle:nil];

    [[YasoundDataProvider main] subscriptionsWithTarget:self action:@selector(onSubscriptionsReceived:succes:)];
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



- (void)onSubscriptionsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{

    if (!success)
    {
        [ActivityAlertView close];
        
        DLog(@"onSubscriptionsReceived : failed!");

        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.subscriptions.error.title", nil) message:NSLocalizedString(@"Purchase.subscriptions.error.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[Subscription class]];
    self.subscriptions = container.objects;
    
    if ((self.subscriptions == nil) || (self.subscriptions.count == 0))
    {
        [ActivityAlertView close];
        DLog(@"onSubscriptionsReceived : failed!");

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.subscriptions.error.title", nil) message:NSLocalizedString(@"Purchase.subscriptions.error.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];

        return;
    }

    // fill the product identifiers list
    for (Subscription* sub in self.subscriptions)
    {
        [self.productIdentifierList addObject:sub.sku];
    }
    
    DLog(@"onSubscriptionsReceived : product ids : %@", self.productIdentifierList);
    
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifierList]];
    request.delegate = self;
    [request start];

}



-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [ActivityAlertView close];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    NSString* productId = [self.productIdentifierList objectAtIndex:indexPath.row];
    
    SKPayment* payment = [SKPayment paymentWithProductIdentifier:productId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [SKPaymentQueue canMakePayments];
}












- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    DLog(@"complete Transaction = %@", transaction.description);
    
    //[self recordTransaction: transaction];
    //[self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    DLog(@"restore Transaction = %@", transaction.description);

    //[self recordTransaction: transaction];
    //[self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    DLog(@"failed Transaction = %@", transaction.description);

    if (transaction.error != SKErrorPaymentCancelled)
    {
        UIAlertView *successesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.transaction.error.title", nil)
                                                                 message:NSLocalizedString(@"Purchase.transaction.error.message", nil)
                                                                delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [successesAlert show];
        [successesAlert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}



@end
