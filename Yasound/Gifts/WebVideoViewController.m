//
//  WebVideoViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebVideoViewController.h"
#import "YasoundAppDelegate.h"

@implementation WebVideoViewController

@synthesize videoUrl;


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil withVideoUrl:(NSURL*)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.videoUrl = url;
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
    [_webview release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = self.title;
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _webview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    NSString* htmlString = @"<html margin-left:0 margin-top:0>\n\
    <head>\n\
    <script type=\"text/javascript\"></script>\n\
    </head>\n\
    <body>\n\
    <iframe src=\"http://www.youtube.com/embed/YkFaWMN6Rsg\"\n\
    width=\"320px\" height=\"240px\" frameborder=\"0\">\n\
    </iframe>\n\
    </body>\n\
    </html>";
    
    htmlString = [NSString stringWithFormat:htmlString, self.videoUrl];
    
    DLog(@"%@", htmlString);

    [_webview loadHTMLString:htmlString baseURL:nil];
    
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
    return YES;
}










#pragma mark - TopBarModalDelegate

- (BOOL)shouldShowActionButton {
    return NO;
}

- (NSString*)topBarTitle
{
    return self.title ;
}

- (NSString*)titleForCancelButton {
    
    return NSLocalizedString(@"Navigation.close", nil);
}







@end
