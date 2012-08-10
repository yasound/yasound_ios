
#import "WallHeaderCell.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"

@implementation WallHeaderCell

@synthesize radio;
@synthesize isFavorite;
@synthesize headerImage;
@synthesize headerIconFavorite;
@synthesize headerTitle;
@synthesize headerSubscribers;
@synthesize headerListeners;
@synthesize headerButton;
@synthesize headerButtonLabel;


- (void)awakeFromNib
{
}

- (void)setHeaderRadio:(Radio*)radio
{
    self.radio = radio;
    self.isFavorite = NO;

    NSURL* url = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.headerImage setUrl:url];
    
    self.headerTitle.text = radio.name;
    self.headerSubscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
    self.headerListeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
//    self.headerButtonLabel.text = NSLocalizedString(@"Wall.header.favorite.button.add", nil);

    self.headerButton.enabled = NO;
    self.headerButtonLabel.text = @"-";
    self.headerIconFavorite.hidden = YES;

    NSString* str = URL_RADIOS_FAVORITES;
    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:str] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
}


- (IBAction)onFavoriteClicked:(id)sender
{
    BOOL mustBeFavorite = !self.isFavorite;
    self.headerButton.enabled = NO;

    if (mustBeFavorite)
    {
        self.headerIconFavorite.hidden = NO;
        self.headerButtonLabel.text = NSLocalizedString(@"Wall.header.favorite.button.remove", nil);
    }
    else
    {
        self.headerIconFavorite.hidden = YES;
        self.headerButtonLabel.text = NSLocalizedString(@"Wall.header.favorite.button.add", nil);
    }
    
    [[YasoundDataProvider main] setRadio:self.radio asFavorite:mustBeFavorite target:self action:@selector(favoriteUpdated:success:)];
}


- (void)favoriteUpdated:(ASIHTTPRequest*)req success:(BOOL)success
{
    NSString* str = URL_RADIOS_FAVORITES;
    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:str] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
}




- (void)onFavoritesRadioReceived:(NSArray*)radios
{
    NSInteger currentRadioId = [self.radio.id integerValue];

    for (Radio* aRadio in radios)
    {
        if ([aRadio.id integerValue] == currentRadioId)
        {
            self.isFavorite = YES;
            self.headerIconFavorite.hidden = NO;
            self.headerButton.enabled = YES;
            self.headerButtonLabel.text = NSLocalizedString(@"Wall.header.favorite.button.remove", nil);

            // and clear the cache for favorites
            NSString* url = URL_RADIOS_FAVORITES;
            [[YasoundDataCache main] clearRadios:url];

            self.headerButton.enabled = YES;
            return;
        }
    }

    self.isFavorite = NO;
    self.headerButton.enabled = YES;
    self.headerIconFavorite.hidden = YES;    
    self.headerButtonLabel.text = NSLocalizedString(@"Wall.header.favorite.button.add", nil);
}

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
