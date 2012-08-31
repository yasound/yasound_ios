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
#import "RootViewController.h"



@implementation ProfilCellRadio

@synthesize radio;


- (id)initWithRadio:(Radio*)radio {
    
    if (self = [super init]) {
        self.radio = radio;
        
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
    UIButton* radioMask = [sheet makeButton];
    [radioMask setImage:[UIImage imageNamed:@"profilRadioMaskHighlighted.png"] forState:UIControlStateHighlighted];
    [radioMask addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:radioMask];
    
    self.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);

    // title
    sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* title = [sheet makeLabel];
    title.text = self.radio.name;
    [self addSubview:title];
}


- (IBAction)onClicked:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:self.radio];
}


@end
