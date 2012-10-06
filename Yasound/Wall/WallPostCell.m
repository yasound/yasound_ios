//
//  WallPostCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//
//

#import "WallPostCell.h"


@implementation WallPostCell

@synthesize fixed;
@synthesize textfield;
@synthesize button;
@synthesize label;
//@synthesize delegate;
//


- (void)awakeFromNib
{
    self.fixed = NO;
    self.textfield.placeholder = NSLocalizedString(@"Wall.postBar.placeholder", nil);
    self.label.text = NSLocalizedString(@"Wall.postBar.label", nil);
}



//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview)
//    {
//        [self.delegate postCellMoveToSuperview];
//    }
//}

//- (void)willMoveToWindow:(UIWindow *)newWindow
//{
//    NSLog(@"ok");
//}

@end


////....................................................................................
////
//// message bar
////
//sheet = [[Theme theme] stylesheetForKey:@"Wall.MessageBarBackground" error:nil];
//UIImageView* messageBarView = [[UIImageView alloc] initWithImage:[sheet image]];
//messageBarView.frame = sheet.frame;
//
//[_viewWall addSubview:messageBarView];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.RadioViewMessageBar" error:nil];
//_messageBar = [[UITextField alloc] initWithFrame:sheet.frame];
//_messageBar.delegate = self;
//[_messageBar setBorderStyle:UITextBorderStyleRoundedRect];
//[_messageBar setPlaceholder:NSLocalizedString(@"radioview_message", nil)];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.RadioViewMessageBarFont" error:nil];
//[_messageBar setFont:[sheet makeFont]];
//
//[_viewWall addSubview:_messageBar];
