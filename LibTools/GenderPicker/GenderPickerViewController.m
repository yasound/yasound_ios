//
//  GenderPickerViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "GenderPickerViewController.h"
#import "YasoundAppDelegate.h"
#import "RootViewController.h"


@implementation GenderPickerViewController

@synthesize items;
@synthesize delegate;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentItem:(NSString*)currentItem target:(id)target
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      self.delegate = target;
      
        self.items = [NSArray arrayWithObjects:@"M", @"F", nil];
      
      _startItem = currentItem;
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
  
  NSInteger i = 0;
  for (NSString* s in self.items)
  {
    if ([s isEqualToString:_startItem])
    {
      [_pickerView selectRow:i inComponent:0 animated:YES];
      break;
    }
    i++;
  }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return [self.items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return NSLocalizedString([self.items objectAtIndex:row], nil);
}


#pragma mark - IBActions

- (IBAction)onDoneClicked:(id)sender
{
  NSInteger row = [_pickerView selectedRowInComponent:0];
  NSString* item = [self.items objectAtIndex:row];
  [self.delegate genderDidSelect:item];

    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];
}

- (IBAction)onCancelClicked:(id)sender
{
    UINavigationController* cont = [self.delegate genderNavController];

    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];
}


@end
