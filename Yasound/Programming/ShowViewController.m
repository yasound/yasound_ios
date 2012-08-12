//
//  ShowViewController.m
//  Yasound
//
//  Created by neywen on 11/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ShowViewController.h"
#import "Theme.h"

@interface ShowViewController ()

@end

@implementation ShowViewController

@synthesize pickerview;
@synthesize days;
@synthesize hours;
@synthesize minutes;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSString* preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLocale* loc = [[NSLocale alloc] initWithLocaleIdentifier:preferredLang];
    [loc autorelease];
    [dateFormatter setLocale:loc];
    
    self.days = [NSMutableArray arrayWithArray:[dateFormatter weekdaySymbols]];
    [self.days insertObject:NSLocalizedString(@"Show.everyday", nil) atIndex:0];
    
    self.hours = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 10; i++)
        [self.hours addObject:[NSString stringWithFormat:@"0%d", i]];
    for (NSInteger i = 10; i < 24; i++)
        [self.hours addObject:[NSString stringWithFormat:@"%d", i]];

    self.minutes = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 10; i++)
        [self.minutes addObject:[NSString stringWithFormat:@"0%d", i]];
    for (NSInteger i = 10; i < 60; i++)
        [self.minutes addObject:[NSString stringWithFormat:@"%d", i]];
    
    [self.pickerview selectRow:12 inComponent:1 animated:NO];
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




#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
        return self.days.count;
    
    if (component == 1)
        return self.hours.count;

    return self.minutes.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0)
        return 178;
    
    if (component == 1)
        return 52;
    
    return 42;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
        return [self.days objectAtIndex:row];
    
    if (component == 1)
        return [self.hours objectAtIndex:row];
    
    return [self.minutes objectAtIndex:row];
}





#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"select");
//    float rate = [[exchangeRates objectAtIndex:row] floatValue];
//    float dollars = [dollarText.text floatValue];
//    float result = dollars * rate;
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"%.2f USD = %.2f %@", dollars, result,
//                              [countryNames objectAtIndex:row]];
//    resultLabel.text = resultString;
}








#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    
    return 1;
}




//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ((indexPath.section == 1) && (indexPath.row == 0))
//    {
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.bigButton.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        UIImageView* view = [sheet makeImage];
//        cell.backgroundView = view;
//        [view release];
//    }
//}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == 0))
    {
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        cell.backgroundView = view;
        [view release];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifierSwitch = @"CellSwitch";
    static NSString* CellIdentifier = @"Cell";
    static NSString* CellIdentifierDelete = @"CellDelete";
    
    
    if ((indexPath.section == 0) && (indexPath.row == 0))
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSwitch];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierSwitch] autorelease];
            cell.textLabel.text = NSLocalizedString(@"Show.switch.label", nil);
            
            UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectZero];
            sw.frame = CGRectMake(cell.frame.size.width - sw.frame.size.width - 16, cell.frame.size.height/2.f - sw.frame.size.height/2.f, sw.frame.size.width, sw.frame.size.height);
            [cell addSubview:sw];
            
            sw.on = YES;
        }
        
        return cell;
    }

    if ((indexPath.section == 0) && (indexPath.row == 1))
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = NSLocalizedString(@"Show.prog.label", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
        return cell;
    }
    
    

    if (indexPath.section == 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDelete];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierDelete] autorelease];
            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.bigButton.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIButton* btn = [sheet makeButton];
            [cell addSubview:btn];
            
            sheet = [[Theme theme] stylesheetForKey:@"TableView.bigButton.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"Show.delete.label", nil);
            [btn addSubview:label];
        }
        
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
//    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
//    [self.catalog selectAlbum:albumKey];
//    
//    ProgrammingAlbumViewController* view = [[ProgrammingAlbumViewController alloc] initWithNibName:@"ProgrammingAlbumViewController" bundle:nil usingCatalog:self.catalog forRadio:self.radio];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
    
}






@end
