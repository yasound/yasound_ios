//
//  ProgrammingSearchYasoundViewController.h
//  Yasound
//
//  Created by mat on 18/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "RefreshIndicatorViewController.h"

@interface ProgrammingSearchYasoundViewController : RefreshIndicatorViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSArray* _searchResults;
    NSInteger _searchOffset;
    BOOL _searching;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRadio:(Radio*)r;

@property (retain, nonatomic) Radio* radio;
@property (nonatomic, retain) NSString* searchText;

@end
