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
  int identifier;
  NSString* kind;
  NSString* date;
  NSString* user;
  NSString* message;
  WallMessage* wallMessage;
}
@property (nonatomic) int identifier;
@property (retain, nonatomic) NSString *kind;
@property (retain, nonatomic) NSString *date;
@property (retain, nonatomic) NSString *user;
@property (retain, nonatomic) NSString *message;
@property (retain, nonatomic) WallMessage *wallMessage;
@end

@interface RadioViewController : UIViewController<UITextInputDelegate, NSXMLParserDelegate>
{
  IBOutlet UILabel *radioName;
  IBOutlet UIScrollView *wall;
  IBOutlet UITextField *messageInput;
  IBOutlet UIView *avatars;
  
  NSMutableArray* messagesArray;
  NSMutableDictionary* avatarImages;
  
  BOOL backgroundShade;
  
  Message* currentMessage;
  NSMutableString* currentXMLString;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onSendMessage:(id)sender;
- (IBAction)onLike:(id)sender;
- (IBAction)onDislike:(id)sender;
- (IBAction)onLove:(id)sender;

-(void) layoutMessages;

- (void)sendMessage:(NSString*)message;
- (void)addMessage:(NSString*)msg fromUser:(NSString*)user withDate:(NSString*)date interactive:(BOOL)interactive;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
