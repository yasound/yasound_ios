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
#import "RootViewController.h"

@implementation InviteFriendsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // facebook
        {
            BundleStylesheet* sheet;
            
            BOOL facebookEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK];
            if (facebookEnabled)
            {
                sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _facebookImage = [sheet makeImage];
                [self addSubview:_facebookImage];
            }
            else
            {
                sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookImageDisabled" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _facebookImage = [sheet makeImage];
                [self addSubview:_facebookImage];
            }
            
            
            // draw circle mask
            _facebookImage.layer.masksToBounds = YES;
            _facebookImage.layer.cornerRadius = _facebookImage.frame.size.width / 2.f;
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIButton* mask = [sheet makeButton];
            [mask addTarget:self action:@selector(onFacebookButtonActivated:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:mask];
            if (!facebookEnabled)
            {
                mask.enabled = NO;
            }
            
            sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.facebookLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"InviteFriendsRow.facebookLabel", nil);
            [self addSubview:label];
            
            
            
        }
        
        // twitter
        {
            BundleStylesheet* sheet;
            BOOL twitterEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER];
            
            if (twitterEnabled)
            {
                sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.twitterImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _twitterImage = [sheet makeImage];
                [self addSubview:_twitterImage];
            }
            else
            {
                sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.row.twitterImageDisabled" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _twitterImage = [sheet makeImage];
                [self addSubview:_twitterImage];
            }
            
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
            
            if (!twitterEnabled)
            {
                mask.enabled = NO;
            }
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
    NSNumber* animated = [NSNumber numberWithBool:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_INVITE_FACEBOOK object:animated];
}

- (void)onTwitterButtonActivated:(id)sender
{
    NSNumber* animated = [NSNumber numberWithBool:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_INVITE_TWITTER object:animated];
}

- (void)onEmailButtonActivated:(id)sender
{
    NSNumber* animated = [NSNumber numberWithBool:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_INVITE_CONTACTS object:animated];
}


@end
