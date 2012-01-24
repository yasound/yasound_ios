//
//  DateAdditions.h
//
//  Created by Julien on 28/05/09.
//  Copyright 2009 Julien Quéré - Webd.fr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateAdditions) 
-(BOOL) isLaterThanOrEqualTo:(NSDate*)date;
-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date;
-(BOOL) isLaterThan:(NSDate*)date;
-(BOOL) isEarlierThan:(NSDate*)date;
@end

