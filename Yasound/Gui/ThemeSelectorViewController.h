//
//  ThemeSelectorViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThemeSelectorDelegate <NSObject>
@required
- (void)themeSelected:(NSString*)theme;
- (void)themeSelectionCanceled;
@end


@interface ThemeSelectorViewController : UIViewController
{
    IBOutlet UILabel* _themeSelectorTitle;
    IBOutlet UITableView* _tableView;
    
    NSArray* _themes;
}

@property (nonatomic, retain) id<ThemeSelectorDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)target;

- (IBAction)onCancel:(id)sender;

@end
