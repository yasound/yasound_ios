//
//  DataBase.h
//  yasound
//
//  Created by LOIC BERTHELOT on 13/04/12.
//  Copyright (c) 2012 loïc berthelot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define RADIOCATALOG_TABLE @"radioCatalog"
#define LOCALCATALOG_TABLE @"localCatalog"

@interface DataBase : NSObject

@property (nonatomic, retain) FMDatabase* db;
@property (nonatomic, retain) NSString* dbPath;


+ (DataBase*)main;
+ (void)releaseDataBase;


@end
