//
//  BioViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "BioViewController.h"
#import "YasoundDataProvider.h"
#import "YasoundAppDelegate.h"
#import "RootViewController.h"



@implementation BioViewController

@synthesize user;
@synthesize delegate;
@synthesize topbar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)aUser target:(id)target
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = aUser;
        self.delegate = target;
        _changed = NO;
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    [_image setUrl:url];
    
    _label1.text = self.user.name;
    _label2.text = [self.user formatedProfil];
    
    _textView.text = self.user.bio_text;
    
    [self setLabel];
    _textView.delegate = self;
    
    [_textView becomeFirstResponder];
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






#pragma mark - IBActions

#pragma mark - TopBarDelegate

- (BOOL)topBarSave
{
    if (_changed)
    {
        [self save];
        return NO;
    }
    
    return YES;
}

- (BOOL)topBarCancel
{
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];

    return NO;
}

- (void)save
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* message = [_textView.text stringByTrimmingCharactersInSet:space];
    
    [self.delegate bioDidReturn:message];

    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:[NSNumber numberWithBool:NO]];
}



- (void)setLabel
{
    _labelWarning.text = NSLocalizedString(@"Bio.label", nil);
    CGFloat num = (BIO_LENGTH_MAX - _textView.text.length);
    _labelWarning.text = [NSString stringWithFormat:_labelWarning.text, num];
}



#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    _changed = YES;
    
    CGFloat num = (BIO_LENGTH_MAX - _textView.text.length);
    if (num < 0)
    {
        _textView.text = [_textView.text substringToIndex:BIO_LENGTH_MAX];
    }
    
    [self setLabel];
}







@end
