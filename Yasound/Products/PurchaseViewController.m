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
#import "TopBar.h"
#import "PlaylistMoulinor.h"
#import "Base64.h"


@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

@synthesize subscriptions;
@synthesize productIdentifierList;
@synthesize productDetailsList;
@synthesize tableview;

@synthesize cellProfil;
@synthesize cellProfilImage;
@synthesize cellProfilHdImage;
@synthesize cellProfilLabel;



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
    
    
    // init profil cell
    NSURL* url = [[YasoundDataProvider main] urlForPicture:[YasoundDataProvider main].user.picture];
    [self.cellProfilImage setUrl:url];
        
    // get list of acquired sevices
    [[YasoundDataProvider main] servicesWithTarget:self action:@selector(onSubscriptionsReceived:success:)];
    
    
    [ActivityAlertView showWithTitle:nil];

    [[YasoundDataProvider main] subscriptionsWithTarget:self action:@selector(onSubscriptionsReceived:success:)];
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
        DLog(@"%@", [sub toString]);
        
        NSString* sku = sub.sku;
        
//        //LBDEBUG
//        if ([sku isEqualToString:@"com.yasound.yasoundtest.inappHD1m"])
//            sku = @"com.yasound.yasound.inappHD1m";
//        else if ([sku isEqualToString:@"com.yasound.yasoundtest.inappHD1y"])
//            sku = @"com.yasound.yasound.inappHD1y";
//        else if ([sku isEqualToString:@"com.yasound.yasoundtest.inappHD1ysp"])
//            sku = @"com.yasound.yasound.inappHD1ysp";
        
        [self.productIdentifierList addObject:sku];
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
    
    if ((self.productDetailsList == nil) || (self.productDetailsList.count == 0))
    {
        [ActivityAlertView close];
        DLog(@"productsRequest didReceiveResponse : failed!");
        DLog(@"using the identifiers : %@", self.productIdentifierList);
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.subscriptions.error.title", nil) message:NSLocalizedString(@"Purchase.subscriptions.error.apple.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    return [self.productDetailsList count];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    cell.backgroundView = view;
    [view autorelease];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0))
        return self.cellProfil;
    
    
    Subscription* sub = [self.subscriptions objectAtIndex:indexPath.row];
    SKProduct* product = [self.productDetailsList objectAtIndex:indexPath.row];

    PurchaseTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }
    
    [cell updateForProduct:product withSubscription:sub];
    
    if (sub.isEnabled)
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    else
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    Subscription* sub = [self.subscriptions objectAtIndex:indexPath.row];
    SKProduct* product = [self.productDetailsList objectAtIndex:indexPath.row];
    NSString* productId = [self.productIdentifierList objectAtIndex:indexPath.row];

    if (!sub.isEnabled)
        return;
    
//    if ([sub isCurrent])
//    {
//        UIAlertView *successesAlert = [[UIAlertView alloc] initWithTitle:product.description                                       
//                                                                 message:NSLocalizedString(@"Purchase.transaction.current.message", nil)
//                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [successesAlert show];
//        [successesAlert release];
//        return;
//    }

    [ActivityAlertView showWithTitle:nil];
    
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
    NSString* sku = transaction.payment.productIdentifier;

    DLog(@"complete Transaction : %@   for productIdentifier : %@", transaction.description, sku);

    NSString* encodedReceipt = [Base64 encodeBase64WithData:transaction.transactionReceipt];

    
    //LBDEBUG
//    NSData* emailData = [encodedReceipt dataUsingEncoding:NSASCIIStringEncoding];
//    [[PlaylistMoulinor main] emailData:emailData to:@"jerome@yasound.com" mimetype:@"application/octet-stream" filename:@"yasound_inapp_apple_receipt.bin" controller:self];
    
    [[YasoundDataProvider main] subscriptionComplete:sku withBase64Receipt:encodedReceipt target:self action:@selector(onTransactionRecorded:info:)];
        
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
}


- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    DLog(@"restore Transaction = %@", transaction.description);
    
    [ActivityAlertView close];

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    DLog(@"failed Transaction  '%@'   error '%@' ", transaction.description, transaction.error);

    [ActivityAlertView close];

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *successesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.transaction.error.title", nil)
                                                                 message:NSLocalizedString(@"Purchase.transaction.error.message", nil)
                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [successesAlert show];
        [successesAlert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}





//- (void)onTransactionRecorded:(ASIHTTPRequest*)req success:(BOOL)success
- (void)onTransactionRecorded:(NSString*)obj1 info:(NSDictionary*)info
{
    DLog(@"onTransactionRecorded obj1 class : '%@'!", [obj1 class]);
    DLog(@"onTransactionRecorded info : '%@'!", info);
    
    BOOL success = NO;
    NSNumber* succeeded = [info objectForKey:@"succeeded"];
    if (succeeded)
        success = [succeeded boolValue];
    

    if (!success)
    {
        DLog(@"onTransactionRecorded FAILED!");
        UIAlertView *successesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.transaction.record.error.title", nil)
                                                                 message:NSLocalizedString(@"Purchase.transaction.record.error.message", nil)
                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [successesAlert show];
        [successesAlert release];
        return;
    }

    DLog(@"onTransactionRecorded success!");

    UIAlertView *successesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase.transaction.completed.title", nil)
                                                             message:NSLocalizedString(@"Purchase.transaction.completed.message", nil)
                                                            delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [successesAlert show];
    [successesAlert release];
    
    
    // refresh data and gui
    self.productDetailsList    = [[NSMutableArray alloc] init];
    self.productIdentifierList = [[NSMutableArray alloc] init];
    self.subscriptions = nil;
    
    [[YasoundDataProvider main] subscriptionsWithTarget:self action:@selector(onSubscriptionsReceived:success:)];
    
}











#pragma mark - TopBarDelegate

- (BOOL)topBarItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemHd)
    {
        return NO;
    }
    
    
    return YES;
}




@end
