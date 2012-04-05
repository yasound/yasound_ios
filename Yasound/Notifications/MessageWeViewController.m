//
//  MessageWeViewController.m
//  Yasound
//
//  Created by matthieu campion on 4/5/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MessageWeViewController.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"

@implementation MessageWeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString*)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      _url = url;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
//  self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
//  _webView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
  _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
  
  NSURL* url = [NSURL URLWithString:_url];
  NSURLRequest* urlReqest = [NSURLRequest requestWithURL:url];
  [_webView loadRequest:urlReqest];
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


- (IBAction)onNowPlayingClicked:(id)sender
{
  RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}

- (IBAction)onMenuBarItemClicked:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
