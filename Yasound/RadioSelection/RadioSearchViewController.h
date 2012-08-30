//
//  RadioSearchViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"


@interface RadioSearchViewController : YaViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    IBOutlet UISearchDisplayController* _searchController;
  
  NSArray* _radios;
  NSArray* _radiosByCreator;
  NSArray* _radiosBySong;
  
  BOOL _viewVisible;
}


@end
