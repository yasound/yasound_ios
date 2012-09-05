//
//  DB.m
//  astrosurf
//
//  Created by LOIC BERTHELOT on 13/04/12.
//  Copyright (c) 2012 loïc berthelot. All rights reserved.
//

#import "DB.h"
//#import "Settings.h"

@implementation DB

@synthesize db;
@synthesize cacheDirectory;


static DB* _main;

+ (DB*)main
{
    if (_main == nil)
    {
        _main = [[DB alloc] init];
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


- (void)dealloc
{
    [self.db close];
    [self.db release];
    [super dealloc];
}


+ (NSString*)shortString:(NSString*)source
{
    if (source.length < (23))
        return source;
    
    NSString* begin = [source substringToIndex:7];
    NSString* end = [source substringFromIndex:(source.length - 16)];
    
    NSString* shortstring = [NSString stringWithFormat:@"%@[...]%@", begin, end];
    return shortstring;
}


- (void)dumpImages
{
    NSLog(@"\nDB imageRegister dump:");
    
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM imageRegister"];
    while ([s next]) 
    {
        // return the filepath
        NSString* url = [DB shortString:[s stringForColumnIndex:0]];
        NSString* postKey = [DB shortString:[s stringForColumnIndex:1]];
        NSString* author = [DB shortString:[s stringForColumnIndex:2]];
        
        NSLog(@"url(%@)  postKey(%@)   author(%@)", url, postKey, author);
    }
    
    NSLog(@"----------------------------------\n");
}


- (void)dump
{
    NSLog(@"\nDB images dump:");
    
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM images"];
    while ([s next]) 
    {
        // return the filepath
        NSString* url = [DB shortString:[s stringForColumnIndex:0]];
        NSString* filepath = [DB shortString:[s stringForColumnIndex:1]];
        NSDate* date = [s dateForColumnIndex:2];
        NSInteger filesize = [s intForColumnIndex:3];
        
        NSLog(@"url(%@)  filepath(%@)   date(%@)    filesize(%d)", url, filepath, date, filesize);
    }
    
    NSLog(@"----------------------------------\n");

    
    
    [self dumpImages];


    NSLog(@"\nDB messages dump:");
    
    s = [self.db executeQuery:@"SELECT * FROM messages"];
    while ([s next]) 
    {
        // return the filepath
        NSInteger messageId = [s intForColumnIndex:0];
        NSString* postKey = [DB shortString:[s stringForColumnIndex:1]];
        NSString* author = [DB shortString:[s stringForColumnIndex:2]];
        NSString* replyNum = [DB shortString:[s stringForColumnIndex:3]];
        NSString* emoticon = [DB shortString:[s stringForColumnIndex:4]];
        NSDate* pubDate = [s dateForColumnIndex:5];
        NSString* text = [DB shortString:[s stringForColumnIndex:6]];
//        NSString* subject = [DB shortString:[s stringForColumnIndex:7]];
        //        NSString* forumKey = [DB shortString:[s stringForColumnIndex:8]];
        //        NSString* topic = [DB shortString:[s stringForColumnIndex:9]];
        
        
        NSLog(@" id %d   postKey(%@)   author(%@)    replyNum(%@)    pubDate(%@)  emoticon, text, subject, forumKey, topic", messageId, postKey, author, replyNum, pubDate);
    }
    
    NSLog(@"----------------------------------\n");
    
    
//    NSLog(@"\nDB users dump:");
//    
//    s = [self.db executeQuery:@"SELECT * FROM users"];
//    while ([s next]) 
//    {
//        // return the filepath
//        NSString* name = [s stringForColumnIndex:0];
//        NSString* profileUrl = [DB shortString:[s stringForColumnIndex:1]];
//        
//        NSLog(@" name %@   profileUrl %@", name, profileUrl);
//    }
//    
//    NSLog(@"----------------------------------\n");
    
}


- (void)initDB
{
    // registered size accu
    
    
    // set the cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    
    self.cacheDirectory = [paths objectAtIndex:0]; 

    if (self.cacheDirectory == nil)
    {
        NSLog(@"cache directory is nil!");
        assert(0);
    }
    
    self.cacheDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"images"];
    

    
    NSError* error;
    BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    // something went wront
    if (!res)
    {
        self.cacheDirectory = nil;
        NSLog(@"error creating the cache directory! Error - %@", [error localizedDescription]);
    }
    
    
    // create the DB file
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* dbPath = [paths objectAtIndex:0]; 
    dbPath = [dbPath stringByAppendingPathComponent:@"cache.db"];
    
    self.db = [FMDatabase databaseWithPath:dbPath];
    if (![self.db open]) 
    {
        NSLog(@"error : could not open the db file.");
        [self.db release];
    }      
    else 
    {
        NSLog(@"database create images table");
        BOOL res = [self.db executeUpdate:@"CREATE TABLE images (url VARCHAR(255), filepath VARCHAR(255), last_access TIMESTAMP, filesize INTEGER)"];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        else
        {
            res = [self.db executeUpdate:@"CREATE INDEX urlIndex ON images (url)"];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        }

        NSLog(@"database create imageRegister table");
        res = [self.db executeUpdate:@"CREATE TABLE imageRegister (url VARCHAR(255), postKey VARCHAR(255), author VARCHAR(255))"];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);

        NSLog(@"database create messages table");
        res = [self.db executeUpdate:@"CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, postKey VARCHAR(255), author VARCHAR(255), replyNum VARCHAR(4), emoticon VARCHAR(32), pubDate TIMESTAMP, text TEXT, subject VARCHAR(255), forumKey VARCHAR(32), topic VARCHAR(32))"];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);

//        NSLog(@"database create users table");
//        res = [self.db executeUpdate:@"CREATE TABLE users (name VARCHAR(255), profileUrl VARCHAR(255))"];
//        if (!res)
//            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
}
}


//BOOL res = [self.db tableExists:@"images"];
//if (!res)
//{
//    NSLog(@"create database images table");
//    [self.db executeUpdate:@"CREATE TABLE images (url VARCHAR(255), filepath VARCHAR(255), last_access timestamp, filesize INTEGER)"];
//}



- (void)resetDB
{
    // delete the cache directory
    NSError* error;
    BOOL res = [[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectory error:&error];
    if (!res)
    {
        NSLog(@"error deleting the cache directory! Error - %@", [error localizedDescription]);
        assert(0);
    }
    
    // delete db file
    [self.db close];
    

    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* dbPath = [paths objectAtIndex:0]; 
    dbPath = [dbPath stringByAppendingPathComponent:@"cache.db"];
    
    res = [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
    if (!res)
    {
        NSLog(@"error deleting the DB file! Error - %@", [error localizedDescription]);
        assert(0);
    }
    
    // reset the cache size
    [Settings main].cacheSize = 0;
    [[Settings main] save];
    
    // and init the whole thing again... 
    [self initDB];
}


- (void)registerImage:(NSString*)url forPost:(NSString*)postKey fromAuthor:(NSString*)author
{
#ifdef LOG_DB
    NSLog(@"DB registerImage:%@ for %@ from %@", [DB shortString:url], postKey, author);
#endif
    
    [self.db beginTransaction];
    [self.db executeUpdate:@"INSERT INTO imageRegister VALUES (?,?,?)", url, postKey, author];    
    [self.db commit];
}

- (BOOL)isImageRegistered:(NSString*)url forPost:(NSString*)postKey fromAuthor:(NSString*)author
{
#ifdef LOG_DB
    NSLog(@"DB isImageRegistered:%@ for post %@ from author %@", [DB shortString:url], postKey, author);
#endif

    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM imageRegister WHERE postKey=? AND url=? AND author=?", postKey, url, author];
    if ([s next]) 
    {
#ifdef LOG_DB
        NSLog(@"YES");
#endif
        return YES;
    }

    
#ifdef LOG_DB
    NSLog(@"NO");
#endif
    return NO;
}



// return array of registered images for the given postKey
- (NSArray*)registeredImages:(NSString*)postKey
{
    NSMutableArray* results = [NSMutableArray array];
                               
    // is the image has already been cached?
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM imageRegister WHERE postKey=?", postKey];
    while ([s next]) 
    {
        NSString* url = [s stringForColumnIndex:0];
        [results addObject:url];
    }
    
    
    
    return results;
}


- (NSArray*)registeredPostKeys:(NSString*)url
{
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM imageRegister WHERE url=?", url];
    while ([s next]) 
    {
        NSString* postKey = [s stringForColumnIndex:1];
        [results addObject:postKey];
    }
    
    return results;
}



- (NSArray*)registeredImagesFromAuthor:(NSString*)author
{
    NSMutableArray* results = [NSMutableArray array];
    
    // is the image has already been cached?
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM imageRegister WHERE author=?", author];
    while ([s next]) 
    {
        NSString* url = [s stringForColumnIndex:0];
        [results addObject:url];
    }
    
    return results;
}



- (NSString*)getImage:(NSString*)url
{
    // is the image has already been cached?
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM images WHERE url=?", url];
    if (![s next]) 
        return nil;

    // return the filepath
    NSString* filepath = [s stringForColumnIndex:1];
    
    // and update the timestamp
    NSDate* now = [NSDate date];
    [self.db executeUpdate:@"UPDATE images SET last_access=? WHERE url=?", now, url];
    
#ifdef LOG_DB
    NSLog(@"DB getImage:%@ => %@", [DB shortString:url], [DB shortString:filepath]);
#endif
    
    return filepath;
}



- (NSString*)setImage:(NSData*)imageData forUrl:(NSString*)url
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString* filePath = [self.cacheDirectory stringByAppendingPathComponent:(NSString *)newUniqueIdString];

    NSError* error;
    BOOL res = [imageData writeToFile:filePath options:NSAtomicWrite error:&error];

    // something went wront
    if (!res)
    {
        NSLog(@"error writing the file '%@'! Error - %@", filePath, [error localizedDescription]);
        assert(0);
        return nil;
    }

    // everything's fine. write the info down to the image register
        NSDate* now = [NSDate date];
        
    [self.db beginTransaction];
        [self.db executeUpdate:@"INSERT INTO images VALUES (?,?,?,?)", url, filePath, now, [NSNumber numberWithInt:imageData.length]];
    [self.db commit];
        
        // and update the cache size count
        [Settings main].cacheSize = [Settings main].cacheSize + imageData.length;

        // check if GC is necessary
        [self startGC];
        
        // save the settings
        [[Settings main] save];
    
#ifdef LOG_DB
    NSLog(@"DB setImage:%@ => %@   for size:%d", [DB shortString:url], [DB shortString:filePath], imageData.length);
#endif
    
        
    return filePath;
}





- (void)startGC
{
    NSLog(@"GC check : cacheSize %d < cacheMaxSize %d", [Settings main].cacheSize, [Settings main].cacheMaxSize);
    
    if ([Settings main].cacheSize < [Settings main].cacheMaxSize)
        return;
    
    NSLog(@"DB start Garbage Collector : current size %d vs max size %d", [Settings main].cacheSize, [Settings main].cacheMaxSize);
    
    // get all the registered images, ordered from the oldest one to the newer one
    FMResultSet* s = [db executeQuery:@"SELECT * FROM images ORDER BY last_access ASC"];
    BOOL done = NO;
    NSInteger counter = 0;
    
    [self.db beginTransaction];

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
            NSLog(@"error deleting the file from the cache disk! Error - %@", [error localizedDescription]);
            continue;
        }
        
        // remove the entry from the DB
        [db executeUpdate:@"DELETE FROM images WHERE url=?", url];
        [db executeUpdate:@"DELETE FROM imageRegister WHERE url=?", url];

        // do we need some more?
        [Settings main].cacheSize = [Settings main].cacheSize  - filesize;
        done = ([Settings main].cacheSize < [Settings main].cacheMaxSize);
        
        counter++;
        NSLog(@"deleted file %@ for url %@", filepath, url);
    }
    
    [self.db commit];

    
    NSLog(@"\ndeleted %d files", counter);
    
    
    
    // extreme case : there were error in deleting the files, and the cache is still over the limit
    // dont have a choice, we have to delete the whole thing
    if ([Settings main].cacheSize > [Settings main].cacheMaxSize)
    {
        NSLog(@"extreme case! we are still above the limit : %d vs %d", [Settings main].cacheSize, [Settings main].cacheMaxSize);
        NSLog(@"reset the DB and cache!");
        [self resetDB];
    }
    
    
}


- (void)clearForPost:(NSString*)postKey
{
    NSArray* registeredImages = [self registeredImages:postKey];
    
    NSLog(@"DB::clearForPost %@", postKey);
    
    for (NSString* url in registeredImages)
    {
        [self.db beginTransaction];
        
        [self.db executeUpdate:@"DELETE FROM imageRegister WHERE url=? AND postKey=?", url, postKey];
        [self.db commit];
        
        NSArray* registeredPostKeys = [self registeredPostKeys:url];
        if (registeredPostKeys.count == 0)
        {
            NSString* filepath = [self getImage:url];
            BOOL res = [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
            if (!res)
                NSLog(@"error deleting the file %@", filepath);
            
            [self.db beginTransaction];
            [self.db executeUpdate:@"DELETE FROM images WHERE url=?", url];
            [self.db commit];
            

        }
    }

}




- (void)clearCache
{
    
}




- (void)setMessageForPostKey:(NSString*)postKey replyNum:(NSString*)replyNum author:(NSString*)author emoticon:(NSString*)emoticon pubDate:(NSDate*)pubDate text:(NSString*)text subject:(NSString*)subject forumKey:(NSString*)forumKey topic:(NSString*)topic
{
    [self.db beginTransaction];
    
    NSInteger messageId = [self messageIdForPostKey:postKey andReplyNum:replyNum];
    BOOL res = YES;
    if (messageId < 0)
    {
        res = [self.db executeUpdate:@"INSERT INTO messages VALUES (NULL,?,?,?,?,?,?,?,?,?)", postKey, author, replyNum, emoticon, pubDate, text, subject, forumKey, topic];
        NSLog(@"DB setMessageForPostKey (INSERT):%@ replyNum %@ author %@ pubDate %@  subject %@   forumKey %@   topic %@" , postKey, replyNum, author, pubDate, subject, forumKey, topic);
    }
    else
    {
        res = [self.db executeUpdate:@"UPDATE messages SET text = ? WHERE id = ?", text, [NSNumber numberWithInteger:messageId]];    
        NSLog(@"DB setMessageForPostKey (UPDATE):%@ replyNum %@ author %@ pubDate %@   subject %@   forumKey %@  topic %@", postKey, replyNum, author, pubDate, subject, forumKey, topic);
    }
    
    if (!res)
    {
        NSLog(@"error writing the DB!");
        NSLog(@"Error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);        
    }
    
    [self.db commit];    
    
}


- (NSDictionary*)messageForPostKey:(NSString*)postKey andReplyNum:(NSString*)replyNum
{
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM messages WHERE postKey=? AND replyNum=?", postKey, replyNum];
    if (![s next]) 
        return nil;
    
    NSString* author = [s stringForColumnIndex:2];
    NSString* emoticon = [s stringForColumnIndex:4];
    NSDate* pubDate = [s dateForColumnIndex:5];
    NSString* text = [s stringForColumnIndex:6];
    NSString* subject = [s stringForColumnIndex:7];
    NSString* forumKey = [s stringForColumnIndex:8];
    NSString* topic = [s stringForColumnIndex:9];

    NSMutableDictionary* dico = [NSMutableDictionary dictionary];
    
    [dico setObject:postKey forKey:@"postKey"];
    [dico setObject:author forKey:@"author"];
    [dico setObject:replyNum forKey:@"replyNum"];
    [dico setObject:emoticon forKey:@"emoticon"];
    [dico setObject:pubDate forKey:@"pubDate"];
    [dico setObject:text forKey:@"text"];
    [dico setObject:subject forKey:@"subject"];
    [dico setObject:forumKey forKey:@"forumKey"];
    [dico setObject:topic forKey:@"topic"];
    
    return dico;
}


- (NSInteger)messageIdForPostKey:(NSString*)postKey andReplyNum:(NSString*)replyNum
{
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM messages WHERE postKey=? AND replyNum=?", postKey, replyNum];
    if (![s next]) 
        return -1;
    
    NSInteger messageId = [s intForColumnIndex:0];
    return messageId;
}







//- (void)setUser:(NSString*)name withProfileUrl:(NSString*)profileUrl
//{
//    [self.db beginTransaction];
//    
//    [db executeUpdate:@"DELETE FROM users WHERE name=?", name];
//    
//    BOOL res = [self.db executeUpdate:@"INSERT INTO users VALUES (?,?)", name, profileUrl];
//    NSLog(@"DB setUser (INSERT) name %@  profileUrl %@" , name, profileUrl);
//
//    if (!res)
//    {
//        NSLog(@"error writing the DB!");
//        NSLog(@"Error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);        
//    }
//    
//    [self.db commit];    
//}
//
//
//- (NSString*)getProfileUrlForUser:(NSString*)name
//{
//    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM users WHERE name=?", name];
//    if (![s next]) 
//        return nil;
//
//    NSString* profileUrl = [s stringForColumnIndex:1];
//    return profileUrl;
//}




@end

