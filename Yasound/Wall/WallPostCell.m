

////....................................................................................
////
//// message bar
////
//sheet = [[Theme theme] stylesheetForKey:@"Wall.MessageBarBackground" error:nil];
//UIImageView* messageBarView = [[UIImageView alloc] initWithImage:[sheet image]];
//messageBarView.frame = sheet.frame;
//
//[_viewWall addSubview:messageBarView];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.RadioViewMessageBar" error:nil];
//_messageBar = [[UITextField alloc] initWithFrame:sheet.frame];
//_messageBar.delegate = self;
//[_messageBar setBorderStyle:UITextBorderStyleRoundedRect];
//[_messageBar setPlaceholder:NSLocalizedString(@"radioview_message", nil)];
//
//sheet = [[Theme theme] stylesheetForKey:@"Wall.RadioViewMessageBarFont" error:nil];
//[_messageBar setFont:[sheet makeFont]];
//
//[_viewWall addSubview:_messageBar];
