//
//  ShareModalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareModalViewController : UIViewController
{
    IBOutlet UITableViewCell* _cellFacebook;
    IBOutlet UITableViewCell* _cellTwitter;
    IBOutlet UITableViewCell* _cellPublishButton;
    IBOutlet UITableViewCell* _cellEmail;
    IBOutlet UITableViewCell* _cellEmailButton;
    
    IBOutlet UILabel* _labelFacebook;
    IBOutlet UILabel* _labelTwitter;
    IBOutlet UILabel* _labelPublishButton;
    IBOutlet UILabel* _labelEmail;
    IBOutlet UILabel* _labelEmailButton;
    
    IBOutlet UISwitch* _switchFacebook;
    IBOutlet UISwitch* _switchTwitter;

    IBOutlet UIButton* _buttonPublish;
    IBOutlet UIButton* _buttonEmail;
    
    IBOutlet UITextView* _textFacebook;
    IBOutlet UITextView* _textTwitter;
    
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _cancel;

}

@property (nonatomic, retain) NSString* song;
@property (nonatomic, retain) NSString* artist;
@property (nonatomic, retain) NSURL* pictureUrl;
@property (nonatomic, retain) NSURL* fullLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(NSString*)aSong andArtist:(NSString*)anArtist;


@end
