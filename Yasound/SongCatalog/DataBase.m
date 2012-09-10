//
//  DataBase.m
//  yasound
//
//  Created by LOIC BERTHELOT on 13/04/12.
//  Copyright (c) 2012 loïc berthelot. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase

@synthesize db;
@synthesize dbPath;


static DataBase* _main = nil;

+ (DataBase*)main {
    
    if (_main == nil)
    {
        _main = [[DataBase alloc] init];
    }
    return _main;
}


- (void)dealloc {
    
    [self.db close];
    
    // delete current DB file
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
    }
    
    [super dealloc];

}

- (id)init {
    
    if (self = [super init]) {

        // create the DB file
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dbPath = [paths objectAtIndex:0];
        self.dbPath = [self.dbPath stringByAppendingPathComponent:@"songCatalog.sqlite"];
        
        
        // delete current DB file
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
        }

        
        self.db = [FMDatabase databaseWithPath:self.dbPath];
        if (![self.db open])
        {
            NSLog(@"error : could not open the db file.");
            [self.db release];
        }
        else
        {
            // radioCatalog
            BOOL res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@ (songKey TEXT, name VARCHAR(255), nameLetter VARCHAR(1), artistKey VARCHAR(255), artistLetter VARCHAR(1), albumKey VARCHAR(255), genre VARCHAR(255))", RADIOCATALOG_TABLE]];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
            else
            {
                res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX radioCatalogKeyIndex ON %@ (songKey)", RADIOCATALOG_TABLE]];
                if (!res)
                    NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
            }
            
            // localCatalog
            res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@ (songKey TEXT, name VARCHAR(255), nameLetter VARCHAR(1), artistKey VARCHAR(255), artistLetter VARCHAR(1), albumKey VARCHAR(255), genre VARCHAR(255))", LOCALCATALOG_TABLE]];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
            else
            {
                res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX localCatalogKeyIndex ON %@ (songKey)", LOCALCATALOG_TABLE]];
                if (!res)
                    NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
            }
            
            // playlistCatalog
            res = [self.db executeUpdate:@"CREATE TABLE playlistCatalog (songKey TEXT, playlist VARCHAR(255))"];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        }
    }
    
    return self;
}



+ (void)releaseDataBase {
    
    if (_main) {
    
        [_main release];
        _main = nil;
    }
}




@end

