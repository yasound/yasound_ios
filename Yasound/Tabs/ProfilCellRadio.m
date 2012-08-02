//
//  ProfilCellRadio.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ProfilCellRadio.h"
#import "YasoundDataProvider.h"


@implementation ProfilCellRadio

@synthesize image;
@synthesize title;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
    }
    
    return self;
}



- (void)updateWithRadio:(Radio*)radio;
{
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.image setUrl:imageURL];
    
    // info
    self.title.text = radio.name;
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







@end
