//
//  BLYViewController.m
//  BitlySample
//
//  Created by tracy pesin on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BLYViewController.h"

#import "BLYBitlyTextViewExample.h"
#import "BLYBitlyURLShortenerExample.h"

@implementation BLYViewController

@synthesize bitlyTweetSheet;
@synthesize popoverController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Bitly SDK Examples";
    bitlyTweetSheet = [[BitlyTweetSheet alloc] init];
    bitlyTweetSheet.delegate = self;
    
    bitlyTweetSheet.initialText = @"Lookee here: http://en.wikipedia.org/wiki/Tetraodontidae";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark BitlyTweetSheetDelegate
- (void)bitlyTweetSheetDidSendTweet:(BitlyTweetSheet *)viewController {
    NSLog(@"Sent tweet!");
    
    //if displaying the tweetSheet as a modal
    [self dismissModalViewControllerAnimated:YES];
    
    //if displaying the tweetSheet as a popover
    [self.popoverController dismissPopoverAnimated:YES];
}

- (void)bitlyTweetSheet:(BitlyTweetSheet *)viewController didFailWithError:(NSError *)error {
    NSLog(@"Tweet failed with error: %@", [error localizedDescription]);
}

- (void)bitlyTweetSheetUserCancelledTweet:(BitlyTweetSheet *)viewController {
    NSLog(@"User cancelled tweet");
    
    //if displaying the tweetSheet as a modal
    [self dismissModalViewControllerAnimated:YES];
    
    //if displaying the tweetSheet as a popover
    [self.popoverController dismissPopoverAnimated:YES];
}

- (void)bitlyTweetSheet:(BitlyTweetSheet *)viewController textDidChange:(NSString *)text {
    NSLog(@"TweetSheet text changed to: %@", text );
}
/*These two methods are only relevant when on iOS5+ since they refer to the Accounts framework. */
- (void)bitlyTweetSheetAccountAccessDenied:(BitlyTweetSheet *)viewController {
    NSLog(@"Access to the user's twitter account was denied");
}
- (void)bitlyTweetSheetNoAccountsAvailable:(BitlyTweetSheet *)viewController {
    UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:@"Account error" 
                              message:@"No twitter accounts available. Please sign in to your account in the Settings app."
                              delegate:nil 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil];
    [alertView show];
    
     //if displaying the tweetSheet as a modal
    [self dismissModalViewControllerAnimated:YES];

    //if displaying the tweetSheet as a popover
    [self.popoverController dismissPopoverAnimated:YES];
}


- (IBAction)displayBitlyTweetSheet:(id)sender {
    [bitlyTweetSheet presentModallyFromViewController:self];
}

- (IBAction)displayBitlyTweetSheetAsPopover:(id)sender {
    self.popoverController = self.bitlyTweetSheet.popoverController;
    [self.popoverController presentPopoverFromRect:((UIView *)sender).frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:NO];
}

- (IBAction)bitlyTextViewExample:(id)sender {
    BLYBitlyTextViewExample *viewController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[BLYBitlyTextViewExample alloc] initWithNibName:@"BLYBitlyTextViewExample_iPhone" bundle:nil]; 
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        viewController = [[BLYBitlyTextViewExample alloc] initWithNibName:@"BLYBitlyTextViewExample_iPad" bundle:nil]; 
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)bitlyURLShortenerExample:(id)sender {
    BLYBitlyURLShortenerExample *viewController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[BLYBitlyURLShortenerExample alloc] initWithNibName:@"BLYBitlyURLShortenerExample_iPhone" bundle:nil]; 
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        viewController = [[BLYBitlyURLShortenerExample alloc] initWithNibName:@"BLYBitlyURLShortenerExample_iPad" bundle:nil]; 
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
