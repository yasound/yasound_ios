//
//  WebPageViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebPageViewController.h"
#import "YasoundAppDelegate.h"

@implementation WebPageViewController

@synthesize url;


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil withUrl:(NSURL*)url andTitle:(NSString*)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.url = url;
        self.title = title;
    }
    
    return self;
}







- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = self.title;
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _webview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];

    NSURL* url = [NSURL URLWithString:[APPDELEGATE getServerUrlWith:@"legal/eula.html"]];
    NSURLRequest* requestObj = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:requestObj];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}










- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}









@end
