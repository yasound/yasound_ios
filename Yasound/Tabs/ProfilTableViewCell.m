//
//  ProfilTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ProfilTableViewCell.h"
#import "Theme.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"

#import "InteractiveView.h"





@implementation ProfilTableViewCell

@synthesize scrollview;
@synthesize items;
@synthesize target;
@synthesize action;
@synthesize displayRadios;
@synthesize displayUsers;

static NSString* ProfilCellRadioIdentifier = @"ProfilCellRadio";


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier items:(NSArray*)items target:(id)target action:(SEL)action;
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self updateWithItems:items];
        
  }
  return self;
}







- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
//        for (NSArray* objects in self.radioObjects)
//        {
//            WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
//            if (view)
//                [view releaseCache];
//            view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
//            if (view)
//                [view releaseCache];
//        }
    }
}




- (void)updateWithItems:(NSArray*)items;
{
    self.items = items;
    
    if (items != nil)
    {
        id object = [items objectAtIndex:0];
        if ([object isKindOfClass:[Radio class]])
        {
            self.displayRadios = YES;
            self.displayUsers = NO;
        }
        
        else if ([object isKindOfClass:[User class]])
        {
            self.displayRadios = NO;
            self.displayUsers = YES;
        }
    }
    
    if (self.scrollview != nil)
    {
        [self.scrollview removeFromSuperview];
        self.scrollview = nil;
    }
    
    
    self.scrollview = [[UIScrollView alloc] initWithFrame:self.frame];
    [self addSubview:self.scrollview];
    
    if (self.displayRadios)
        [self updateRadios];
    else
        [self updateUsers];

    
}

- (void)updateRadios
{
    NSInteger itemIndex = 0;
    CGFloat xOffset = 0;
    BundleStylesheet* sheet = nil;
    
    if (self.userObjects)
        [self.userObjects release];
    self.userObjects = [[NSMutableArray alloc] init];
    
    for (Radio* radio in self.items)
    {
        BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
        UIView* container = [[UIView alloc] initWithFrame:sheetContainer.frame];
        [self addSubview:container];

        // radio image
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        WebImageView* radioImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
        radioImage.frame = sheet.frame;
        [container addSubview:radioImage];

        // radio mask
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        sheet.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        UIImageView* radioMask = [sheet makeImage];
        [container addSubview:radioMask];

        // title
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* title = [sheet makeLabel];
        title.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@", radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name];
        [container addSubview:title];

        // interactive view : catch the "press down" and "press up" actions
        [self.userObjects addObject:radioMask];
        
        InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [container addSubview:interactiveView];


        itemIndex++;
        xOffset += (sheetContainer.frame.size.width);
    }

}


- (void)onInteractivePressedDown:(NSNumber*)nbIndex
{
    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
}


- (void)onInteractivePressedUp:(NSNumber*)nbIndex
{
    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
    
    Radio* radio = [self.items objectAtIndex:radioIndex];
    
    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:radio];
}




- (void)updateUsers
{
    
}






- (void)dealloc
{
//    [self.cellLoader release];
  [super dealloc];
}



//- (void)onInteractivePressedDown:(NSNumber*)indexNb
//{
//    // set the "highlighted" image for the radio mask
//    NSInteger radioIndex = [indexNb integerValue];
//    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
//    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [radioMask setImage:[sheet image]];
//}
//
//- (void)onInteractivePressedUp:(NSNumber*)indexNb
//{
//    // set back the "normal" image for the radio mask
//    NSInteger radioIndex = [indexNb integerValue];
//    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
//    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [radioMask setImage:[sheet image]];
//    
//    Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];
//
//    // and call external action to delegate the radio selection
//    [self.target performSelector:self.action withObject:radio];
//}
//




//- (void)onUpdate:(NSTimer*)timer
//{
//    [[YasoundDataCache main] requestCurrentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
//}
//- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
//{
//    if (!song)
//        return;
//    
//    self.radioSubtitle1.text = song.artist;
//    self.radioSubtitle2.text = song.name;
//}



//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//  [super setSelected:selected animated:animated];
//
//  if (selected)
//  {
//    self.cellBackground.image = _bkgSelected;
//    self.radioAvatarMask.image = _maskSelected;
//
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:@"selected"];
//  }
//  else
//  {
//    self.cellBackground.image = _bkgBackup;
//    self.radioAvatarMask.image = _maskBackup;
//
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:nil];
//  }
//}








//
//
//#pragma mark - TableView Source and Delegate
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (self.items == nil)
//        return 0;
//    return [self.items count];
//}
//
//
//
////- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
////    view.frame = CGRectMake(0, 0, 100, 100);
////    cell.backgroundView = view;
////    [view release];
////}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    return 100;
//}





//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    }
//    
//    cell.textLabel.text = @"prout";
//    cell.textLabel.frame = CGRectMake(0, 0, 100, 100);
//    
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
//    view.backgroundColor = [UIColor redColor];
//    cell.backgroundView = view;
//    cell.selectedBackgroundView = view;
//    
//    
//    return cell;
//    
//    
//    
//    
//    if (self.displayRadios)
//    {
//        Radio* radio = [self.items objectAtIndex:indexPath.row];
//        
//        ProfilCellRadio* cell = [tableView dequeueReusableCellWithIdentifier:ProfilCellRadioIdentifier];
//        if (cell == nil)
//        {
//            NSArray* topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
//            cell = [topLevelItems objectAtIndex:0];
//        }
//        
//        [cell updateWithRadio:radio];
//        
//        return cell;
//    }
//    
//    return nil;
//}
//
//
//
//- (NSIndexPath *)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return nil;
//}










@end
