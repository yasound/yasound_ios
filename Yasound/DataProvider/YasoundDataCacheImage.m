//
//  YasoundDataCacheImage.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundDataCacheImage.h"

// 30 minutes
#define TIMEOUT_IMAGE (30*60)


@implementation YasoundDataCacheImage

@synthesize url;
@synthesize timeout;
@synthesize image;
@synthesize target;
@synthesize action;
@synthesize receivedData;


- (id)initWithUrl:(NSURL*)aUrl
{
    if (self = [super init])
    {
        self.url = aUrl;
    }
    
    return self;
}



- (void)update
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
    NSDate* date = [NSDate date];
    self.timeout = [date dateByAddingTimeInterval:TIMEOUT_IMAGE];

    // callback
    if ((self.target != nil) && ([self.target respondsToSelector:self.action]))
        [self.target performSelector:self.action withObject:self.image];
    
    
    [self.receivedData release];
    self.receivedData = nil;
}



@end
