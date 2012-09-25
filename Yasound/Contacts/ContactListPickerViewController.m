//
//  ContactListPickerViewController.m
//  Yasound
//
//  Created by mat on 24/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ContactListPickerViewController.h"

@implementation ContactListPickerViewController

- (id)initWithContacts:(NSArray*)contacts
{
    self = [super init];
    if (self)
    {
        _contacts = contacts;
        [_contacts retain];
        _selectedContacts = [[NSMutableSet alloc] initWithArray:_contacts];
        
        _checkmarkImage = [UIImage imageNamed:@"GrayCheckmark.png"];
        [_checkmarkImage retain];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableview cellForRowAtIndexPath:indexPath];
    
    Contact* contact = [_contacts objectAtIndex:indexPath.row];
    if ([_selectedContacts containsObject:contact])
    {
        DLog(@"deselect %@ %@", contact.firstName, contact.lastName);
        [_selectedContacts removeObject:contact];
        [self checkmark:cell with:NO];
    }
    else
    {
        DLog(@"select %@ %@", contact.firstName, contact.lastName);
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
