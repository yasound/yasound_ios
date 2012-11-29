//
//  ProfilViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilViewController.h"
#import "TopBar.h"
#import "AudioStreamManager.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "Theme.h"
#import "RootViewController.h"
#import "YasoundSessionManager.h"


@interface ProfilViewController ()

@end

@implementation ProfilViewController

@synthesize scrollview;
@synthesize viewProfil;
@synthesize viewMyRadios;
@synthesize viewFavorites;
@synthesize viewFriends;


@synthesize user;
@synthesize userId;
@synthesize modelUsername;
@synthesize radios;
@synthesize favorites;
@synthesize friends;

@synthesize userImage;
@synthesize name;
@synthesize profil;
@synthesize hd;

@synthesize buttonBlue;
@synthesize buttonFollow;
@synthesize buttonBlueLabel;
@synthesize followed;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = user;
        self.userId = nil;
        self.modelUsername = nil;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUserId:(NSNumber*)userId andModelUsername:(NSString*)modelUsername
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.user = nil;
        self.userId = userId;
        self.modelUsername = modelUsername;
    }
    return self;
}








- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifProfilUpdated:) name:NOTIF_PROFIL_UPDATED object:nil];
    
    // temporarly deactivated "message" function
    self.buttonBlue.hidden = YES;
    self.buttonBlueLabel.hidden = YES;
    
    // update top bar with an edit button
    if ([YasoundDataProvider isAuthenticated])
    {
        if (self.user && [self.user.id isEqualToNumber:[YasoundDataProvider user_id]]) {
            [self.topbar showEditItem];
        }
    }
    
    // build scrollview
    CGFloat posY = 0;
    self.viewProfil.frame = CGRectMake(0, posY, self.viewProfil.frame.size.width, self.viewProfil.frame.size.height);
    [self.scrollview addSubview:self.viewProfil];
    
    posY += self.viewProfil.frame.size.height;
    
    self.viewMyRadios.frame = CGRectMake(0, posY, self.viewMyRadios.frame.size.width, self.viewMyRadios.frame.size.height);
    [self.scrollview addSubview:self.viewMyRadios];
    
    posY += self.viewMyRadios.frame.size.height;
    
    if ([YasoundSessionManager main].registered) {
        
        self.viewFavorites.frame = CGRectMake(0, posY, self.viewFavorites.frame.size.width, self.viewFavorites.frame.size.height);
        [self.scrollview addSubview:self.viewFavorites];

        posY += self.viewMyRadios.frame.size.height;    

        self.viewFriends.frame = CGRectMake(0, posY, self.viewFriends.frame.size.width, self.viewFriends.frame.size.height);
        [self.scrollview addSubview:self.viewFriends];

        posY += self.viewFriends.frame.size.height;
    }
    
    
    self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width, posY);
    
    self.buttonFollow.target = self;
    self.buttonFollow.action = @selector(onButtonGrayClicked:);

    
    // define sections
    self.viewMyRadios.title.text = NSLocalizedString(@"Profil.section.myRadios", nil);
    self.viewFavorites.title.text = NSLocalizedString(@"Profil.section.favorites", nil);
    self.viewFriends.title.text = NSLocalizedString(@"Profil.section.friends", nil);
    
    
    
    if (self.user)
    {
        [self userReceived:self.user info:nil];
        return;
    }
    
    if ([YasoundSessionManager main].registered)
        [[YasoundDataProvider main] userWithId:self.userId target:self action:@selector(userReceived:info:)];
    else
        [[YasoundDataProvider main] userWithUsername:self.modelUsername target:self action:@selector(publicUserReceived:success:)];

    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)publicUserReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"ProfilViewController::publicUserReceived error : userWithUsername failed using '%@'", self.user.username);

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error.generic.title", nil) message:NSLocalizedString(@"Error.generic.message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    self.user = [req responseObjectWithClass:[User class]];
    
    [self update];

}



- (void)userReceived:(User*)user info:(NSDictionary*)info
{
    DLog(@"userReceived from id '%@' : %p", self.userId, user);
    DLog(@"info : %@", info);
    self.user = user;
    
    if (self.user == nil)
    {
        DLog(@"ProfilViewController::userReceived error : userWithId failed using '%@'",  self.userId);

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error.generic.title", nil) message:NSLocalizedString(@"Error.generic.message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    [self update];
}


- (void)update
{
    self.name.text = self.user.name;
    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    [self.userImage setUrl:url];
    
    if ((self.user.bio_text == nil) || (self.user.bio_text.length == 0))
    {
        NSString* text = NSLocalizedString(@"Profil.bio.empty", nil);
        text = [NSString stringWithFormat:text, self.user.name];
        self.bio.text = text;
        self.bio.alpha = 0.3;
    }
    else
    {
        self.bio.text = self.user.bio_text;
        self.bio.alpha = 0.75;
    }
    
    self.profil.text = [self.user formatedProfil];
    
    // custom follow button
    [self.buttonFollow setThemeRef:@"darkGray" title:NSLocalizedString(@"Profil.follow", nil)];
    
    self.buttonBlueLabel.text = NSLocalizedString(@"Profil.message", nil);

    // not registered
    if (![YasoundSessionManager main].registered)
    {
        [self enableFollow:NO];
        [self enableSendMessage:NO];    
    }
    // registered, and it's me
    else if ([self.user.id isEqualToNumber:[YasoundDataProvider user_id]])
    {
        [self enableFollow:NO];
        [self enableSendMessage:NO];
        [[YasoundDataProvider main] friendsForUser:self.user withTarget:self action:@selector(friendsReceived:success:)];
    }
    // someone else
    else
    {
        [self enableFollow:NO];
        [[YasoundDataProvider main] friendsForUser:self.user withTarget:self action:@selector(friendsReceived:success:)];
        
        // is he one of my friends? (<=> I need to know to enable and set the follow/unfollow button properly)
        [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(myFriendsReceived:success:)];

    }
    


    [[YasoundDataProvider main] radiosForUser:self.user withTarget:self action:@selector(radiosReceived:success:)];
    [[YasoundDataProvider main] favoriteRadiosForUser:self.user withTarget:self action:@selector(favoritesRadioReceived:withInfo:)];
}




- (void)enableFollow:(BOOL)enable
{
    [self.buttonFollow setEnabled:enable];
    CGFloat alpha = 1;
    if (!enable)
        alpha = 0.5;
    self.buttonFollow.alpha = alpha;
}

- (void)enableSendMessage:(BOOL)enable
{
    [self.buttonBlue setEnabled:enable];
    CGFloat alpha = 1;
    if (!enable)
        alpha = 0.5;
    self.buttonBlue.alpha = alpha;
    self.buttonBlueLabel.alpha = alpha;
}

- (void)setFollowButtonToFollow
{
    [self.buttonFollow setThemeRef:@"darkGray" title:NSLocalizedString(@"Profil.follow", nil)];
}

- (void)setFollowButtonToUnfollow
{
    [self.buttonFollow setThemeRef:@"darkGray" title:NSLocalizedString(@"Profil.unfollow", nil)];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}







- (void)radiosReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"ProfilViewController::radiosReceived failed");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[Radio class]];
    self.radios = container.objects;
    
    if (self.radios == nil)
    {
        DLog(@"ProfilViewController::radiosReceived error : radios is nil!");
        assert(0);
    }
    
    self.viewMyRadios.items = self.radios;
}


- (void)favoritesRadioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    self.favorites = radios;
    
    self.viewFavorites.items = self.favorites;
}



- (void)myFriendsReceived:(NSArray*)myFriends success:(BOOL)success
{
    DLog(@"%d friends", myFriends.count);
    
    for (User* user in myFriends)
    {
        DLog(@"my friend : %@", user.username);
        
        if ([user.id isEqualToNumber:self.user.id])
        {
            // it's one of my friend.
            // follow button becomes unfollow
            self.followed = YES;
            [self enableFollow:YES];
            [self setFollowButtonToUnfollow];
            return;
        }
    }
    
    // follow
    self.followed = NO;
    [self enableFollow:YES];
    [self setFollowButtonToFollow];
}

- (void)friendsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    Container* container = [req responseObjectsWithClass:[User class]];
    self.friends = container.objects;
    
    self.viewFriends.items = self.friends;
}






- (IBAction)onButtonGrayClicked:(id)sender
{
    [self.buttonFollow setEnabled:NO];
    
    if (self.followed)
    {
        self.followed = NO;
        [self setFollowButtonToFollow];
        
        [[YasoundDataProvider main] unfollowUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* error){
            BOOL success = (error == nil) && (status == 200);
            [self onFollowAcknowledge:success];
        }];
    }
    else
    {
        self.followed = YES;
        [self setFollowButtonToUnfollow];
        
        [[YasoundDataProvider main] followUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* error){
            BOOL success = (error == nil) && (status == 200);
            [self onFollowAcknowledge:success];
        }];
    }
    
}

- (void)onFollowAcknowledge:(BOOL)success
{
    if (!success)
    {
        if (self.followed)
        {
            self.followed = NO;
            [self setFollowButtonToFollow];
        }
        else
        {
            self.followed = YES;
            [self setFollowButtonToUnfollow];
        }
    }
    
    [[YasoundDataCache main] clearFriends];
    
    // refresh
    [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(myFriendsReceived:success:)];
}


- (IBAction)onButtonBlueClicked:(id)sender
{

}






#pragma mark - TopBarDelegate



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)onNotifProfilUpdated:(NSNotification*)notif {

    //refresh
    if ([YasoundSessionManager main].registered)
        [[YasoundDataProvider main] userWithId:self.user.id target:self action:@selector(userReceived:info:)];

}



@end
