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
#import "YasoundAppDelegate.h"

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
}

- (void)onTwitterButtonActivated:(id)sender
{
    DLog(@"Twitter button clicked");
}

- (void)onEmailButtonActivated:(id)sender
{
    DLog(@"Email button clicked");
    
    NSMutableArray* contacts = [NSMutableArray array];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(people), people);
    
    CFArraySortValues(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), (CFComparatorFunction) ABPersonComparePeopleByName, (void*) ABPersonGetSortOrdering());
    
    for (CFIndex i = 0; i < CFArrayGetCount(peopleMutable); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, i);
        ABMultiValueRef emailsValue = ABRecordCopyValue(person, kABPersonEmailProperty);
        if (ABMultiValueGetCount(emailsValue) > 0)
        {
            NSString* firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString* lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            UIImage* thumbnail = nil;
            if (person != nil && ABPersonHasImageData(person))
            {
                thumbnail = [UIImage imageWithData:(NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
            }
            
            NSMutableArray* emails = [NSMutableArray array];
            for (CFIndex j=0; j < ABMultiValueGetCount(emailsValue); j++)
            {
                NSString* email = (NSString*)ABMultiValueCopyValueAtIndex(emailsValue, j);
                [emails addObject:email];
                [email release];
            }
            
            Contact* contact = [[Contact alloc] init];
            contact.firstName = firstName;
            contact.lastName = lastName;
            contact.thumbnail = thumbnail;
            contact.emails = emails;
            [contacts addObject:contact];
        }
        CFRelease(emailsValue);
    }
    
    CFRelease(addressBook);
    CFRelease(people);
    CFRelease(peopleMutable);
    
    InviteContactsViewController* controller = [[InviteContactsViewController alloc] initWithContacts:contacts];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}

@end
