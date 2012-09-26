//
//  YasoundDataCacheImage.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundDataCacheImage.h"
#import "FMDatabaseAdditions.h"
#import "UserSettings.h"

//........................................................................................
//
// YasoundDataCacheImageManager
//
//

@implementation YasoundDataCacheImageManager

@synthesize fifo;
@synthesize db;
@synthesize cacheDirectory;
@synthesize memoryCacheImages;


static NSInteger _dbSizeMax = 1024 * 1024 * 128; // CACHE MAX SIZE : 128Mo

static YasoundDataCacheImageManager* _main;

+ (YasoundDataCacheImageManager*)main
{
    if (_main == nil)
    {
        _main = [[YasoundDataCacheImageManager alloc] init];
    }
        
    return _main;
}   

- (id)init
{
    if (self = [super init])
    {
        [self initDB];
            
    }
    return self;
}


// be careful
- (void)clear
{
    DLog(@"YasoundDataCacheImageManager::clear : empty the cache and the DB");
    [self resetDB];
}



- (void)clearItem:(NSURL*)url
{
    NSString* strurl = [url absoluteString];
    
    // remove the object from the memory cache
    [self.memoryCacheImages removeObjectForKey:strurl];

    // remove the file
    
    FMResultSet* s = [db executeQuery:@"SELECT * FROM imageRegister WHERE url=?", strurl];
    if ([s next]) 
    {
        NSString* filepath = [s stringForColumnIndex:1];
        BOOL res = [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        DLog(@"YasoundDataCacheImage clearItem delete image %d", res);

    }
    else
        DLog(@"YasoundDataCacheImage clearItem error getting the image filepath");
    

    [self.db beginTransaction];
    
     // remove the entry from the DB
    BOOL res = [self.db executeUpdate:@"DELETE FROM imageRegister WHERE url=?", strurl];

    [self.db commit];
    
    DLog(@"YasoundDataCacheImage clearItem result %d for Url %@", res, strurl);
}



- (void)resetDB
{
    // empty fifo
    [self.fifo release];
    
    // delete the cache directory
    NSError* error;
    BOOL res = [[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectory error:&error];
    if (!res)
    {
        DLog(@"error deleting the cache directory! Error - %@", [error localizedDescription]);
        assert(0);
    }
    
    // delete db file
    [self.db close];
    
    // delete memory cache
    [self.memoryCacheImages release];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* dbPath = [paths objectAtIndex:0]; 
    dbPath = [dbPath stringByAppendingPathComponent:@"cache.db"];

    res = [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
    if (!res)
    {
        DLog(@"error deleting the DB file! Error - %@", [error localizedDescription]);
        assert(0);
    }

        

    
    // and init the whole thing again... 
    [self initDB];
}


- (void)initDB
{
    // memory object fifo
    self.fifo = [[NSMutableArray alloc] init];

    // memory cache images
    self.memoryCacheImages = [[NSMutableDictionary alloc] init];

    
    // registered size accu
    [[UserSettings main] setInteger:0 forKey:USKEYcacheImageRegisterSize];
    

    // set the cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    self.cacheDirectory = [paths objectAtIndex:0]; 
    self.cacheDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"images"];
    
    NSError* error;
    BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    // something went wront
    if (!res)
    {
        self.cacheDirectory = nil;
        DLog(@"error creating the cache directory! Error - %@", [error localizedDescription]);
    }

    
    // create the DB file
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* dbPath = [paths objectAtIndex:0]; 
    dbPath = [dbPath stringByAppendingPathComponent:@"cache.db"];
    
    self.db = [FMDatabase databaseWithPath:dbPath];
    if (![self.db open]) 
    {
        DLog(@"YasoundDataCache error : could not open the db file.");
        [self.db release];
    }      
    else 
    {
        BOOL res = [self.db tableExists:@"imageRegister"];
        if (!res)
        {
            DLog(@"YasoundDataCache create database imageRegister table");
            [self.db executeUpdate:@"CREATE TABLE imageRegister (url VARCHAR(255), filepath VARCHAR(255), last_access timestamp, filesize INTEGER)"];
        }
    }
}



- (void)dump
{
    NSUInteger count = [db intForQuery:@"select count(*) from imageRegister"];
    if (count == 0)
        return;
    
    DLog(@"\n\n-------------------------------------------\nSQLITE imageRegister dump\n");
    
    DLog(@"%d elements in db", count);
    
    FMResultSet* s = [db executeQuery:@"SELECT * FROM imageRegister"];
    NSInteger counter = 0;
    while ([s next]) 
    {
        NSString* url = [s stringForColumnIndex:0];
        NSString* filepath = [s stringForColumnIndex:1];
        NSDate* last_access = [s dateForColumnIndex:2];
        NSUInteger filesize = [s intForColumnIndex:3];
        
        NSRange range = NSMakeRange(url.length - 32, 32);
        NSMutableString* short_url = @"...";
        short_url = [short_url stringByAppendingString:[url substringWithRange:range]];
        
        range = NSMakeRange(filepath.length - 32, 32);
        NSMutableString* short_filepath = @"...";
        short_filepath = [short_filepath stringByAppendingString:[filepath substringWithRange:range]];
        
        DLog(@"%d. %@ - %@ - %@ - %d", counter, url, short_filepath, last_access, filesize);
        counter++;
    }
    
    DLog(@"end.\n----------------------------------------------\n");
}



- (void)startGC:(NSInteger)currentRegisteredSize
{
    if (currentRegisteredSize < _dbSizeMax)
        return;
    
    DLog(@"YasoundDataCacheImage start Garbage Collector : current size %d vs max size %d", currentRegisteredSize, _dbSizeMax);
    
    // get all the registered images, ordered from the oldest one to the newer one
    FMResultSet* s = [db executeQuery:@"SELECT * FROM imageRegister ORDER BY last_access ASC"];
    BOOL done = NO;
    NSInteger counter = 0;
    while (!done && [s next]) 
    {
        NSString* url = [s stringForColumnIndex:0];
        NSString* filepath = [s stringForColumnIndex:1];
        NSUInteger filesize = [s intForColumnIndex:3];
        
        // delete the file
        NSError* error;
        BOOL res = [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
        
        if (!res)
        {
            DLog(@"error deleting the file from the cache disk! Error - %@", [error localizedDescription]);
            continue;
        }
        
        // remove the object from the memory cache
        [self.memoryCacheImages removeObjectForKey:url];
        
        
        // remove the entry from the DB
         [db executeQuery:@"DELETE FROM imageRegister WHERE url=?", url];

        // do we need some more?
        currentRegisteredSize -= filesize;
        done = (currentRegisteredSize < _dbSizeMax);
        
        counter++;
        DLog(@"deleted file %@ for url %@", filepath, url);
    }
    
    DLog(@"\ndeleted %d files", counter);

    
    // things back to normal, we are below the limit.
    [[UserSettings main] setInteger:currentRegisteredSize forKey:USKEYcacheImageRegisterSize];

    // extreme case : there were error in deleting the files, and the cache is still over the limit
    // dont have a choice, we have to delete the whole thing
    if (currentRegisteredSize > _dbSizeMax)
    {
        DLog(@"extreme case! we are still above the limit : %d vs %d", currentRegisteredSize, _dbSizeMax);
        DLog(@"reset the DB and cache!");
        [self resetDB];
    }

    
}



- (void)dealloc
{
    [self.db close];
    [self.db release];
    [super dealloc];
}


- (void)addItem:(YasoundDataCacheImage*)item
{
    [self.fifo addObject:item];

    if (self.fifo.count == 1)
        [item launch];
}

- (void)loop
{
    if (self.fifo.count == 0)
        return;
    
    [self.fifo removeObjectAtIndex:0];
    if (self.fifo.count == 0)
        return;

    YasoundDataCacheImage* item = [self.fifo objectAtIndex:0];
    [item launch];
}



@end






//........................................................................................
//
// YasoundDataCacheImageTarget
//
//



@implementation YasoundDataCacheImageTarget
@synthesize target;
@synthesize action;
@end






//........................................................................................
//
// YasoundDataCacheImage
//
//


@implementation YasoundDataCacheImage

@synthesize url;
@synthesize last_access;
@synthesize image;
@synthesize targets;
@synthesize receivedData;
@synthesize isDownloading;
@synthesize target;
@synthesize action;




- (id)initWithUrl:(NSURL*)aUrl
{
    if (self = [super init])
    {
        self.url = aUrl;
        self.targets = [[NSMutableArray alloc] init];
        self.isDownloading = NO;
        
        //DLog(@"YasoundDataCacheImage initWithUrl %@", aUrl);
        
        // try to import the image from the disk
        FMResultSet* s = [[YasoundDataCacheImageManager main].db executeQuery:@"SELECT * FROM imageRegister WHERE url=?", self.url];
        if ([s next]) 
        {
            NSString* filepath = [s stringForColumnIndex:1];
            self.image = [[UIImage alloc] initWithContentsOfFile:filepath];
        }
    }
    
    return self;
}


- (void)addTarget:(id)target action:(SEL)action
{
    if (self.targets == nil)
        return;
    
    // only once
    for (YasoundDataCacheImageTarget* t in self.targets)
    {
        if (t.target == target)
            return;
    }
    
    YasoundDataCacheImageTarget* t = [[YasoundDataCacheImageTarget alloc] init];
    t.target = target;
    t.action = action;
    [self.targets addObject:t];
}

- (void)removeTarget:(id)target
{
    if (self.targets == nil)
        return;
    
    for (NSInteger index = 0; index < self.targets.count; index++)
    {
        YasoundDataCacheImageTarget* t = [self.targets objectAtIndex:index];
        if (t.target == target)
        {
            [self.targets removeObjectAtIndex:index];
            return;
        }
    }
}


- (void)start
{    
    self.target = target;
    self.action = action;
    
    [[YasoundDataCacheImageManager main] addItem:self];
}

- (void)updateTimestamp
{
    NSDate* now = [NSDate date];
    [[YasoundDataCacheImageManager main].db executeUpdate:@"UPDATE imageRegister SET last_access=? WHERE url=?", now, [self.url absoluteString]];
}



 


- (void)launch
{
    self.isDownloading = YES;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) 
    {
        DLog(@"YasoundDataCache requestImageToServer : connection did fail!");
        self.isDownloading = NO;
        
        [[YasoundDataCacheImageManager main] loop];
        return;
    }
    
    self.receivedData = [[NSMutableData data] retain];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
    
//    CGFloat expectedDataLength = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isDownloading = NO;
    
    [connection release];
    [self.receivedData release];
    
    // inform the user
    DLog(@"YasoundDataCacheImage Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [[YasoundDataCacheImageManager main] loop];    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //DLog(@"connectionDidFinishLoading for image %@", self.url);

    self.image = [[UIImage alloc] initWithData:self.receivedData];
    
    // we want to store the image on disk.

    // get a unique filepath and store the file
    if ([YasoundDataCacheImageManager main].cacheDirectory != nil)
    {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        NSString* filePath = [[YasoundDataCacheImageManager main].cacheDirectory stringByAppendingPathComponent:(NSString *)newUniqueIdString];
        
        NSError* error;
        BOOL res = [self.receivedData writeToFile:filePath options:NSAtomicWrite error:&error];

        // something went wront
        if (!res)
        {
            DLog(@"error writing the file '%@'! Error - %@", filePath, [error localizedDescription]);
        }
        
        // everything's fine. write the info down to the image register
        else
        {
            NSDate* now = [NSDate date];
            
            [[YasoundDataCacheImageManager main].db executeUpdate:@"INSERT INTO imageRegister VALUES (?,?,?,?)", [self.url absoluteString], filePath, now, [NSNumber numberWithInt:self.receivedData.length]];
            
            // and update the cache size count
            BOOL error;
            NSInteger imageRegisterSize = [[UserSettings main] integerForKey:USKEYcacheImageRegisterSize error:&error];
            if (error)
                imageRegisterSize = 0;
            imageRegisterSize += self.receivedData.length;
            
            [[UserSettings main] setInteger:imageRegisterSize forKey:USKEYcacheImageRegisterSize];
            
            
            // check if GC is necessary
            [[YasoundDataCacheImageManager main] startGC:imageRegisterSize];
        }
        
    }

    
    

    // callback for all registered targets
    for (YasoundDataCacheImageTarget* t in self.targets)
    {
        if ((t.target != nil) && ([t.target respondsToSelector:t.action]))
            [t.target performSelector:t.action withObject:self.image];
    }
    
    [self.targets release];
    self.targets = nil;

    
    
    [self.receivedData release];
    self.receivedData = nil;
    
    self.isDownloading = NO;
    
    
    // call for next download
    [[YasoundDataCacheImageManager main] loop];    
}



@end
