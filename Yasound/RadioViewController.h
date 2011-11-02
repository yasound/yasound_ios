//
//  RadioViewController.h
//  Yasound
//
//  Created by Sébastien Métrot on 11/2/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WallMessage;

@interface Message : NSObject
{
  NSString* date;
  NSString* user;
  NSString* message;
  WallMessage* wallMessage;
}
@property (retain, nonatomic) NSString *date;
@property (retain, nonatomic) NSString *user;
@property (retain, nonatomic) NSString *message;
@property (retain, nonatomic) WallMessage *wallMessage;
@end

@interface RadioViewController : UIViewController<UITextInputDelegate>
{
  IBOutlet UILabel *radioName;
  IBOutlet UIScrollView *wall;
  IBOutlet UITextField *messageInput;
  IBOutlet UIView *avatars;
  
  NSMutableArray* messagesArray;
  NSMutableDictionary* avatarImages;
  
  BOOL backgroundShade;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onSendMessage:(id)sender;
- (IBAction)onLike:(id)sender;
- (IBAction)onDislike:(id)sender;
- (IBAction)onLove:(id)sender;

- (void)sendMessage:(NSString*)message;
- (void)addMessage:(NSString*)msg fromUser:(NSString*)user withDate:(NSString*)date interactive:(BOOL)interactive;
@end
