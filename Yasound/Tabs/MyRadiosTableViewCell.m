//
//  MyRadiosTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyRadiosTableViewCell.h"
#import "YasoundDataProvider.h"


@implementation MyRadiosTableViewCell

@synthesize delegate;
@synthesize radio;

@synthesize image;
@synthesize title;
@synthesize subscribers;
@synthesize listeners;
@synthesize metric1;
@synthesize metric2;
@synthesize metric1sub;
@synthesize metric2sub;



+ (UINib*)nib
{
    // singleton implementation to get a UINib object
    static dispatch_once_t pred = 0;
    __strong static UINib* _sharedNibObject = nil;
    dispatch_once(&pred, ^{
        _sharedNibObject = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    });
    return _sharedNibObject;
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    // return any identifier you like, in this case the class name
    return NSStringFromClass([self class]);
}

- (id)initWithOwner:(id)owner target:(id)target radio:(Radio*)radio;
{
    self =  [[[[self class] nib] instantiateWithOwner:owner options:nil] objectAtIndex:0];
    
    self.delegate = target;
    
    self.metric1sub.text = NSLocalizedString(@"MyRadios.metric1.sublabel", nil);
    self.metric2sub.text = NSLocalizedString(@"MyRadios.metric2.sublabel", nil);

    [self updateWithRadio:radio];
    
    return self;
}




- (void)updateWithRadios:(NSArray*)radios target:(id)target action:(SEL)action
{
    self.radio = radio;
    
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.image setUrl:imageURL];
    
    // info
    self.title.text = radio.name;
    self.subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
    self.listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];

    // metrics
    self.metric1.text = @"12345";
    self.metric2.text = @"432";
}






- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        if (self.image)
            [self.image releaseCache];
    }
}





- (void)dealloc
{
  [super dealloc];
}






- (IBAction)onStatsClicked:(id)sender
{
}

- (IBAction)onSettingsClicked:(id)sender
{
}



@end
