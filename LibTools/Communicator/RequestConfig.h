//
//  RequestConfig.h
//  Yasound
//
//  Created by matthieu campion on 4/17/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Auth.h"

@interface RequestConfig : NSObject
{
    NSString* _url;
    BOOL _urlIsAbsolute;
    NSString* _method;
    NSArray* _params;
    Auth* _auth;
    id _callbackTarget;
    SEL _callbackAction;
    id _userData;
}

@property (retain, nonatomic) NSString* url;
@property BOOL urlIsAbsolute;
@property (retain, nonatomic) NSString* method;
@property (retain, nonatomic) NSArray* params;

@property (retain, nonatomic) Auth* auth;

@property (retain, nonatomic) id callbackTarget;
@property SEL callbackAction;
@property (retain, nonatomic) id userData;

@end
