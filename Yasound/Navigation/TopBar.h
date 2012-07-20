//
//  TopBar.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopBarDelegate <NSObject>
- (void)topBarBackItemClicked;
- (void)topBarNowPlayingClicked;
@end


@interface TopBar : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarDelegate> delegate;

@end
