//
////....................................................................................
////
//// status bar
////
//BundleStylesheet* sheetStatus = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//_statusBar = [[UIView alloc] initWithFrame:sheetStatus.frame];
//UIImageView* statusBarBackground = [sheetStatus makeImage];
//statusBarBackground.frame = CGRectMake(0, 0, sheetStatus.frame.size.width, sheetStatus.frame.size.height);
//[self.view addSubview:_statusBar];
//[_statusBar addSubview:statusBarBackground];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarButtonOff" error:nil];
//_statusBarButtonImage = [sheet makeImage];
//[_statusBar addSubview:_statusBarButtonImage];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarInteractiveView" error:nil];
//InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onStatusBarButtonClicked:)];
//[_statusBar addSubview:interactiveView];
//
//
//// headset image
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusHeadSet" error:nil];
//_listenersIcon = [[UIImageView alloc] initWithImage:[sheet image]];
//_listenersIcon.frame = sheet.frame;
//[_statusBar addSubview:_listenersIcon];
//
//// listeners
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusListeners" error:nil];
//_listenersLabel = [sheet makeLabel];
//_listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
//[_statusBar addSubview:_listenersLabel];
//
