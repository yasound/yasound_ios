
#import "UIKit/UIKit.h"
#import "WebImageView.h"
#import "Radio.h"

@interface WallHeaderCell : UITableViewCell

@property (nonatomic, retain) Radio* radio;
@property (nonatomic) BOOL isFavorite;

@property (nonatomic, retain) IBOutlet WebImageView* headerImage;
@property (nonatomic, retain) IBOutlet UIImageView* headerIconFavorite;
@property (nonatomic, retain) IBOutlet UILabel* headerTitle;
@property (nonatomic, retain) IBOutlet UILabel* headerSubscribers;
@property (nonatomic, retain) IBOutlet UILabel* headerListeners;
@property (nonatomic, retain) IBOutlet UIButton* headerButton;
@property (nonatomic, retain) IBOutlet UILabel* headerButtonLabel;

- (void)setHeaderRadio:(Radio*)radio;
- (IBAction)onFavoriteClicked:(id)sender;

@end


