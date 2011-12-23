//
//  KeywordsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "KeywordsViewController.h"


@implementation KeywordsViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"KeywordsView_title", nil);
  
        UIBarButtonItem* editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)];
        self.navigationItem.rightBarButtonItem = editBtn;
        
        _firstRowIsNotValidated = NO;
        
        _keywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundKeywords"];
        if (_keywords == nil)
            _keywords = [[NSMutableArray alloc] init];
        
        [_keywords retain];
    }
  
  return self;
}


- (void)dealloc
{
    [_keywords release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}







#pragma mark - View lifecycle


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
    // Return YES for supported orientations
  return YES;
}



//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];  
//}






- (void)viewWillDisappear:(BOOL)animated 
{
  [super viewWillDisappear:animated];
}




#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
        return 1;
    
    NSInteger nbRows = [_keywords count];
    if (_firstRowIsNotValidated == YES)
        nbRows++;
    return nbRows;
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) || ((indexPath.section == 1) && (indexPath.row == 0) && _firstRowIsNotValidated))
        return UITableViewCellEditingStyleNone;
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    NSInteger index = indexPath.row;
    if (index < 0)
      return;
    
      [_keywords removeObjectAtIndex:index];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
  }
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == 1) && (indexPath.row == 0) && (_firstRowIsNotValidated == YES))
    {
        _textField.placeholder = NSLocalizedString(@"KeywordsView_textfield_placeholder", nil);
        return _cellTextField;
    }

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.text = NSLocalizedString(@"KeywordsView_add_label", nil);
        return cell;
    }
    
    cell.textLabel.text = [_keywords objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
  
    return cell;
}






#pragma mark - UITableViewDelegate


// cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
        return;
    
    _firstRowIsNotValidated = YES;
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    
    _firstRowIsNotValidated = NO;

    [_keywords insertObject:[NSString stringWithString:textField.text] atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_keywords forKey:@"MyYasoundKeywords"];
    
    textField.text = @"";
    textField.placeholder = NSLocalizedString(@"KeywordsView_textfield_placeholder", nil);
    [_tableView reloadData];
    
    return FALSE;
}




#pragma mark - IBActions

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onEdit:(id)sender
{
    if ([_keywords count] == 0)
        return;
    [_tableView setEditing:!(_tableView.editing)];
}





@end
