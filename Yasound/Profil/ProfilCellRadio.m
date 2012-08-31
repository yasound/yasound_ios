//
//  ProfilCellRadio
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilCellRadio.h"
#import "Theme.h"
#import "YasoundDataProvider.h"




@implementation ProfilCellRadio

@synthesize target;
@synthesize action;
@synthesize radio;


- (id)initWithRadio:(Radio*)radio target:(id)target  action:(SEL)action {
    
    if (self = [super init]) {
        self.radio = radio;
        self.target = target;
        self.action = action;
        
        [self loadView];
    }
    
    return self;
}


- (void)loadView {
    
    // radio image
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    WebImageView* radioImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
    radioImage.frame = [sheet frame];
    [self addSubview:radioImage];

    // radio mask
    sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* radioMask = [sheet makeImage];
    [self addSubview:radioMask];
    
    self.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);

    // title
    sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* title = [sheet makeLabel];
    title.text = self.radio.name;
    [self addSubview:title];
}


- (IBAction)onClicked:(id)sender {
    

}


@end
