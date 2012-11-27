//
//  YaFormDataRequest.h
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaRequest.h"

@interface YaFormDataRequest : YaRequest

- (void)addPostValue:(id <NSObject>)value forKey:(NSString *)key;

@end
