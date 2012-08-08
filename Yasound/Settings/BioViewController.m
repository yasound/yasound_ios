//
//  BioViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "BioViewController.h"




@implementation BioViewController

@synthesize user;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)user target:(id)target
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = user;
        self.delegate = target;
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GUI
//    _buttonCancel.title = NSLocalizedString(@"Navigation_cancel", nil);
//    _buttonSave.title = NSLocalizedString(@"MessageBroadcastModalView_send_button_label", nil);
//    _itemTitle.title = NSLocalizedString(@"MessageBroadcastModalView_title", nil);

    [self setLabel];
//    _label2.text = NSLocalizedString(@"MessageBroadcastModalView_to", nil);
//    _label2.text = [NSString stringWithFormat:_label2.text, self.subscribers.count];
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

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onSave:(id)sender
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* message = [_textView.text stringByTrimmingCharactersInSet:space];
    
    if (message.length == 0)
        return;

    [self.delegate bioDidReturn:message];

    [self.navigationController popViewControllerAnimated:YES];
}



- (void)setLabel
{
    _label1.text = NSLocalizedString(@"Bio.label", nil);
    CGFloat num = (BIO_LENGTH_MAX - _textView.text.length);
    _label1.text = [NSString stringWithFormat:_label1.text, num];
}



#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat num = (BIO_LENGTH_MAX - _textView.text.length);
    if (num < 0)
    {
        _textView.text = [_textView.text substringToIndex:BIO_LENGTH_MAX];
    }
    
    [self setLabel];
}







@end
