//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//



#import "TwitteriOSSessionManager.h"



@implementation TwitteriOSSessionManager

@synthesize account = _account;
  




- (void)login:(id)target
{
  self.delegate = target;
}



- (void)logout
{

}



@end
