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
    self.image = [[WebImageView alloc] initWithImageAtURL:imageURL];
    self.image.frame = [sheet frame];
    [self addSubview:self.image];

    // radio mask
    sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* radioMask = [sheet makeButton];
    [radioMask setImage:[UIImage imageNamed:@"profilRadioMaskHighlighted.png"] forState:UIControlStateHighlighted];
    [radioMask addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:radioMask];
    
    self.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);

    // title
    sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.text = [sheet makeLabel];
    self.text.text = self.radio.name;
    [self addSubview:self.text];
}





- (IBAction)onClicked:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SEARCH_RADIO_SELECTED object:self.radio];
}


@end
