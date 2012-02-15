//
//  CreateMyRadio.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 17/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "CreateMyRadio.h"
#import "ActivityAlertView.h"
#import "SettingsViewController.h"
#import "RootViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation CreateMyRadio


@synthesize radio;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil wizard:(BOOL)wizard radio:(Radio*)aRadio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = aRadio;
        _wizard = wizard;
        
        UIImage* tabImage = [UIImage imageNamed:@"tabIconMyYasound.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"selection_tab_myyasound", nil) image:tabImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];   
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

    [ActivityAlertView close];
    

    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];                          
    [self.view addSubview:toolbar];
    
    [self.view bringSubviewToFront:_toolbarTitle];

    _toolbarTitle.text = NSLocalizedString(@"CreateMyRadio_title", nil);
    
    
    _goButton.backgroundColor = [UIColor colorWithRed:85.f/255.f green:85.f/255.f blue:85.f/255.f alpha:1];
    
    _goButton.layer.cornerRadius = 10;
    _goButton.layer.borderColor = [UIColor colorWithRed:160.f/255.f green:160.f/255.f blue:160.f/255.f alpha:1];
    _goButton.layer.borderWidth = 1;

    _skipButton.backgroundColor = [UIColor colorWithRed:85.f/255.f green:85.f/255.f blue:85.f/255.f alpha:1];
    
    _skipButton.layer.cornerRadius = 10;
    _skipButton.layer.borderColor = [UIColor colorWithRed:160.f/255.f green:160.f/255.f blue:160.f/255.f alpha:1];
    _skipButton.layer.borderWidth = 1;

    [_goButton setTitle: NSLocalizedString(@"CreateMyRadio_goButton_text", nil) forState: UIControlStateNormal];
    [_goButton addTarget:self action:@selector(onGo:) forControlEvents:UIControlEventTouchUpInside];
    
//    CGRect frame = _goButton.frame;
//    _goButton.titleLabel.textAlignment = UITextAlignmentCenter;
//    _goButton.titleLabel.text = ;
//    [_goButton addTarget:self action:@selector(onGo:) forControlEvents:UIControlEventTouchUpInside];
//    _goButton.titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if (_wizard)
    {
        [_skipButton setTitle: NSLocalizedString(@"CreateMyRadio_skipButton_text", nil) forState: UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(onSkip:) forControlEvents:UIControlEventTouchUpInside];

//        _skipButton.titleLabel.textAlignment = UITextAlignmentCenter;
//        _skipButton.titleLabel.text = NSLocalizedString(@"CreateMyRadio_skipButton_text", nil);
//        CGRect frame = _skipButton.frame;
//        [_skipButton addTarget:self action:@selector(onSkip:) forControlEvents:UIControlEventTouchUpInside];
//        _skipButton.titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    else
    {
        _skipButton.hidden = YES;
      
      UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
      NSMutableArray* items = [[NSMutableArray alloc] init];
      [items addObject:backBtn];
      [toolbar setItems:items animated:NO];
    }

    
    _text.text = NSLocalizedString(@"CreateMyRadio_text", nil);
//    CGRect frame = _goButton.frame;
//    _goButton.titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    
    _logoPosX = _logo.frame.origin.x;
    
    _logo.frame = CGRectMake(self.view.frame.size.width + _logo.frame.size.width, _logo.frame.origin.y, _logo.frame.size.width, _logo.frame.size.height);
    

    
}


//- (void)viewWillAppear:(BOOL)animated
//{
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.33];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _logo.frame = CGRectMake(_logoPosX, _logo.frame.origin.y, _logo.frame.size.width, _logo.frame.size.height);
    
    [UIView commitAnimations];

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





#pragma mark - IBActions


- (IBAction)onGo:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_WIZARD object:nil];
}


- (IBAction)onSkip:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CANCEL_WIZARD object:nil];
}

- (void)onBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}




@end
