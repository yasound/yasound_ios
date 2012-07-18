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
@end


@interface TopBar : UIToolbar

@property IBOutlet id<TopBarDelegate> delegate;

@end
