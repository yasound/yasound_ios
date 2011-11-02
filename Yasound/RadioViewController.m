//
//  RadioViewController.m
//  Yasound
//
//  Created by Sébastien Métrot on 11/2/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewController.h"
#import "ASIFormDataRequest.h"
#import "WallMessage.h"

#define LOCAL 1 // use localhost as the server

@implementation Message
@synthesize identifier;
@synthesize kind;
@synthesize date;
@synthesize user;
@synthesize message;
@synthesize wallMessage;

@end

@implementation RadioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
    
    messagesArray = [[NSMutableArray alloc] init];
    avatarImages = [[NSMutableDictionary alloc] init];

    UIImage* img = [UIImage imageNamed:@"avatar1"];
    [avatarImages setObject:img forKey:@"meeloo"];
    img = [UIImage imageNamed:@"avatar2"];
    [avatarImages setObject:img forKey:@"jmp"];
    img = [UIImage imageNamed:@"avatar3"];
    [avatarImages setObject:img forKey:@"bruno"];

    currentMessage = nil;
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [radioName release];
  radioName = nil;
  [wall release];
  wall = nil;
  [messageInput release];
  messageInput = nil;
  [avatars release];
  avatars = nil;
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
  [radioName release];
  [wall release];
  [messageInput release];
  [avatars release];
  [messagesArray release];
  [avatarImages release];

  [super dealloc];
}

- (IBAction)onBack:(id)sender
{
  [[UIApplication sharedApplication].delegate onQuitRadio:sender];
}

- (IBAction)onSendMessage:(id)sender
{
  if (messageInput.text.length != 0)
    [self sendMessage:messageInput.text];
  messageInput.text = @"";
}

- (IBAction)onLike:(id)sender
{
  [self sendMessage:@"[[like]]"];
}

- (IBAction)onLove:(id)sender
{
  [self sendMessage:@"[[love]]"];
}

- (IBAction)onDislike:(id)sender 
{
  [self sendMessage:@"[[dislike]]"];
}

- (void)selectionWillChange:(id <UITextInput>)textInput
{
  
}

- (void)selectionDidChange:(id <UITextInput>)textInput
{
  
}

- (void)textWillChange:(id <UITextInput>)textInput
{
  
}

- (void)textDidChange:(id <UITextInput>)textInput
{
  
}

- (NSString*) getWall
{
  // Needed to init cookies
#if LOCAL
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/all/"];  
#else
  NSURL *url = [NSURL URLWithString:@"http://94.100.167.5:8080/wall/all/"];
#endif
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request startSynchronous];

  NSLog(@"Request sent, response we got: %@\n\n", request.responseString);
  return request.responseString;
}

- (void) sendMessage:(NSString *)message
{
  
#if LOCAL
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/sendpostAPI/"];
#else
  NSURL *url = [NSURL URLWithString:@"http://94.100.167.5:8080/wall/sendpostAPI/"];
#endif

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addPostValue:@"meeloo" forKey:@"author"];
	[request addPostValue:@"pipo" forKey:@"password"];
	[request addPostValue:@"text" forKey:@"kind"];
  [request addPostValue:message forKey:@"posttext"];
	[request setDelegate:self];
	[request startSynchronous];
  
  NSLog(@"Request sent, response we got: \n%@\n\n", request.responseString);
  NSLog(@"status message: %@\n\n", request.responseStatusMessage);
  //NSLog(@"cookies: %@\n\n", request.responseCookies);
  //[request release];
  
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:request.responseData];
  [parser setDelegate:self];
  [parser parse];
  
  //[self addMessage:message fromUser:@"meeloo" withDate:@"now" interactive:YES];
  [self layoutMessages];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
  NSLog(@"XML start element: %@", elementName);
  
  if ( [elementName isEqualToString:@"post"]) 
  {
    currentMessage = [[Message alloc] init];
  }
  

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
  if (!currentXMLString)
  {
    // currentXMLString is an NSMutableString instance variable
    currentXMLString = [[NSMutableString alloc] initWithCapacity:50];
  }
  [currentXMLString appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  NSString* str = [currentXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSLog(@"XML end element: %@", elementName);
  if ( [elementName isEqualToString:@"post"]) 
  {
    if ([messagesArray count] == 0 || currentMessage.identifier > ((Message*)[messagesArray objectAtIndex:0]).identifier)
    {
      NSLog(@"New post: %d\n", currentMessage.identifier);
 
      WallMessage* wm = [[WallMessage alloc] initWithNibName:@"WallMessage" bundle:nil];
      UIImage* img = (UIImage*)[avatarImages objectForKey:currentMessage.user];
      
      Message* m = [[Message alloc] init];
      m.user = currentMessage.user;
      m.date = currentMessage.date;
      m.message = currentMessage.message;
      m.wallMessage = wm;
      
      [wall addSubview:wm.view];
      wm.image.image = img;
      wm.message.text = currentMessage.message;
      wm.title.text = [NSString stringWithFormat:@"%@ - %@", currentMessage.date, currentMessage.user];
      
      if (backgroundShade)
        wm.view.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
      else
        wm.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
      
      backgroundShade = !backgroundShade;
      [messagesArray insertObject:m atIndex:0];
    }
    else
      [currentMessage release];
    currentMessage = nil;
  }
  else if ( [elementName isEqualToString:@"id"]) 
  {
    currentMessage.identifier = str.intValue;
  }
  else if ( [elementName isEqualToString:@"kind"]) 
  {
    currentMessage.kind = str;
  }
  else if ( [elementName isEqualToString:@"author"]) 
  {
    currentMessage.user = str;
  }
  else if ( [elementName isEqualToString:@"date"]) 
  {
    currentMessage.date = str;
  }
  else if ( [elementName isEqualToString:@"message"]) 
  {
    currentMessage.message = str;
  }
  
  [currentXMLString release];
  //[str release];
  currentXMLString = nil;
}


-(void) layoutMessages
{
  int y = 0;
  for (Message* m in messagesArray)
  {
    WallMessage* wm = m.wallMessage;
    CGRect r = wm.view.frame;
    r.origin.y = y;
    wm.view.frame = r;
    y += r.size.height;
  }
  
  wall.contentSize = CGSizeMake(320, y);
}

- (void) addMessage:(NSString*)msg fromUser:(NSString*)user withDate:(NSString*)date interactive:(BOOL)interactive
{
  WallMessage* wm = [[WallMessage alloc] initWithNibName:@"WallMessage" bundle:nil];
  UIImage* img = (UIImage*)[avatarImages objectForKey:user];
  
  Message* m = [[Message alloc] init];
  m.user = user;
  m.date = date;
  m.message = msg;
  m.wallMessage = wm;

  [wall addSubview:wm.view];
  wm.image.image = img;
  wm.message.text = msg;
  wm.title.text = [NSString stringWithFormat:@"%@ - %@", date, user];

  if (backgroundShade)
    wm.view.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
  else
    wm.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
  
  backgroundShade = !backgroundShade;
  
  [messagesArray insertObject:m atIndex:0];
  
  [self layoutMessages];
  if (interactive)
    [wall scrollRectToVisible:CGRectMake(0, 0, 320, 50) animated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField endEditing:TRUE];
  return FALSE;
}



@end
