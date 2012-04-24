//
//  BLYBitlyURLShortenerExample.m
//  BitlySample
//
//  Created by tracy pesin on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BLYBitlyURLShortenerExample.h"


@interface BLYBitlyURLShortenerExample ()
@property(nonatomic, strong) BitlyURLShortener *bitly;
@end

@implementation BLYBitlyURLShortenerExample
@synthesize linkLabel;
@synthesize bitly;


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
    [self setLinkLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)shortenLink:(id)sender {
    bitly = [[BitlyURLShortener alloc] init];
    bitly.delegate = self;
    [bitly shortenLinksInText:[linkLabel text]];
    
}

- (void)bitlyURLShortenerDidShortenText:(BitlyURLShortener *)shortener oldText:(NSString *)oldText text:(NSString *)text linkDictionary:(NSDictionary *)dictionary {
    self.linkLabel.text = text;
}

- (void)bitlyURLShortener:(BitlyURLShortener *)shortener 
        didFailForLongURL:(NSURL *)longURL 
               statusCode:(NSInteger)statusCode
               statusText:(NSString *)statusText {
    NSLog(@"Shortening failed for link %@: status code: %d, status text: %@", 
          [longURL absoluteString], statusCode, statusText);
}


@end
