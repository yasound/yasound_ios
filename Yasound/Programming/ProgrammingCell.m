//
//  ProgrammingCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WebImageView.h"
#import "YasoundDataProvider.h"

@implementation ProgrammingCell

@synthesize image;
@synthesize label;
@synthesize sublabel;
@synthesize buttonDelete;
@synthesize buttonLabel;
@synthesize buttonSpinner;
@synthesize song;
@synthesize row;


static NSMutableDictionary* gEditingSongs = nil;






//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview)
//    {
//        if (self.image)
//            [self.image releaseCache];
//    }
//}




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSong:(Song*)aSong atRow:(NSInteger)row deletingTarget:(id)deletingTarget deletingAction:(SEL)deletingAction
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        if (gEditingSongs == nil)
            gEditingSongs = [[NSMutableDictionary alloc] init];
        
        _editMode = NO;
        
        _deletingTarget = deletingTarget;
        _deletingAction = deletingAction;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;

        

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:self.image];
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImageMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.mask = [sheet makeImage];
        [self addSubview:self.mask];

        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        [self addSubview:self.label];


        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.sublabel = [sheet makeLabel];
        [self addSubview:self.sublabel];

        [self updateWithSong:aSong atRow:row];
        
        
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];

        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];
        
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier text:(NSString*)text detailText:(NSString*)detailText customImage:(UIImage*)customImage refSong:(Song*)aSong
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        if (gEditingSongs == nil)
            gEditingSongs = [[NSMutableDictionary alloc] init];
        
        _editMode = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* url = [[YasoundDataProvider main] urlForPicture:aSong.cover];
        self.image = [[WebImageView alloc] initWithImageAtURL:url];
        self.image.frame = sheet.frame;
        [self addSubview:self.image];
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImageMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* mask = [sheet makeImage];
        [self addSubview:mask];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        [self addSubview:self.label];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.sublabel = [sheet makeLabel];
        [self addSubview:self.sublabel];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* di = [sheet makeImage];
        self.accessoryView = di;
        [di release];

        
        [self updateWithText:text detailText:detailText customImage:customImage refSong:aSong];
        
    }
    return self;
}


- (void)dealloc
{
    [gEditingSongs removeObjectForKey:self.song.name];
    [super dealloc];
}






- (void)updateWithSong:(Song*)aSong atRow:(NSInteger)row
{
    self.song = aSong;
    self.row = row;
    
    if (self.row == 0)
        self.label.text = song.name;
    else
        self.label.text = [NSString stringWithFormat:@"%d. %@", self.row, song.name];

    self.sublabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    
    [self.image releaseCache];

    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
    self.image.url = url;

    BOOL editing = ([gEditingSongs objectForKey:self.song.name] != nil);

    if ([song isSongEnabled])
    {
        self.label.alpha = 1;
        self.sublabel.alpha = 1;
        self.image.alpha = 1;
    }
    else 
    {
        self.label.alpha = 0.5;
        self.sublabel.alpha = 0.5;
        self.image.alpha = 0.5;
    }
    
    if (editing && !_editMode)
    {
        [self activateEditModeAnimated:NO];
    }
    else if (!editing && _editMode)
    {
        [self deactivateEditModeAnimated:NO];
    }
}





- (void)updateWithText:(NSString*)text detailText:(NSString*)detailText customImage:(UIImage*)customImage refSong:(Song*)refSong
{
    self.song = refSong;
    self.row = 0;
    
    self.label.text = text;
    self.sublabel.text = detailText;
    
    [self.image releaseCache];

    if (customImage == nil)
    {
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
        self.image.url = url;
    }
    else
    {
        [self.image setImage:customImage];
    }
    
    BOOL editing = NO;
}







#define BORDER 8

- (void)onSwipeRight
{
    [self deactivateEditModeAnimated:YES];
}

- (void)activateEditModeAnimated:(BOOL)animated
{
    if (_editMode)
        return;
    
    _editMode = YES;
    [gEditingSongs setObject:[NSNumber numberWithBool:YES] forKey:self.song.name];
    
    // create delete button
    UIImage* image = [UIImage imageNamed:@"barRedItemMediumBkg.png"];
    CGFloat size = image.size.width;
    self.buttonDelete = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.size.height /2.f - image.size.height /2.f, size, image.size.height)];
    [self.buttonDelete setImage:image forState:UIControlStateNormal];
    [self.buttonDelete setImage:[UIImage imageNamed:@"barRedItemMediumBkgHighlighted.png"] forState:UIControlStateHighlighted];
    [self.buttonDelete setImage:[UIImage imageNamed:@"barItemMediumBkgDisabled.png"] forState:UIControlStateDisabled];
    [self.buttonDelete addTarget:self action:@selector(onDeleteRequest:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonDelete];
    
    // delete button label
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemEmptyLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonLabel = [sheet makeLabel];
    self.buttonLabel.frame = CGRectMake(0, 0, self.buttonDelete.frame.size.width, self.buttonDelete.frame.size.height);
    self.buttonLabel.text = NSLocalizedString(@"Programming.del", nil);
    [self.buttonDelete addSubview:self.buttonLabel];
    
    // compute frames for animation
    CGRect frameLabel = self.label.frame;
    frameLabel = CGRectMake(frameLabel.origin.x - size + 2*BORDER, frameLabel.origin.y, frameLabel.size.width - size - BORDER, frameLabel.size.height);
    CGRect frameSublabel = self.sublabel.frame;
    frameSublabel = CGRectMake(frameSublabel.origin.x - size + 2*BORDER, frameSublabel.origin.y, frameSublabel.size.width - size - BORDER, frameSublabel.size.height);
    CGRect frameButton = self.buttonDelete.frame;
    frameButton = CGRectMake(self.frame.size.width - size - 2*BORDER, frameButton.origin.y, frameButton.size.width, frameButton.size.height);
    
    // move button and labels with animation
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
    }
    self.label.frame = frameLabel;
    self.sublabel.frame = frameSublabel;
    self.buttonDelete.frame = frameButton;
//    self.imageView.frame = CGRectMake(-self.imageView.frame.size.width, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.image.alpha = 0;
    self.mask.alpha = 0;
    if (animated)
    {
        [UIView commitAnimations];
    }
}



- (void)onSwipeLeft
{
    [self activateEditModeAnimated:YES];

}


- (void)deactivateEditModeAnimated:(BOOL)animated
{
    if (!_editMode)
        return;
    _editMode = NO;
    
    [gEditingSongs removeObjectForKey:self.song.name];

    
    CGFloat size = self.buttonDelete.frame.size.width;
    
    // compute frames for animation
    CGRect frameLabel = self.label.frame;
    frameLabel = CGRectMake(frameLabel.origin.x + size - 2*BORDER, frameLabel.origin.y, frameLabel.size.width + size + BORDER, frameLabel.size.height);
    CGRect frameSublabel = self.sublabel.frame;
    frameSublabel = CGRectMake(frameSublabel.origin.x +size - 2*BORDER, frameSublabel.origin.y, frameSublabel.size.width + size + BORDER, frameSublabel.size.height);
    CGRect frameButton = self.buttonDelete.frame;
    frameButton = CGRectMake(self.frame.size.width, frameButton.origin.y, frameButton.size.width, frameButton.size.height);
    
    // move button and labels with animation
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwipeLeftStop)];
    }
    self.label.frame = frameLabel;
    self.sublabel.frame = frameSublabel;
    self.buttonDelete.frame = frameButton;
    self.image.alpha = 1;
    self.mask.alpha = 1;
    if (animated)
    {
        [UIView commitAnimations];
    }
    else
    {
        [self onSwipeLeftStop:nil finished:nil context:nil];
    }
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.buttonDelete removeFromSuperview];
    self.buttonDelete = nil;
}
     


- (void)onDeleteRequest:(id)sender
{
    [gEditingSongs removeObjectForKey:self.song.name];

    if (_deletingTarget == nil)
        return;
    
    [_deletingTarget performSelector:_deletingAction withObject:self withObject:self.song];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
