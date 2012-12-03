//
//  NSString+JsonLoading.h
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Container.h"

@interface NSString (JsonLoading)

- (NSDictionary*)jsonToDictionary;
- (NSArray*)jsonToArray;
- (Model*)jsonToModel:(Class)ModelClass;
- (Container*)jsonToContainer:(Class)ModelClass;

@end
