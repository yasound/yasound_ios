#pragma mark - Flip View

- (void) flipToView:(UIView*)view removeView:(UIView*)viewToRemove fromLeft:(BOOL)fromLeft
{
    [self keyboardDidHide:nil];
    
    UIViewAnimationOptions animOptions = UIViewAnimationOptionTransitionFlipFromLeft;
    if (!fromLeft)
        animOptions = UIViewAnimationOptionTransitionFlipFromRight;
        
        [UIView transitionWithView:_container
                          duration:0.75
                           options:animOptions
                        animations:^{ if (viewToRemove != nil) [viewToRemove removeFromSuperview];  [_container addSubview:view]; }
                        completion:NULL];
    
    _loginViewVisible = NO;
    _yasoundSignupViewVisible = NO;
    
    if (view == _loginView)
    {
        _loginViewVisible = YES;
        [[self navigationItem] setLeftBarButtonItem:nil];      
        self.title = @"Yasound";
    }
    else if (view == _yasoundSignupView)
    {
        _yasoundSignupViewVisible = YES;
        [[self navigationItem] setLeftBarButtonItem:_backBtn];        
        [self yasoundSignup_ViewDidAppear];
    }
    
    
}


