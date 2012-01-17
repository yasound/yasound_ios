//
//  BuyLinkManager.h
//  Yasound
//
//  Created by Jérôme Blondon on 17/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface BuyLinkManager : NSObject <ASIHTTPRequestDelegate>

-(NSString *) generateLink: (NSString *) artist album:(NSString *)album song:(NSString *)song;
@end
