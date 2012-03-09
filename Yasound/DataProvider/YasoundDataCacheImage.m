//
//  YasoundDataCacheImage.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundDataCacheImage.h"





@implementation YasoundDataCacheImageTarget
@synthesize target;
@synthesize action;
@end





@implementation YasoundDataCacheImage

@synthesize url;
@synthesize timeout;
@synthesize timer;
@synthesize image;
@synthesize targets;
@synthesize receivedData;


- (id)initWithUrl:(NSURL*)aUrl
{
    if (self = [super init])
    {
        self.url = aUrl;
        self.targets = [[NSMutableArray alloc] init];
        self.timeout = NO;
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
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) 
    {
        NSLog(@"YasoundDataCache requestImageToServer : connection did fail!");
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
    [connection release];
    [self.receivedData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.image = [[UIImage alloc] initWithData:self.receivedData];

    // callback
    for (YasoundDataCacheImageTarget* t in self.targets)
    {
        if ((t.target != nil) && ([t.target respondsToSelector:t.action]))
            [t.target performSelector:t.action withObject:self.image];
    }
    
    [self.targets relase];
    self.targets = nil;

    
    
    [self.receivedData release];
    self.receivedData = nil;
}



@end
