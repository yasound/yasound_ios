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
        _themeSelectorTitle.text = NSLocalizedString(@"themeselector_title", nil);
        
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
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary* dico = [_themes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithString:NSLocalizedString([dico objectForKey:@"name"], nil)];
    cell.detailTextLabel.text = [NSString stringWithString:NSLocalizedString([dico objectForKey:@"description"], nil)];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    NSString* iconPath = [NSString stringWithFormat:@"%@.icon.png", [dico objectForKey:@"bundle"]];
//    
////    NSLog(iconPath);
//    
////    [cell.imageView setImage:[UIImage imageWithContentsOfFile:iconPath]];
//    [cell.imageView setImage:[UIImage imageNamed:iconPath]];

    
    Theme* theme = [[Theme alloc] initWithName:[dico objectForKey:@"bundle"]];
    [cell.imageView setImage:[theme icon]];
    [theme release];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dico = [_themes objectAtIndex:indexPath.row];
    
    [self.delegate themeSelected:[dico objectForKey:@"bundle"]];
}









#pragma mark - IBActions


- (IBAction)onCancel:(id)sender
{
    [self.delegate themeSelectionCanceled];
}





@end
