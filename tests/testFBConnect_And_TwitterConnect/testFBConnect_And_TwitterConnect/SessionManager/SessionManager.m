//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SessionManager.h"



@implementation SessionManager

@synthesize authorized;
@synthesize delegate = _delegate;

- (id)init
{
  self = [super init];
  if (self)
  {
    _delegate = nil;
  }
  return self;
}


- (void)dealloc
{
  [super dealloc];
}












@end