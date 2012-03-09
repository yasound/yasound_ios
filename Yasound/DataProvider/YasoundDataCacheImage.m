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
    }
    return self;
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
@synthesize timeout;
@synthesize timer;
@synthesize image;
@synthesize targets;
@synthesize receivedData;
@synthesize failed;



- (id)initWithUrl:(NSURL*)aUrl
{
    if (self = [super init])
    {
        self.url = aUrl;
        self.targets = [[NSMutableArray alloc] init];
        self.timeout = NO;
        self.failed = NO;
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
    self.failed = NO;
    
    [[YasoundDataCacheImageManager main] addItem:self];
}
 


- (void)launch
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) 
    {
        NSLog(@"YasoundDataCache requestImageToServer : connection did fail!");
        failed = YES;
        
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
    self.failed = YES;
    
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
    
    

    // callback
    for (YasoundDataCacheImageTarget* t in self.targets)
    {
        if ((t.target != nil) && ([t.target respondsToSelector:t.action]))
            [t.target performSelector:t.action withObject:self.image];
    }
    
    [self.targets release];
    self.targets = nil;

    
    
    [self.receivedData release];
    self.receivedData = nil;
    
    [[YasoundDataCacheImageManager main] loop];    
}



@end
