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



//+ (UINib*)nib
//{
////    // singleton implementation to get a UINib object
////    static dispatch_once_t pred = 0;
////    __strong static UINib* _sharedNibObject = nil;
////    dispatch_once(&pred, ^{
////        _sharedNibObject = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
////    });
////    return _sharedNibObject;
//    
//    static UINib *nib;
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        nib = [UINib nibWithNibName:@"MyRadiosTableViewCell" bundle:nil];
//    });
//    return nib;
//}
//
//- (NSString *)reuseIdentifier
//{
//    return [[self class] reuseIdentifier];
//}
//
//+ (NSString *)reuseIdentifier
//{
//    // return any identifier you like, in this case the class name
////    return NSStringFromClass([self class]);
//    return (NSString *)@"MyRadiosTableViewCell";
//}

//- (id)initWithOwner:(id)owner target:(id)target radio:(Radio*)radio;
//{
//    UINib* myNib = [[self class] nib];
//    
//    
//    NSArray* myArray = [myNib instantiateWithOwner:owner options:nil];
//    NSLog(@"%@", myArray);
//    id object =  [myArray objectAtIndex:0];
//    
//
//    [self updateWithRadio:radio];
//    
//    return object;
//}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.metric1sub.text = NSLocalizedString(@"MyRadios.metric1.sublabel", nil);
        self.metric2sub.text = NSLocalizedString(@"MyRadios.metric2.sublabel", nil);
        
    }
    
    return self;
}



- (void)updateWithRadio:(Radio*)radio target:(id)target;
{
    self.radio = radio;
    self.delegate = target;

    
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.image setUrl:imageURL];
    
    // info
    self.title.text = radio.name;
    self.subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
    self.listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];

    // metrics
    self.metric1.text = [self.radio.overall_listening_time stringValue];
    self.metric2.text = [self.radio.new_wall_messages_count stringValue];
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




- (IBAction)onRadioClicked:(id)sender
{
    [self.delegate myRadioRequestedPlay:self.radio];
}


- (IBAction)onStatsClicked:(id)sender
{
    [self.delegate myRadioRequestedStats:self.radio];
}

- (IBAction)onSettingsClicked:(id)sender
{
    [self.delegate myRadioRequestedSettings:self.radio];
}



@end
