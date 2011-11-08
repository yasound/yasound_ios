//
//  WallMessageViewController.h
//  Yasound
//
//  Created by Sébastien Métrot on 11/2/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallMessageViewController : UIViewController
{
}

@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *message;

@end
