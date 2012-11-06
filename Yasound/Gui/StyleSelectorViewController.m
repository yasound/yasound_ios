//
//  StyleSelectorViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "StyleSelectorViewController.h"
#import "Genres.h"

@implementation StyleSelectorViewController

@synthesize styles;
@synthesize delegate;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentStyle:(NSString*)currentStyle target:(id)target
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      self.delegate = target;
      
        self.styles = [Genres genres];
        assert(self.styles != nil);
      
      _startStyle = currentStyle;
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
  for (NSString* s in self.styles) 
  {
    if ([s isEqualToString:_startStyle])
    {
      [stylePickerView selectRow:i inComponent:0 animated:YES];
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
    return YES;
}



#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return [self.styles count];  
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return NSLocalizedString([self.styles objectAtIndex:row], nil);
}


#pragma mark - IBActions

- (IBAction)onDoneClicked:(id)sender
{
  NSInteger row = [stylePickerView selectedRowInComponent:0];
  NSString* style = [self.styles objectAtIndex:row];
  [self.delegate didSelectStyle:style];
  [self.delegate closeSelectStyleController];
}

- (IBAction)onCancelClicked:(id)sender
{
  [self.delegate closeSelectStyleController];
}


@end
