//
//  SongsViewController.h
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"

@interface SongsViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* _tableView;  
}

-(IBAction)onBack:(id)sender;
@end
