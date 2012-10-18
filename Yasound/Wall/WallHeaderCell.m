
#import "WallHeaderCell.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "InteractiveView.h"
#import "ProfilViewController.h"
#import "YasoundAppDelegate.h"
#import "YasoundSessionManager.h"
#import "RadioListTableViewController.h"

@implementation WallHeaderCell

@synthesize radio;
@synthesize isFavorite;
@synthesize headerImage;
@synthesize headerImageHighlight;
@synthesize headerIconFavorite;
@synthesize headerTitle;
@synthesize headerSubscribers;
@synthesize headerListeners;
@synthesize headerButtonFavorites;
@synthesize headerButtonListeners;


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

    
    [self.headerButtonFavorites setImage:[UIImage imageNamed:@"wallHeaderButtonPressed.png"] forState:(UIControlStateSelected|UIControlStateDisabled)];

    self.headerButtonFavorites.enabled = NO;
    self.headerButtonListeners.enabled = YES;
    self.headerIconFavorite.hidden = YES;

    NSString* str = URL_RADIOS_FAVORITES;
    NSURL* favoritesUrl = [NSURL URLWithString:str];
    NSLog(@"favoritesUrl '%@'", favoritesUrl);
    [[YasoundDataCache main] requestRadiosWithUrl:favoritesUrl withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
}


- (void)setListeners:(NSInteger)nbListeners {
    
    self.headerListeners.text = [NSString stringWithFormat:@"%d", nbListeners];
}



- (IBAction)onFavoriteClicked:(id)sender
{
    [[YasoundDataCache main] clearRadios:URL_RADIOS_FAVORITES];
    
    BOOL mustBeFavorite = !self.isFavorite;
    self.headerButtonFavorites.enabled = NO;

    if (mustBeFavorite)
    {
        self.headerIconFavorite.hidden = NO;
        self.headerButtonFavorites.selected = YES;
    }
    else
    {
        self.headerIconFavorite.hidden = YES;
        self.headerButtonFavorites.selected = NO;
    }
    
    [[YasoundDataProvider main] setRadio:self.radio asFavorite:mustBeFavorite target:self action:@selector(favoriteUpdated:success:)];
}


- (void)favoriteUpdated:(ASIHTTPRequest*)req success:(BOOL)success
{
    NSString* str = URL_RADIOS_FAVORITES;
    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:str] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
}




- (void)onFavoritesRadioReceived:(Container*)radioContainer
{
    NSInteger currentRadioId = [self.radio.id integerValue];
    NSArray* radios = radioContainer.objects;
    for (Radio* aRadio in radios)
    {
        if ([aRadio.id integerValue] == currentRadioId)
        {
            self.isFavorite = YES;
            self.headerIconFavorite.hidden = NO;
            
            // and clear the cache for favorites
            NSString* url = URL_RADIOS_FAVORITES;
            [[YasoundDataCache main] clearRadios:url];

            if ([YasoundSessionManager main].registered) {
                self.headerButtonFavorites.enabled = YES;
                self.headerButtonFavorites.selected = YES;
            }

            return;
        }
    }

    self.isFavorite = NO;
    if ([YasoundSessionManager main].registered) {
        self.headerButtonFavorites.enabled = YES;
        self.headerButtonFavorites.selected = NO;
    }
    self.headerIconFavorite.hidden = YES;
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



- (IBAction)onListenersClicked:(id)sender {
    
    [[YasoundDataProvider main] currentUsersForRadio:self.radio target:self action:@selector(onCurrentUsersReceived:info:)];

}



- (void)onCurrentUsersReceived:(NSArray*)listeners info:(NSDictionary*)info {
    
    if (listeners && (listeners.count == 0))
        return;
    
    CGRect frame = CGRectMake(0,0, 320, 480);
    RadioListTableViewController* view = [[RadioListTableViewController alloc] initWithNibName:@"WallListenersViewController" bundle:nil listeners:listeners];
    view.listDelegate = self;
    [APPDELEGATE.navigationController pushViewController:view animated:YES];

    [view setListeners:listeners];

    [view release];

}


#pragma mark - RadioListDelegate

- (void)friendListDidSelect:(User*)aFriend {
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:aFriend];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];

}





@end

