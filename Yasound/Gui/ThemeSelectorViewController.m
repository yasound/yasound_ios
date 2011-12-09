//
//  ThemeSelectorViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ThemeSelectorViewController.h"
#import "Theme.h"

@implementation ThemeSelectorViewController

@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        _themes = [resources objectForKey:@"themes"];
        if (_themes == nil)
        {
            NSLog(@"could not find themes list in the info file");
            assert(0);
        }
        else
            [_themes retain];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_themes release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _themeSelectorTitle.text = NSLocalizedString(@"themeselector_title", nil);    
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









#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [_themes count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary* dico = [_themes objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Theme* theme = [[Theme alloc] initWithBundleName:[dico objectForKey:@"bundle"]];
    cell.textLabel.text = theme.name;
    NSString* description = theme.description;
    cell.detailTextLabel.text = description;
    [cell.imageView setImage:theme.icon];
    [theme release];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dico = [_themes objectAtIndex:indexPath.row];
    
    [self.delegate themeSelected:[dico objectForKey:@"id"]];
}









#pragma mark - IBActions


- (IBAction)onCancel:(id)sender
{
    [self.delegate themeSelectionCanceled];
}





@end
