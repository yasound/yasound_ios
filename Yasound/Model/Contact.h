//
//  Contact.h
//  Yasound
//
//  Created by mat on 24/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (retain, nonatomic) NSString* firstName;
@property (retain, nonatomic) NSString* lastName;
@property (retain, nonatomic) NSArray* emails;
@property (retain, nonatomic) UIImage* thumbnail;

@end
