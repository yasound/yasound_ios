//
//  RefreshIndicator.m
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RefreshIndicator.h"
#import "Theme.h"

@implementation RefreshIndicator

@synthesize label;
@synthesize height;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RefreshIndicator.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        
        self.backgroundColor = [UIColor redColor];
        self.hidden = YES;
        
        self.height = frame.size.height;
        self.status = eStatusClosed;


    }
    
    return self;
}


//- (void)dealloc
//{
//    [super dealloc];
//}
//

- (void)pull {
    
    self.label.text = NSLocalizedString(@"RefreshIndicator.label.pulled", nil);

    self.status = eStatusPulled;
    self.hidden = NO;
    
    NSLog(@"     refresh pull");
}


- (void)open {
    
    self.label.text = NSLocalizedString(@"RefreshIndicator.label.opened", nil);
    
    self.status = eStatusOpened;
    self.hidden = NO;
    NSLog(@"     refresh open");
}

- (void)close {
    
    self.status = eStatusClosed;
    self.hidden = YES;
    NSLog(@"     refresh close");
}




@end
