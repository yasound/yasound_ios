//
//  SlidingMenu.m
//  Yasound
//
//  Created by Sébastien Métrot on 10/26/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SlidingMenu.h"
#import "MenuHeader.h"
#import "Tile.h"

@implementation SlidingMenu

- (id)initWithFrame:(CGRect)frame menuName:(NSString*)name names:(NSArray*)names captions:(NSArray*)captions andDestinations:(NSArray*)destinations
{
  const int interline = 22;
  const int H = frame.size.height - interline;
  const int W = H * .85;

  tiles = [[NSMutableArray alloc] initWithCapacity:[destinations count]];
  
  self = [super initWithFrame:frame];
  if (self)
  {
    // Title:
    MenuHeader* pLabel = [[MenuHeader alloc] initWithFrame:CGRectMake(0, 0, 320, interline) andText:name];
    [self addSubview:pLabel];

    // Background image:
    CGRect menurect = CGRectMake(0, interline, frame.size.width, H);

    UIImage* bgimg = [UIImage imageNamed:@"MenuBg@2x.png"];
    UIImageView* bg = [[UIImageView alloc] initWithImage:bgimg];
    bg.frame = menurect;
    bg.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:bg];
    
    // Scroll view with images as buttons:
    UIScrollView* pScroll = [[UIScrollView alloc] initWithFrame:menurect];
    [self addSubview:pScroll];
    [pScroll setScrollEnabled:TRUE];
    [pScroll setContentSize:CGSizeMake(4 + (W + 4) * destinations.count, H)];
    [pScroll setZoomScale:.5];
    
    for (int k = 0; k < destinations.count; k++)
    {
      NSString* str = (NSString*)[destinations objectAtIndex:k];
      NSURL* url = [NSURL URLWithString:str];
      NSString* tileName = (NSString*)[names objectAtIndex:k];
      NSString* captionName = (NSString*)[captions objectAtIndex:k];
      
      //Tile* pButton = [[[NSBundle mainBundle] loadNibNamed:@"TileView" owner:self options:nil] objectAtIndex:0];
      Tile* pButton = [[Tile alloc] initWithFrame:CGRectMake(4 + (k * (4 + W)), 0, W, H) identifier:tileName caption:captionName andImageURL: url];
      [tiles addObject: pButton];
      [pScroll addSubview:pButton];
    }
  }
  return self;
}

- (void)dealloc
{
  [tiles release];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
  for (Tile* tile in tiles)
  {
    [tile addTarget:target action:action forControlEvents:controlEvents];
  }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
