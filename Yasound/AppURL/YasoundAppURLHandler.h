//
//  YasoundAppURLHandler.h
//  Yasound
//
//  Created by mat on 06/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YasoundAppURLHandler : NSObject

+ (YasoundAppURLHandler*) main;

- (BOOL)handleOpenURL:(NSURL*)url;

@end
