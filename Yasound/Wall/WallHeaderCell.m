
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

- (void)setHeaderRadio:(YaRadio*)aRadio
{
    self.radio = aRadio;
    self.isFavorite = NO;

    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [self.headerImage setUrl:url];
    
    InteractiveView* intView = [[InteractiveView alloc] initWithFrame:self.headerImage.frame target:self action:@selector(onHeaderImageClicked)];
    [intView setTargetOnTouchDown:self action:@selector(onHeaderImagePressed)];
    [self addSubview:intView];
    
    self.headerTitle.text = self.radio.name;
    self.headerSubscribers.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    self.headerListeners.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];

    
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
        
        int newFav = [self.radio.favorites integerValue] + 1;
        self.headerSubscribers.text = [NSString stringWithFormat:@"%d", newFav];
    }
    else
    {
        self.headerIconFavorite.hidden = YES;
        self.headerButtonFavorites.selected = NO;
        int newFav = [self.radio.favorites integerValue] - 1;
        self.headerSubscribers.text = [NSString stringWithFormat:@"%d", newFav];
    }
    
    [[YasoundDataProvider main] setRadio:self.radio asFavorite:mustBeFavorite withCompletionBlock:^(int status, NSString* response, NSError* error){
        BOOL success = YES;
        int newFavoriteCount = [self.radio.favorites intValue];
        if (error != nil)
        {
            DLog(@"set favorite error: %d - %@", error.code, error.domain);
            success = NO;
        }
        else if (status != 200)
        {
            DLog(@"set favorite error: response status %d", status);
            success = NO;
        }
        else
        {
            NSDictionary* dict = [response jsonToDictionary];
            if (dict == nil)
            {
                DLog(@"set favorite error: cannot parse response %@", response);
                success = NO;
            }
            if ([dict valueForKey:@"success"] == NO)
            {
                DLog(@"set favorite failed: response %@", response);
                success = NO;
            }
            else
            {
                NSNumber* newFav = [dict valueForKey:@"favorites"];
                if (newFav == nil)
                    success = NO;
                else
                    newFavoriteCount = [newFav intValue];
            }
        }
        
        if (success)
        {
            self.radio.favorites = [NSNumber numberWithInt:newFavoriteCount];
            
            NSString* str = URL_RADIOS_FAVORITES;
            [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:str] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
        }
    }];
}




- (void)onFavoritesRadioReceived:(Container*)radioContainer
{
    NSInteger currentRadioId = [self.radio.id integerValue];
    NSArray* radios = radioContainer.objects;
    for (YaRadio* aRadio in radios)
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
    
    self.headerSubscribers.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
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



- (IBAction)onListenersClicked:(id)sender
{
    [[YasoundDataProvider main] currentUsersForRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"radio current users error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"radio current users error: response status %d", status);
            return;
        }
        Container* usersContainer = [response jsonToContainer:[User class]];
        if (usersContainer == nil)
        {
            DLog(@"radio current users error: cannot parse response %@", response);
            return;
        }
        NSArray* listeners = usersContainer.objects;
        if (listeners == nil)
        {
            DLog(@"radio current users error: bad response %@", response);
            return;
        }
        if (listeners.count == 0)
            return;
        
        RadioListTableViewController* view = [[RadioListTableViewController alloc] initWithNibName:@"WallListenersViewController" bundle:nil listeners:listeners];
        view.listDelegate = self;
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        
        [view setListeners:listeners];
        
        [view release];
    }];

}

#pragma mark - RadioListDelegate

- (void)friendListDidSelect:(User*)aFriend {
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:aFriend];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}





@end

