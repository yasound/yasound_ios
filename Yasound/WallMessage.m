//
//  WallMessage.m
//  Yasound
//
//  Created by Sébastien Métrot on 11/2/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallMessage.h"

@implementation WallMessage
@synthesize image;
@synthesize title;
@synthesize message;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [image release];
  image = nil;
  [title release];
  title = nil;
  [message release];
  message = nil;
  [self setImage:nil];
  [self setTitle:nil];
  [self setMessage:nil];
  [self setImage:nil];
  [self setTitle:nil];
  [self setMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
  [image release];
  [title release];
  [message release];
  [image release];
  [title release];
  [message release];
  [image release];
  [title release];
  [message release];
  [super dealloc];
}
@end
