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
        [self addSubview:self.label];
        
        self.backgroundColor = [UIColor clearColor];
        
//        sheet = [[Theme theme] stylesheetForKey:@"RefreshIndicator.icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        self.icon = [sheet makeImage];
//        [self addSubview:self.icon];
        
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
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RefreshIndicator.icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.icon = [sheet makeImage];
    [self addSubview:self.icon];

    NSLog(@"     refresh pull");
}


- (void)open {
    
    self.label.text = NSLocalizedString(@"RefreshIndicator.label.opened", nil);
    
    self.status = eStatusOpened;
    self.hidden = NO;

    CABasicAnimation* rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnim.toValue = [NSNumber numberWithFloat: M_PI];
    rotateAnim.delegate = self;
    [self.icon.layer addAnimation:rotateAnim forKey:@"rotateAnim"];
    
    NSLog(@"     refresh open");
}


- (void)openedAndRelease {
    
    [self.icon removeFromSuperview];
    [self.icon release];

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RefreshIndicator.icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.frame = sheet.frame;
    [self addSubview:self.indicator];
    
    [self.indicator startAnimating];

}

- (void)close {
    
    self.status = eStatusClosed;
    self.hidden = YES;
    NSLog(@"     refresh close");
    
    [self.indicator stopAnimating];
    [self.indicator release];
}



#pragma mark - CAAnimationDelegate

//- (void)animationDidStart:(CAAnimation *)anim;

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.icon.transform = CGAffineTransformMakeRotation(M_PI);
}





@end
