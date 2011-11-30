//
//  RadioViewController.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewController.h"
#import "ASIFormDataRequest.h"
#import "AudioStreamer.h"


@implementation RadioViewController

- (id)init
{
  self = [super init];
  if (self) 
  {
      // Custom initialization
    
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
    
//    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:@"selected"];

}


- (void)viewDidAppear:(BOOL)animated
{
//  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/cedric.mp3"];
//  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
//  [mpStreamer retain];
//  [mpStreamer start];
}

- (void)viewWillDisappear:(BOOL)animated
{
//  [mpStreamer stop];
//  [mpStreamer release];
}


- (void)viewDidUnload
{
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
  [super dealloc];
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField endEditing:TRUE];
  return FALSE;
}


//- (NSString*) getWall
//{
//  // Needed to init cookies
//#if LOCAL
//  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/all/"];  
//#else
//  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/all/"];
//#endif
//  
//  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//  [request setDelegate:self];
//  [request startSynchronous];
//
//  //NSLog(@"Request sent, response we got: %@\n\n", request.responseString);
//  return request.responseString;
//}

//- (void) sendMessage:(NSString *)message
//{
//  
//#if LOCAL
//  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/sendpostAPI/"];
//#else
//  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/sendpostAPI/"];
//#endif
//
//	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//	//[request addPostValue:@"jmp" forKey:@"author"];
//	//[request addPostValue:@"meeloo" forKey:@"author"];
//  [request addPostValue:[[UIDevice currentDevice] name] forKey:@"author"];
//  
//	[request addPostValue:@"pipo" forKey:@"password"];
//	[request addPostValue:@"text" forKey:@"kind"];
//  [request addPostValue:message forKey:@"posttext"];
//	[request setDelegate:self];
//	[request startAsynchronous];
//}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
//{
//  //NSLog(@"XML start element: %@", elementName);
//  
//  if ( [elementName isEqualToString:@"post"]) 
//  {
//    currentMessage = [[Message alloc] init];
//  }
//  
//
//}
//
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
//{
//  if (!currentXMLString)
//  {
//    // currentXMLString is an NSMutableString instance variable
//    currentXMLString = [[NSMutableString alloc] initWithCapacity:50];
//  }
//  [currentXMLString appendString:string];
//}
//
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
//{
//  NSString* str = [currentXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//  //NSLog(@"XML end element: %@", elementName);
//  if ( [elementName isEqualToString:@"post"]) 
//  {
//    if ([messagesArray count] < currentMessage.identifier - 1)
//    {
//      NSLog(@"New post: %d\n", currentMessage.identifier);
//
//      //LBDEBUG
//
////      WallMessageViewController* wm = [[WallMessageViewController alloc] initWithNibName:@"WallMessageViewController" bundle:nil];
////      UIImage* img = (UIImage*)[avatarImages objectForKey:currentMessage.user];
////      
////      Message* m = [[Message alloc] init];
////      m.user = currentMessage.user;
////      m.date = currentMessage.date;
////      m.message = currentMessage.message;
////      m.wallMessage = wm;
//      
////      [wall addSubview:wm.view];
////LBDEBUG ICI
//      
////      wm.image.image = img;
////      wm.message.text = currentMessage.message;
////      wm.title.text = [NSString stringWithFormat:@"%@ - %@", currentMessage.date, currentMessage.user];
////      
////      if (backgroundShade)
////        wm.view.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
////      else
////        wm.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
//      
////      backgroundShade = !backgroundShade;
////      [messagesArray insertObject:m atIndex:0];
//    }
//    else
//      [currentMessage release];
//    currentMessage = nil;
//  }
//  else if ( [elementName isEqualToString:@"id"]) 
//  {
//    currentMessage.identifier = str.intValue;
//  }
//  else if ( [elementName isEqualToString:@"kind"]) 
//  {
//    currentMessage.kind = str;
//  }
//  else if ( [elementName isEqualToString:@"author"]) 
//  {
//    currentMessage.user = str;
//  }
//  else if ( [elementName isEqualToString:@"date"]) 
//  {
//    currentMessage.date = str;
//  }
//  else if ( [elementName isEqualToString:@"message"]) 
//  {
//    currentMessage.message = str;
//  }
//  
//  [currentXMLString release];
//  //[str release];
//  currentXMLString = nil;
//}





@end
