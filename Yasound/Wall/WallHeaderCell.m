
#import "WallHeaderCell.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "InteractiveView.h"
#import "ProfilViewController.h"
#import "YasoundAppDelegate.h"


@implementation WallHeaderCell

@synthesize radio;
@synthesize isFavorite;
@synthesize headerImage;
@synthesize headerImageHighlight;
@synthesize headerIconFavorite;
@synthesize headerTitle;
@synthesize headerSubscribers;
@synthesize headerListeners;
@synthesize headerButton;
@synthesize headerButtonLabel;


- (void)awakeFromNib
{
    self.headerImageHighlight.hidden = YES;
}

- (void)setHeaderRadio:(Radio*)radio
{
    self.radio = radio;
    self.isFavorite = NO;

    NSURL* url = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.headerImage setUrl:url];
    
    InteractiveView* intView = [[InteractiveView alloc] initWithFrame:self.headerImage.frame target:self action:@selector(onHeaderImageClicked)];
    [intView setTargetOnTouchDown:self action:@selector(onHeaderImagePressed)];
    [self addSubview:intView];
    
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
    [[YasoundDataCache main] clearRadios:URL_RADIOS_FAVORITES];
    
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


- (void)onHeaderImagePressed
{
    self.headerImageHighlight.hidden = NO;
    [self setNeedsDisplay];
}

- (void)onHeaderImageClicked
{
    self.headerImageHighlight.hidden = YES;
    [self setNeedsDisplay];
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:self.radio.creator];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];    
}

@end

