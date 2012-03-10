//
//  YasoundDataCacheImage.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundDataCacheImage.h"


//........................................................................................
//
// YasoundDataCacheImageManager
//
//

@implementation YasoundDataCacheImageManager

@synthesize fifo;
@synthesize db;

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
        self.fifo = [[NSMutableArray alloc] init];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        NSString* dbPath = [paths objectAtIndex:0]; 
        dbPath = [dbPath stringByAppendingPathComponent:@"cache.db"];
        
        self.db = [FMDatabase databaseWithPath:dbPath];
        if (![self.db open]) 
        {
            NSLog(@"YasoundDataCache error : could not open the db file.");
            [self.db release];
        }      
        else 
        {
            BOOL res = [self.db tableExists:@"imageRegister"];
            if (!res)
            {
                NSLog(@"YasoundDataCache create database imageRegister table");
                [self.db executeUpdate:@"CREATE TABLE imageRegister (url VARCHAR(255), filepath VARCHAR(255), last_access timestamp, filesize INTEGER)"];
            }
        }
        
    }
    return self;
}


- (void)dump
{
    NSLog(@"\n\n-------------------------------------------\nSQLITE imageRegister dump\n");
    
    FMResultSet* s = [db executeQuery:@"SELECT COUNT(*) FROM imageRegister"];
    NSInteger counter = 0;
    while ([s next]) 
    {
        NSString* url = [s stringForColumnIndex:0];
        NSString* filepath = [s stringForColumnIndex:1];
        NSDate* last_access = [s dateForColumnIndex:2];
        NSUInteger filesize = [s intForColumnIndex:3];
        
        NSRange range = NSMakeRange(url.length - 8, 8);
        NSString* short_url = [url substringWithRange:range];
        short_url = [@"..." stringByAppendingString:short_url];
        range = NSMakeRange(filepath.length - 8, 8);
        NSString* short_filepath = [filepath substringWithRange:range];
        short_filepath = [@"..." stringByAppendingString:short_filepath];
        
        NSLog(@"%d. %@ - %@ - %@ - %d", counter, short_url, short_filepath, last_access, filesize);
        counter++;
    }
    
    NSLog(@"end.\n----------------------------------------------\n");
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


static NSString* _cacheDirectory = nil;


- (id)initWithUrl:(NSURL*)aUrl
{
    if (self = [super init])
    {
        self.url = aUrl;
        self.targets = [[NSMutableArray alloc] init];
        self.isDownloading = NO;
        
//        // try to import the image from the disk
//        // first, try to get the local filepath for this url
//        NSString* filepath = nil;
//        NSDictionary* imageRegister = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageRegister"];
//        if (imageRegister != nil)
//            filepath = [imageRegister objectForKey:[self.url absoluteString]];
//        // then, try to load the file
//        if (filepath != nil)
//            self.image = [[UIImage alloc] initWithContentsOfFile:filepath];
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


- (void)start:(id)target action:(SEL)action
{    
    self.target = target;
    self.action = action;
    
    [[YasoundDataCacheImageManager main] addItem:self];
}

- (void)updateTimestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
    NSDate* now = [NSDate date];
    NSString* dateStr = [formatter stringFromDate:now];

    [[YasoundDataCacheImageManager main].db executeUpdate:@"UPDATE imageRegister SET last_access=? WHERE url=?", dateStr, [self.url absoluteString]];
    
    [formatter release];
}



 


- (void)launch
{
    self.isDownloading = YES;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) 
    {
        NSLog(@"YasoundDataCache requestImageToServer : connection did fail!");
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
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [[YasoundDataCacheImageManager main] loop];    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading for image %@", self.url);

    self.image = [[UIImage alloc] initWithData:self.receivedData];
    
    // we want to store the image on disk.
    
    // set the cache directory
    if (_cacheDirectory == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        _cacheDirectory = [paths objectAtIndex:0]; 
        _cacheDirectory = [_cacheDirectory stringByAppendingPathComponent:@"images"];
        [_cacheDirectory retain];
        
        NSError* error;
        BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        // something went wront
        if (!res)
        {
            _cacheDirectory = nil;
            
            NSLog(@"error creating the cache directory! Error - %@", [error localizedDescription]);
        }
    }
    
    // get a unique filepath and store the file
    if (_cacheDirectory != nil)
    {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        NSString* filePath = [_cacheDirectory stringByAppendingPathComponent:(NSString *)newUniqueIdString];
        
        NSError* error;
        BOOL res = [self.receivedData writeToFile:filePath options:NSAtomicWrite error:&error];

        // something went wront
        if (!res)
        {
            NSLog(@"error writing the file '%@'! Error - %@", filePath, [error localizedDescription]);
        }
        
        // everything's fine. write the info down to the image register
        else
        {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
            NSDate* now = [NSDate date];
            NSString* dateStr = [formatter stringFromDate:now];
            //NSDate *date = [formatter dateFromString:score.datetime];
            
            
            [[YasoundDataCacheImageManager main].db executeUpdate:@"INSERT INTO imageRegister VALUES (?,?,?,?)", [self.url absoluteString], filePath, dateStr, self.receivedData.length];
            
            [formatter release];
            
//            NSMutableDictionary* imageRegister = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"imageRegister"]];
//            
//            // the info is : the filepath for the url as the key
//            [imageRegister setObject:filePath forKey:[self.url absoluteString]];
//            [[NSUserDefaults standardUserDefaults] setObject:imageRegister forKey:@"imageRegister"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            
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
