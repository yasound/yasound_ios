//
//  SongCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongCatalog : NSObject
{
    NSCharacterSet* _numericSet;
    NSCharacterSet* _lowerCaseSet;
    NSCharacterSet* _upperCaseSet;
}

@property (nonatomic, retain) NSMutableDictionary* alphabeticRepo;
@property (nonatomic, retain) NSMutableDictionary* artistsRepo;
@property (nonatomic, retain) NSArray* artistsRepoKeys;
@property (nonatomic, retain) NSMutableArray* artistsIndexSections;
@property (nonatomic, retain) NSMutableArray* indexMap;


- (void)buildWithSource:(NSDictionary*)source;


@end
