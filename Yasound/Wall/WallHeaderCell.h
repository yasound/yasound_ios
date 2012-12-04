
#import "UIKit/UIKit.h"
#import "WebImageView.h"
#import "YaRadio.h"

@interface WallHeaderCell : UITableViewCell

@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic) BOOL isFavorite;

@property (nonatomic, retain) IBOutlet WebImageView* headerImage;
@property (nonatomic, retain) IBOutlet UIView* headerImageHighlight;
@property (nonatomic, retain) IBOutlet UIImageView* headerIconFavorite;
@property (nonatomic, retain) IBOutlet UILabel* headerTitle;
@property (nonatomic, retain) IBOutlet UILabel* headerSubscribers;
@property (nonatomic, retain) IBOutlet UILabel* headerListeners;
@property (nonatomic, retain) IBOutlet UIButton* headerButtonFavorites;
@property (nonatomic, retain) IBOutlet UIButton* headerButtonListeners;

- (void)setHeaderRadio:(YaRadio*)radio;
- (void)setListeners:(NSInteger)nbListeners;
- (IBAction)onFavoriteClicked:(id)sender;

@end


