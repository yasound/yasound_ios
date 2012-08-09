






//[[YasoundDataProvider main] currentUsersForRadio:self.radio target:self action:@selector(receivedCurrentUsers:withInfo:)];





//- (void)receivedCurrentUsers:(NSArray*)users withInfo:(NSDictionary*)info
//{
//    if (!users || users.count == 0)
//        return;
//    
//    if (_connectedUsers && _connectedUsers.count > 0)
//    {
//        // get diff
//        NSMutableArray* joined = [NSMutableArray array];
//        NSMutableArray* left = [NSMutableArray array];
//        
//        // user arrays are sorted by id
//        NSArray* oldUsers = _connectedUsers;
//        NSArray* newUsers = users;
//        User* u;
//        
//        User* firstNew = [newUsers objectAtIndex:0];
//        User* lastNew = [newUsers objectAtIndex:newUsers.count - 1];
//        User* firstOld = [oldUsers objectAtIndex:0];
//        User* lastOld = [oldUsers objectAtIndex:oldUsers.count - 1];
//        
//        
//        for (u in oldUsers)
//        {
//            if ([u.id intValue] >= [firstNew.id intValue])
//                break;
//            [left addObject:u];
//        }
//        
//        NSEnumerator* reverseEnumerator = [oldUsers reverseObjectEnumerator];
//        while (u = [reverseEnumerator nextObject])
//        {
//            if ([u.id intValue] <= [lastNew.id intValue])
//                break;
//            [left addObject:u];
//        }
//        
//        for (u in newUsers)
//        {
//            if ([u.id intValue] >= [firstOld.id intValue])
//                break;
//            [joined addObject:u];
//        }
//        
//        reverseEnumerator = [newUsers reverseObjectEnumerator];
//        while (u = [reverseEnumerator nextObject])
//        {
//            if ([u.id intValue] <= [lastOld.id intValue])
//                break;
//            [joined addObject:u];
//        }
//        
//        
//        for (u in joined)
//            [self userJoined:u];
//        for (u in left)
//            [self userLeft:u];
//    }
//    
//    if (_connectedUsers)
//        [_connectedUsers release];
//    _connectedUsers = users;
//    [_connectedUsers retain];
//    
//    if (_usersContainer)
//        [_usersContainer reloadData];
//}








//
//
//- (IBAction)onStatusBarButtonClicked:(id)sender
//{
//    BundleStylesheet* sheet = nil;
//    
//    // downsize status bar : hide users
//    if (_statusBarButtonToggled)
//    {
//        _statusBarButtonToggled = !_statusBarButtonToggled;
//        
//        sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarButtonOff" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        [_statusBarButtonImage setImage:[sheet image]];
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration: 0.15];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(onStatusBarClosed:finished:context:)];
//        
//        _statusBarButtonImage.frame = sheet.frame;
//        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y + _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
//        
//        _pageControl.alpha = 1;
//        _listenersIcon.alpha = 1;
//        _listenersLabel.alpha = 1;
//        
//        [UIView commitAnimations];
//    }
//    
//    // upsize status bar : show users
//    else
//    {
//        [self cleanStatusMessages];
//        
//        _statusBarButtonToggled = !_statusBarButtonToggled;
//        
//        BundleStylesheet* buttonImageSheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarButtonOn" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        [_statusBarButtonImage setImage:[buttonImageSheet image]];
//        
//        sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.RadioViewStatusBarUserScrollView" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        _usersContainer = [[OrientedTableView alloc] initWithFrame:sheet.frame];
//        _usersContainer.orientedTableViewDataSource = self;
//        _usersContainer.delegate = self;
//        _usersContainer.tableViewOrientation = kTableViewOrientationHorizontal;
//        _usersContainer.backgroundColor = [UIColor clearColor];
//        _usersContainer.separatorColor = [UIColor clearColor];
//        _usersContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
//        
//        [_statusBar addSubview:_usersContainer];
//        
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration: 0.15];
//        
//        _statusBarButtonImage.frame = buttonImageSheet.frame;
//        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y - _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
//        _usersContainer.alpha = 1;
//        
//        _pageControl.alpha = 0;
//        _listenersIcon.alpha = 0;
//        _listenersLabel.alpha = 0;
//        
//        
//        [UIView commitAnimations];
//        
//    }
//    
//}
//
//
//- (void)onStatusBarClosed:(NSString *)animationId finished:(BOOL)finished context:(void *)context
//{
//    [UIView setAnimationDelegate:nil];
//    [_usersContainer removeFromSuperview];
//    [_usersContainer release];
//    _usersContainer = nil;
//    
//    
//}
//
//
//
//


















//
//
//
//
//#pragma mark - User list
//
//- (NSIndexPath *)usersContainerDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell* cell = [_usersContainer cellForRowAtIndexPath:indexPath];
//    cell.selected = NO;
//    
//    User* user = [_connectedUsers objectAtIndex:indexPath.row];
//    
//    // Launch profile view
//    ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:user];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//    //    [user release];
//    
//    return nil;
//}
//
//
//- (void)usersContainerWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    UIView* view = [[UIView alloc] initWithFrame:cell.frame];
//    //    view.backgroundColor = [UIColor redColor];
//    //
//    //    CGFloat width = cell.frame.size.width;
//    //
//    //    UIView* selection = [[UIView alloc] initWithFrame:CGRectMake(0, 12, width, 58)];
//    //    selection.backgroundColor = [UIColor blueColor];
//    //    [view addSubview:selection];
//    //
//    //    cell.selectedBackgroundView = view;
//}
//
//
//
//- (NSInteger)numberOfSectionsInUsersContainer
//{
//    return 1;
//}
//
//- (NSInteger)usersContainerNumberOfRowsInSection:(NSInteger)section
//{
//    return _connectedUsers.count;
//}
//
//- (CGFloat)usersContainerWidthForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    CGRect nameRect = nameSheet.frame;
//    return nameRect.size.width + 2 * USER_VIEW_CELL_BORDER;
//}
//
//- (UITableViewCell*)usersContainerCellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString* cellIdentifier = @"UserViewCell";
//    UserViewCell* cell = [_usersContainer dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[[UserViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
//    }
//    cell.user = [_connectedUsers objectAtIndex:indexPath.row];
//    
//    
//    CGFloat width = cell.frame.size.width;
//    
//    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListenerSelectedBackground.png"]];
//    view.frame = CGRectMake(0, 12, width, 58);
//    cell.selectedBackgroundView = view;
//    
//    return cell;
//}
//
//
//
//
//
//
//- (void)receivedRadioForSelectedUser:(Radio*)r withInfo:(NSDictionary*)info
//{
//    if (!r)
//        return;
//    if (![r.ready boolValue])
//    {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:r.creator.name message:NSLocalizedString(@"GoTo_CurrentUser_Radio_Unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"GoTo_CurrentUser_Radio_Unavailable_OkButton_Title", nil) otherButtonTitles:nil];
//        [alertView show];
//        [alertView release];
//        return;
//    }
//    
//    DLog(@"radio '%@'   creator '%@'", r.name, r.creator.name);
//    _radioForSelectedUser = r;
//    
//    NSString* s = NSLocalizedString(@"GoTo_CurrentUser_Radio", nil);
//    NSString* msg = [NSString stringWithFormat:s, _radioForSelectedUser.name];
//    _alertGoToRadio = [[UIAlertView alloc] initWithTitle:r.creator.name message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"GoTo_CurrentUser_Radio_CancelButton_Title", nil) otherButtonTitles:NSLocalizedString(@"GoTo_CurrentUser_Radio_OkButton_Title", nil), nil];
//    [_alertGoToRadio show];
//    [_alertGoToRadio release];
//    
//    
//}
