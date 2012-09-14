//
//  ProfilCellUser
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilCellUser.h"
#import "WebImageView.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import "ProfilViewController.h"
#import "YasoundAppDelegate.h"

@implementation ProfilCellUser

@synthesize user;


- (id)initWithUser:(User*)user {
    
    if (self = [super init]) {
        self.user = user;
        
        [self loadView];
    }
    
    return self;
}


- (void)loadView {
    
    // user image
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.User.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    WebImageView* image = [[WebImageView alloc] initWithImageAtURL:imageURL];
    image.frame = [sheet frame];
    [self addSubview:image];

    // radio mask
    sheet = [[Theme theme] stylesheetForKey:@"Profil.User.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* userMask = [sheet makeButton];
    [userMask setImage:[UIImage imageNamed:@"profilUserMaskHighlighted.png"] forState:UIControlStateHighlighted];
    [userMask addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:userMask];
    
    self.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);

    // title
    sheet = [[Theme theme] stylesheetForKey:@"Profil.User.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* title = [sheet makeLabel];
    title.text = self.user.name;
    [self addSubview:title];
}


- (IBAction)onClicked:(id)sender {
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:self.user];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}


@end
