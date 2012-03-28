//
//  YasoundLoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundLoginViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundReachability.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "ConnectionView.h"
#import "SongUploadManager.h"
#import "CreateMyRadio.h"




@implementation YasoundLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //self.title =  NSLocalizedString(@"LoginView_title", nil);        
    }
    return self;
}


- (void) dealloc
{
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
    
    _titleLabel.text = NSLocalizedString(@"LoginView_title", nil);
    
    [_email becomeFirstResponder];
    
    //_signupButton.titleLabel.text = NSLocalizedString(@"LoginView_signup_label", nil);    
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


- (void)logoutReturned
{
    // once logout done, go back to the home screen
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];    
}



#pragma mark - YasoundDataProvider

- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    //    assert(radio);
    
    // account just being create, go to configuration screen
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"skipRadioCreationSendToSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    CreateMyRadio* view = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:YES radio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}



@end
