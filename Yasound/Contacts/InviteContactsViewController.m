//
//  InviteContactsViewController.m
//  Yasound
//
//  Created by mat on 24/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "InviteContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import "UserSettings.h"

@implementation InviteContactsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        _contacts = nil;
        
        _selectedContacts = [[NSMutableSet alloc] init];
        
        _checkmarkImage = [UIImage imageNamed:@"GrayCheckmark.png"];
        [_checkmarkImage retain];
        
        _accessGranted = NO;
    }
    return self;
}

- (void)dealloc
{
    if (_contacts)
        [_contacts release];
    if (_selectedContacts)
        [_selectedContacts release];
    
    [_checkmarkImage release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    { // we're on iOS6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    { // we're on iOS5 or older
        BOOL error;
        accessGranted = [[UserSettings main] boolForKey:USKEYuserAllowsAccessToContacts error:&error];
        
        if (!accessGranted)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AllowContacts.title", nil) message:NSLocalizedString(@"AllowContacts.message", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"AllowContacts.yes", nil)
                                                  otherButtonTitles:NSLocalizedString(@"AllowContacts.no", nil), nil];
            [alert show];
            [alert release];
        }
    }
    
    if (accessGranted)
        [self setAccess:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accessGranted = (buttonIndex == 0);
    [[UserSettings main] setBool:accessGranted forKey:USKEYuserAllowsAccessToContacts];
    
    [self setAccess:accessGranted];
}

- (void)loadContacts
{
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
    
    _contacts = contacts;
    [_contacts retain];
    
    [_selectedContacts removeAllObjects];
    [_selectedContacts addObjectsFromArray:_contacts];
    
    [_tableview reloadData];
}

- (void)setAccess:(BOOL)granted
{
    _accessGranted = granted;
    
    if (_accessGranted)
    {
        _accessNotGrantedLabel.hidden = YES;
        _tableview.hidden = NO;
        [self loadContacts];
    }
    else
    {
        _tableview.hidden = YES;
        _accessNotGrantedLabel.hidden = NO;
        _accessNotGrantedLabel.text = NSLocalizedString(@"InviteContacts.accessNotGrantedLabel", nil);
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section > 0)
        return 0;
    if (!_contacts)
        return 0;    
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    Contact* contact = [_contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    cell.imageView.image = contact.thumbnail;
    BOOL selected = [_selectedContacts containsObject:contact];
    [self checkmark:cell with:selected];
    
    return cell;
}

- (void)checkmark:(UITableViewCell*)cell with:(BOOL)value
{
    if (value)
    {
        UIImageView* checkmark = [[UIImageView alloc] initWithImage:_checkmarkImage];
        cell.accessoryView = checkmark;
        [checkmark release];
    }
    else
        cell.accessoryView = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableview cellForRowAtIndexPath:indexPath];
    
    Contact* contact = [_contacts objectAtIndex:indexPath.row];
    if ([_selectedContacts containsObject:contact])
    {
        [_selectedContacts removeObject:contact];
        [self checkmark:cell with:NO];
    }
    else
    {
        [_selectedContacts addObject:contact];
        [self checkmark:cell with:YES];
    }
}


#pragma mark - Top bar delegate

- (BOOL)topBarSave
{
    return YES;
}

- (BOOL)topBarCancel
{
    return YES;
}

- (BOOL)shouldShowActionButton
{
    return YES;
}

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"ContactListPicker.SendButton", nil);
}

- (NSString*)titleForCancelButton
{
    return NSLocalizedString(@"ContactListPicker.CancelButton", nil);
}

- (NSString*)topBarModalTitle
{
    return NSLocalizedString(@"ContactListPickerTitle", nil);
}

@end
