//
//  RadioViewController.m
//  Yasound
//
//  Created by Sébastien Métrot on 11/2/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewController.h"
#import "ASIFormDataRequest.h"
#import "WallMessageViewController.h"
#import "AudioStreamer.h"


#define LOCAL 0 // use localhost as the server

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
    
    [avatarImages setObject:[UIImage imageNamed:@"avatar1"]  forKey:@"meeloo"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar2"]  forKey:@"jmp"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar3"]  forKey:@"bruno"];
    
    [avatarImages setObject:[UIImage imageNamed:@"avatar4"]  forKey:@"james"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar5"]  forKey:@"john"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar6"]  forKey:@"mark"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar7"]  forKey:@"michael"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar8"]  forKey:@"carol"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar9"]  forKey:@"david"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar10"] forKey:@"paul"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar11"] forKey:@"lisa"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar12"] forKey:@"neywen"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar13"] forKey:@"sandra"];
    [avatarImages setObject:[UIImage imageNamed:@"avatar14"] forKey:@"charles"];

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


- (void)updateWall
{
#if LOCAL
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/allAPI/"];
#else
  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/allAPI/"];
#endif
  
	ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];
  
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
  NSLog(@"Request sent [%@], response we got: \n%@\n\n", request.url.absoluteString, request.responseString);
  NSLog(@"status message: %@\n\n", request.responseStatusMessage);
  //NSLog(@"cookies: %@\n\n", request.responseCookies);
  //[request release];
  
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:request.responseData];
  [parser setDelegate:self];
  [parser parse];
  
  [self layoutMessages];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  // add avatar icons
  float x = 0;
  float tileW = 40;
  float tileH = 50;
  
  CGRect r = avatars.frame;
  CGSize avatarsContentSize;
  avatarsContentSize.height = tileH;
  
  for (NSString* name in avatarImages) 
  {
    UIImage* img = [avatarImages objectForKey:name];
    
    float border = 6;
    float interspace = 3;
    float imgW = 24;
    float imgH = 24;
    float imgLeft = (tileW - imgW) / 2.f;
    
    float labelW = tileW - 2 * border;
    float labelH = tileH - imgH - 2 * border - interspace;
    
    CGRect imgRect = CGRectMake(x + imgLeft, border, imgW, imgH);
    CGRect labelRect = CGRectMake(x + border, border + imgH + interspace, labelW, labelH);
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = imgRect;
    UILabel* label = [[UILabel alloc] initWithFrame:labelRect];
    label.text = name;
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:7];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    [avatars addSubview:imgView];
    [avatars addSubview:label];
    
    x += tileW;
    avatarsContentSize.width += tileW;
  }
  avatars.contentSize = avatarsContentSize;
  
  r = avatars.frame;
  
  [self updateWall];
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                   target:self
                                 selector:@selector(updateWall)
                                 userInfo:nil
                                  repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/cedric.mp3"];
  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
  [mpStreamer retain];
  [mpStreamer start];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [mpStreamer stop];
  [mpStreamer release];
}


- (void)viewDidUnload
{
  [timer release];
  timer = nil;

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
  [self.navigationController popViewControllerAnimated:YES];
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
  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/all/"];
#endif
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request startSynchronous];

  //NSLog(@"Request sent, response we got: %@\n\n", request.responseString);
  return request.responseString;
}

- (void) sendMessage:(NSString *)message
{
  
#if LOCAL
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/sendpostAPI/"];
#else
  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/sendpostAPI/"];
#endif

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//[request addPostValue:@"jmp" forKey:@"author"];
	//[request addPostValue:@"meeloo" forKey:@"author"];
  [request addPostValue:[[UIDevice currentDevice] name] forKey:@"author"];
  
	[request addPostValue:@"pipo" forKey:@"password"];
	[request addPostValue:@"text" forKey:@"kind"];
  [request addPostValue:message forKey:@"posttext"];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
  //NSLog(@"XML start element: %@", elementName);
  
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
  //NSLog(@"XML end element: %@", elementName);
  if ( [elementName isEqualToString:@"post"]) 
  {
    if ([messagesArray count] < currentMessage.identifier - 1)
    {
      NSLog(@"New post: %d\n", currentMessage.identifier);
 
      WallMessageViewController* wm = [[WallMessageViewController alloc] initWithNibName:@"WallMessageViewController" bundle:nil];
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
    WallMessageViewController* wm = m.wallMessage;
    CGRect r = wm.view.frame;
    r.origin.y = y;
    wm.view.frame = r;
    y += r.size.height;
  }
  
  wall.contentSize = CGSizeMake(320, y);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField endEditing:TRUE];
  return FALSE;
}



@end
