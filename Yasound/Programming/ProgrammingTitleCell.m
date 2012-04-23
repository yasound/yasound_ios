//
//  ProgrammingTitleCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingTitleCell.h"
#import "BundleFileManager.h"
#import "Theme.h"


@implementation ProgrammingTitleCell

@synthesize label;
@synthesize sublabel;
@synthesize buttonDelete;
@synthesize song;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSong:(Song*)aSong
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        _editMode = NO;
        
//        self.label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 200, 15)];
//        [self addSubview:self.label];
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"ProgrammingTitleCell_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        [self addSubview:self.label];

//        self.sublabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 22, 200, 15)];
//        [self addSubview:self.sublabel];

        sheet = [[Theme theme] stylesheetForKey:@"ProgrammingTitleCell_sublabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.sublabel = [sheet makeLabel];
        [self addSubview:self.sublabel];

        [self updateWithSong:aSong];
        
        
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];

        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];

        
        
        
        
        
    }
    return self;
}


- (void)updateWithSong:(Song*)aSong
{
    self.song = aSong;
    
    self.label.text = song.name;
    self.sublabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];

//    //LBDEBUG
//    NSLog(@"\n\n%@", self.label.text);
//    NSLog(@"\n\n%@", self.sublabel.text);
//    
    if ([song isSongEnabled])
    {
        self.label.textColor = [UIColor whiteColor];
        self.sublabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    }
    else 
    {
        self.label.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
        self.sublabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    }
}


#define BORDER 8

- (void)onSwipeRight
{
    if (_editMode)
        return;
    _editMode = YES;
    
    // create delete button
    UIImage* image = [UIImage imageNamed:@"barRedItemMediumBkg.png"];
    CGFloat size = image.size.width;
    self.buttonDelete = [[UIButton alloc] initWithFrame:CGRectMake(-size, self.frame.size.height /2.f - image.size.height /2.f, size, image.size.height)];
    [self.buttonDelete setImage:image forState:UIControlStateNormal];
    [self.buttonDelete setImage:[UIImage imageNamed:@"barRedItemMediumBkgHighlighted.png"] forState:UIControlStateHighlighted];
    [self.buttonDelete setImage:[UIImage imageNamed:@"barItemMediumBkgDisabled.png"] forState:UIControlStateDisabled];
    [self.buttonDelete addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonDelete];
    
    // delete button label
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"ProgrammingTitleCell_buttonDelete_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* buttonLabel = [sheet makeLabel];
    buttonLabel.text = NSLocalizedString(@"ProgrammingTitleCell_buttonDelete_label", nil);
    [self.buttonDelete addSubview:buttonLabel];
    
    // compute frames for animation
    CGRect frameLabel = self.label.frame;
    frameLabel = CGRectMake(frameLabel.origin.x + size + BORDER, frameLabel.origin.y, frameLabel.size.width - size - BORDER, frameLabel.size.height);
    CGRect frameSublabel = self.sublabel.frame;
    frameSublabel = CGRectMake(frameSublabel.origin.x + size + BORDER, frameSublabel.origin.y, frameSublabel.size.width - size - BORDER, frameSublabel.size.height);
    CGRect frameButton = self.buttonDelete.frame;
    frameButton = CGRectMake(BORDER, frameButton.origin.y, frameButton.size.width, frameButton.size.height);
    
    // move button and labels with animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.label.frame = frameLabel;
    self.sublabel.frame = frameSublabel;
    self.buttonDelete.frame = frameButton;
    [UIView commitAnimations];
}



- (void)onSwipeLeft
{
    if (!_editMode)
        return;
    _editMode = NO;
    
    CGFloat size = self.buttonDelete.frame.size.width;
    
    // compute frames for animation
    CGRect frameLabel = self.label.frame;
    frameLabel = CGRectMake(frameLabel.origin.x - size - BORDER, frameLabel.origin.y, frameLabel.size.width + size + BORDER, frameLabel.size.height);
    CGRect frameSublabel = self.sublabel.frame;
    frameSublabel = CGRectMake(frameSublabel.origin.x - size - BORDER, frameSublabel.origin.y, frameSublabel.size.width + size + BORDER, frameSublabel.size.height);
    CGRect frameButton = self.buttonDelete.frame;
    frameButton = CGRectMake(-size, frameButton.origin.y, frameButton.size.width, frameButton.size.height);
    
    // move button and labels with animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onSwipeLeftStop)];
    self.label.frame = frameLabel;
    self.sublabel.frame = frameSublabel;
    self.buttonDelete.frame = frameButton;
    [UIView commitAnimations];
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.buttonDelete removeFromSuperview];
    self.buttonDelete = nil;
}
     

- (void)onDelete:(id)sender
{
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
