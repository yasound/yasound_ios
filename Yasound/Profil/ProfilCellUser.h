//
//  ProfilCellUser.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface ProfilCellUser : UIView

@property (nonatomic, assign) User* user;


- (id)initWithUser:(User*)user;



@end
