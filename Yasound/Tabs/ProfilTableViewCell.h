//
//  ProfilTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"


@interface ProfilTableViewCell : UITableViewCell


@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier items:(NSArray*)items target:(id)target action:(SEL)action;
- (void)updateWithItems:(NSArray*)items;

@end
