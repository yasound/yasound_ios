//
//  InviteFriendsTableViewCell.m
//  Yasound
//
//  Created by mat on 24/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "InviteFriendsTableViewCell.h"
#import "Theme.h"
#import <AddressBook/AddressBook.h>
#import "Contact.h"
#import "InviteContactsViewController.h"
#import "InviteTwitterFriendsViewController.h"
#import "InviteFacebookFriendsViewController.h"
#import "YasoundAppDelegate.h"
#import "UserSettings.h"
#import "YasoundSessionManager.h"

@implementation InviteFriendsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // facebook
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _facebookImage = [sheet makeImage];
            [self addSubview:_facebookImage];
            
            // draw circle mask
            _facebookImage.layer.masksToBounds = YES;
            _facebookImage.layer.cornerRadius = _facebookImage.frame.size.width / 2.f;
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIButton* mask = [sheet makeButton];
            [mask addTarget:self action:@selector(onFacebookButtonActivated:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:mask];
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"InviteFriendsRow.facebookLabel", nil);
            [self addSubview:label];
            
            BOOL facebookEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK];
            mask.enabled = facebookEnabled;
        }
        
        // twitter
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.twitterImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _twitterImage = [sheet makeImage];
            [self addSubview:_twitterImage];
            
            // draw circle mask
            _twitterImage.layer.masksToBounds = YES;
            _twitterImage.layer.cornerRadius = _twitterImage.frame.size.width / 2.f;
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.twitterMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIButton* mask = [sheet makeButton];
            [mask addTarget:self action:@selector(onTwitterButtonActivated:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:mask];
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.twitterLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"InviteFriendsRow.twitterLabel", nil);
            [self addSubview:label];
            
            BOOL twitterEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER];
            mask.enabled = twitterEnabled;
        }
        
        // email
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.emailImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _emailImage = [sheet makeImage];
            [self addSubview:_emailImage];
            
            // draw circle mask
            _emailImage.layer.masksToBounds = YES;
            _emailImage.layer.cornerRadius = _emailImage.frame.size.width / 2.f;
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.emailMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIButton* mask = [sheet makeButton];
            [mask addTarget:self action:@selector(onEmailButtonActivated:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:mask];
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.emailLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"InviteFriendsRow.emailLabel", nil);
            [self addSubview:label];
        }
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // do nothing
}

- (void)onFacebookButtonActivated:(id)sender
{
    DLog(@"Facebook button clicked");
    
    InviteFacebookFriendsViewController* controller = [[InviteFacebookFriendsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)onTwitterButtonActivated:(id)sender
{
    DLog(@"Twitter button clicked");
    
    InviteTwitterFriendsViewController* controller = [[InviteTwitterFriendsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)onEmailButtonActivated:(id)sender
{
    DLog(@"Email button clicked");    
    InviteContactsViewController* controller = [[InviteContactsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}


@end
