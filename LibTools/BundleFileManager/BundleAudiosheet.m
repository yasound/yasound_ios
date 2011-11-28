//
//  BundleAudiosheet.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleAudiosheet.h"
#import "BundleFileManager.h"


@implementation BundleAudiosheet

@synthesize audioPath = _audioPath;
@synthesize ldPath = _ldPath;
@synthesize name = _name;
@synthesize shortname = _shortname;



- (id)initWithSheet:(NSDictionary*)sheet bundle:(BundleFileManager*)bundle error:(NSError**)anError
{
  self = [super init];
  
  NSString* localAudioPath = [sheet valueForKey:@"audioPath"];
  _audioPath = [[NSString alloc] initWithString:[bundle audioNamed:localAudioPath]];  

  NSString* localLdPath = [sheet valueForKey:@"ldPath"];
  _ldPath = [[NSString alloc] initWithString:[bundle audioNamed:localLdPath]];  

  _name = [[NSString alloc] initWithString:[sheet valueForKey:@"name"]];  
  _shortname = [[NSString alloc] initWithString:[sheet valueForKey:@"shortname"]];  

  // error handling
  if (_audioPath == nil)
    return [BundleFileManager errorHandling:@"audio" forPath:localAudioPath error:anError];

  // error handling
  if (_ldPath == nil)
    return [BundleFileManager errorHandling:@"ld" forPath:localLdPath error:anError];
  
  return self;
}


@end




