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
        [self userReceived:self.user];
        return;
    }
    
    if ([YasoundSessionManager main].registered)
    {
        [[YasoundDataProvider main] userWithId:self.userId withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self userReceivedWithStatus:status response:response error:error];
        }];
        
    }
    else
    {
        [[YasoundDataProvider main] userWithUsername:self.modelUsername withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self publicUserReceivedWithStatus:status response:response error:error];
        }];
        
    }
   
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)userReceivedWithStatus:(int)status response:(NSString*)response error: (NSError*)error
{
    BOOL success = YES;
    User* u = nil;
    if (error)
    {
        DLog(@"get user error: %d - %@", error.code, error.domain);
        success = NO;
    }
    else if (status != 200)
    {
        DLog(@"get user radio error: response status %d", status);
        success = NO;
    }
    else
    {
        u = (User*)[response jsonToModel:[User class]];
        if (!u)
        {
            DLog(@"get user radio error: cannot parse response %@", response);
            success = NO;
        }
    }
    [self userReceived:u];
}

- (void)userReceived:(User*)u
{
    self.user = u;
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

- (void)publicUserReceivedWithStatus:(int)status response:(NSString*)response error: (NSError*)error
{
    BOOL success = YES;
    User* u = nil;
    if (error)
    {
        DLog(@"get user error: %d - %@", error.code, error.domain);
        success = NO;
    }
    else if (status != 200)
    {
        DLog(@"get user radio error: response status %d", status);
        success = NO;
    }
    else
    {
        u = (User*)[response jsonToModel:[User class]];
        if (!u)
        {
            DLog(@"get user radio error: cannot parse response %@", response);
            success = NO;
        }
    }
    if (!success)
    {
        DLog(@"ProfilViewController::publicUserReceived error : userWithUsername failed using '%@'", self.user.username);
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error.generic.title", nil) message:NSLocalizedString(@"Error.generic.message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    self.user = u;
    
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
        [[YasoundDataProvider main] friendsForUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* erorr){
            [self friendsReceivedWithStatus:status response:response error:erorr];
        }];
        
    }
    // someone else
    else
    {
        [self enableFollow:NO];
        [[YasoundDataProvider main] friendsForUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* erorr){
            [self friendsReceivedWithStatus:status response:response error:erorr];
        }];
        
        // is he one of my friends? (<=> I need to know to enable and set the follow/unfollow button properly)
        [[YasoundDataCache main] requestFriendsWithCompletionBlock:^(NSArray* myfriends){
            [self myFriendsReceived:myfriends];
        }];

    }
    
    [[YasoundDataProvider main] radiosForUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"radios for user error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"radios for user error: response status %d", status);
            return;
        }
        Container* radioContainer = [response jsonToContainer:[Radio class]];
        if (!radioContainer || !radioContainer.objects)
        {
            DLog(@"radios for user error: cannot parse response %@", response);
            return;
        }
        self.radios = radioContainer.objects;
        self.viewMyRadios.items = self.radios;
    }];
    
    [[YasoundDataProvider main] favoriteRadiosForUser:self.user withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"favorite radios for user error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"favorite radios for user error: response status %d", status);
            return;
        }
        Container* radioContainer = [response jsonToContainer:[Radio class]];
        if (!radioContainer || !radioContainer.objects)
        {
            DLog(@"favorite radios for user error: cannot parse response %@", response);
            return;
        }
        self.favorites = radioContainer.objects;
        self.viewFavorites.items = self.favorites;
    }];
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

- (void)myFriendsReceived:(NSArray*)friends
{
    DLog(@"%d friends", friends.count);
    
    for (User* user in friends)
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


- (void)friendsReceivedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    if (error)
    {
        DLog(@"friends error: %d - %@", error.code, error. domain);
        return;
    }
    if (status != 200)
    {
        DLog(@"friends error: response status %d", status);
        return;
    }
    Container* friendsContainer = [response jsonToContainer:[User class]];
    if (!friendsContainer || !friendsContainer.objects)
    {
        DLog(@"friends error: cannot parse response %@", response);
        return;
    }
    
    self.friends = friendsContainer.objects;
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
    [[YasoundDataCache main] requestFriendsWithCompletionBlock:^(NSArray* myfriends){
        [self myFriendsReceived:myfriends];
    }];
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
    {        
        [[YasoundDataProvider main] userWithId:self.userId withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self userReceivedWithStatus:status response:response error:error];
        }];
    }

}



@end
