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
#import "YasoundDataProvider.h"
#import "YasoundAppDelegate.h"

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

    _defaultImage = [UIImage imageNamed:@"commonAvatarDummy.png"];
    [_defaultImage retain];

    _accessGranted = NO;
    _inSave = NO;
    _hud = nil;
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
  [_defaultImage release];

  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _selectAllButton.title = NSLocalizedString(@"SelectAll", nil);
  _unselectAllButton.title = NSLocalizedString(@"UnselectAll", nil);

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

- (void)setAllcontactsSelected:(BOOL)selected
{
  [_selectedContacts removeAllObjects];
  if (selected)
  {
    [_selectedContacts addObjectsFromArray:_contacts];
  }
  [_tableview reloadData];
}

- (IBAction)selectAllClicked:(id)sender
{
  [self setAllcontactsSelected:YES];
}

- (IBAction)unselectAllClicked:(id)sender
{
  [self setAllcontactsSelected:NO];
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

      if ([emails count] > 0)
        [contacts addObject:contact];
      else
        [contact release];
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
  return 27;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section > 26)
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
  if (contact.thumbnail != nil)
    cell.imageView.image = contact.thumbnail;
  else
    cell.imageView.image = _defaultImage;
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 0;
}


//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//
//  NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//  [tempArray addObject:@"A"];
//  [tempArray addObject:@"B"];
//  [tempArray addObject:@"C"];
//  [tempArray addObject:@"D"];
//  [tempArray addObject:@"E"];
//  [tempArray addObject:@"F"];
//  [tempArray addObject:@"G"];
//  [tempArray addObject:@"H"];
//  [tempArray addObject:@"I"];
//  [tempArray addObject:@"J"];
//  [tempArray addObject:@"K"];
//  [tempArray addObject:@"L"];
//  [tempArray addObject:@"M"];
//  [tempArray addObject:@"N"];
//  [tempArray addObject:@"O"];
//  [tempArray addObject:@"P"];
//  [tempArray addObject:@"Q"];
//  [tempArray addObject:@"R"];
//  [tempArray addObject:@"S"];
//  [tempArray addObject:@"T"];
//  [tempArray addObject:@"U"];
//  [tempArray addObject:@"V"];
//  [tempArray addObject:@"W"];
//  [tempArray addObject:@"X"];
//  [tempArray addObject:@"Y"];
//  [tempArray addObject:@"Z"];
//  [tempArray addObject:@"#"];
//
//  return tempArray;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//  return index;
//}
//



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
  if (_inSave)
    return NO;

  _inSave = YES;
  NSMutableArray* contactData = [NSMutableArray array];
  for (Contact* c in _selectedContacts)
  {
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:c.emails, @"emails", c.firstName, @"firstName", c.lastName, @"lastName", nil];
    [contactData addObject:dict];
  }

  _hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_hud];

  // Set determinate mode
  _hud.mode = MBProgressHUDModeDeterminate;

  _hud.labelText = NSLocalizedString(@"InviteContacts.sending_invitations", nil);

  [_hud show:YES];


  [[YasoundDataProvider main] inviteContacts:contactData target:self action:@selector(contactsInvited:success:)];
  return NO;
}

- (void)contactsInvited:(ASIHTTPRequest*)req success:(BOOL)success
{
  [_hud hide:YES];
  [_hud release];

  NSDictionary* resp = [req responseDict];
  NSNumber* ok = [resp valueForKey:@"success"];
  if (!success || ok == nil || [ok boolValue] == NO)
  {
    DLog(@"contacts invitation failed   error: %@", [resp valueForKey:@"error"]);
  }

  [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
  //  _inSave = NO;
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
