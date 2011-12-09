//
//  YasoundDataProvider.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Communicator.h"
#import "Radio.h"

@interface YasoundDataProvider : NSObject
{
  Communicator* _communicator;
}

+ (YasoundDataProvider*) main;


- (void)getWallEventsForRadio:(Radio*)radio notifyTarget:(id)target byCalling:(SEL)selector;

@end
