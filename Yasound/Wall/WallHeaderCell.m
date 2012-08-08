@implementation WallHeaderCell

@end



////....................................................................................
////
//// header
////
//BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.Header" error:nil];
//_headerView = [[UIView alloc] initWithFrame:sheet.frame];
//_headerView.backgroundColor = sheet.color;
//[self.view addSubview:_headerView];
//
//// header background
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderBackground" error:nil];
//UIImageView* image = [[UIImageView alloc] initWithImage:[sheet image]];
//CGFloat x = self.view.frame.origin.x + self.view.frame.size.width - sheet.frame.size.width;
//image.frame = CGRectMake(x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
//[_headerView addSubview:image];
//
//// header avatar, as a second back button
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderAvatar" error:nil];
//_radioImage = [[WebImageView alloc] initWithImageFrame:sheet.frame];
//NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
//
//[_radioImage setUrl:imageURL];
//[_headerView addSubview:_radioImage];
//
//// header avatar mask  as button
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderAvatarMask" error:nil];
//UIButton* btn = [[UIButton alloc] initWithFrame:sheet.frame];
//[btn setImage:[sheet image] forState:UIControlStateNormal];
//[btn addTarget:self action:@selector(onAvatarClicked:) forControlEvents:UIControlEventTouchUpInside];
//[_headerView addSubview:btn];
//
//
//// header title
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderTitle" error:nil];
//UILabel* label = [sheet makeLabel];
//label.text = self.radio.name;
//[_headerView addSubview:label];
//
//
//
//// header favorite
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderLikes" error:nil];
//_favoritesLabel = [sheet makeLabel];
//_favoritesLabel.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
//[_headerView addSubview:_favoritesLabel];
//
//
////favorites button
//sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderFavoriteButtonFrame" error:nil];
//CGRect frame = sheet.frame;
//self.favoriteButton = [[UIButton alloc] initWithFrame:sheet.frame];
//
//NSString* tmppath = [[Theme theme] pathForResource:@"btnFavoriteEmpty" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//UIImage* imageFile = [UIImage imageWithContentsOfFile:tmppath];
//[self.favoriteButton setImage:imageFile forState:UIControlStateNormal];
//
//tmppath = [[Theme theme] pathForResource:@"btnFavoriteFull" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//imageFile = [UIImage imageWithContentsOfFile:tmppath];
//[self.favoriteButton setImage:imageFile forState:UIControlStateSelected];
//
//[self.favoriteButton addTarget:self action:@selector(onFavorite:) forControlEvents:UIControlEventTouchUpInside];
//[_headerView addSubview:self.favoriteButton];
//
//
//
//
//
//
//
//
//
//
//
//NSString* url = URL_RADIOS_FAVORITES;
//[[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:url] withGenre:nil target:self action:@selector(onFavoriteUpdate:)];
//
//
//
//
//
//- (void)onFavoriteUpdate:(NSArray*)radios
//{
//    [[ActivityModelessSpinner main] removeRef];
//    
//    NSInteger currentRadioId = [self.radio.id integerValue];
//    
//    for (Radio* radio in radios)
//    {
//        if ([radio.id integerValue] == currentRadioId)
//        {
//            self.favoriteButton.selected = YES;
//            return;
//        }
//    }
//}
//
//
//
