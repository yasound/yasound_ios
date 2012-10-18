/*
 DateViewController.m
 http://iphonedevelopment.blogspot.fr/2009/01/better-generic-date-picker.html
 */
#import "DateViewController.h"
#import "YasoundAppDelegate.h"
#import "RootViewController.h"

@implementation DateViewController
@synthesize datePicker;
@synthesize dateTableView;
@synthesize date;
@synthesize delegate;

-(IBAction)dateChanged
{
    self.date = [datePicker date];
    [dateTableView reloadData];
}
-(IBAction)cancel
{
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];
}
-(IBAction)save
{
    [self.delegate takeNewDate:date];
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];
}

- (void)loadView
{
    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = theView;
    [theView release];
    
    UIToolbar* toolbar = [self setToolbar];
    [self.view addSubview:toolbar];
    
    UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    theTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    theTableView.delegate = self;
    theTableView.dataSource = self;
    [self.view addSubview:theTableView];
    self.dateTableView = theTableView;
    theTableView.scrollEnabled = NO;
    [theTableView release];
    
    UIDatePicker *theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 200.0, 320.0, 216.0)];
    theDatePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker = theDatePicker;
    [theDatePicker release];
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    
    [self dateChanged];
    
    

    
    
}


- (UIToolbar*)setToolbar
{
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    toolbar.barStyle = UIBarStyleBlack;
    
        // set background
        if ([toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
            [toolbar setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        else
            [toolbar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];

    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem* itemSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
        // flexible space
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        
        [toolbar setItems:[NSArray arrayWithObjects:itemBack, flexibleSpace, itemSave, nil]];

    return toolbar;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (self.date != nil)
        [self.datePicker setDate:date animated:YES];
    else
        [self.datePicker setDate:[NSDate date] animated:YES];
    
    [super viewWillAppear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [datePicker release];
    [dateTableView release];
    [date release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table View Methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *DateCellIdentifier = @"DateCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DateCellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DateCellIdentifier] autorelease];
        cell.font = [UIFont systemFontOfSize:17.0];
        cell.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSString* preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([preferredLang isEqualToString:@"fr"])
        [formatter setDateFormat:@"dd MMMM yyyy"];
    else
        [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    [formatter setLocale:[NSLocale currentLocale]];
    
    cell.text = [formatter stringFromDate:date];
    [formatter release];
    
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)onCancel:(id)sender
{

}

- (void)onSave:(id)sender
{
    
}

@end