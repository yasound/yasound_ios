#Bitly Twitter Library

##Introduction

The Bitly Twitter library allows you to easily include Twitter sharing in your application. It builds on top of the iOS5 twitter integration, but with these advantages over Apple's TWTweetComposeViewController:

* Is backwards compatible to iOS4 (must be compiled against iOS5, but can be deployed onto iOS4 devices.)
* Shortens links in tweets using bitly, so that your company can take advantage of its bitly custom domains and sharing analytics. If you don't have a custom domain, you can create one for free!
* Shortens links in real time, so users can see exactly how their tweet will appear. 
* Is open source, so you can customize it as desired. 

Additionally, if you would prefer to shorten links using bitly but present your own UI, the library provides convenience classes to support this.

##Supported iOS Versions

The library must be built against iOS5, but can be deployed onto iOS 4.2+. When running against iOS5, the library automatically uses the Twitter accounts configured by the user in the Settings app. On iOS4, the library uses OAuth to authenticate the user.

##Setting Up

###Creating API Keys

####1) Create Bitly API Keys

If you don't already have a bitly api key, obtain one here: http://bitly.com/a/sign_up. 
	
####2) Create Twitter API Keys (if supporting back to iOS4)
	
If you're supporting iOS 4.x, you must create twitter api keys so that we can send the tweet using OAuth. In iOS5, this is handled by Apple's TWRequest class.

You can create keys here: https://dev.twitter.com/apps/new. **Important** -- You must set a callback URL, even though the user will never see that page. The library will intercept redirects to that URL and act accordingly. As an example, our project uses @"http://twitterauthsuccess.bit.ly";


###Downloading the SDK

####1) Pull the SDK from github: 

	git clone git@github.com:bitly/bitly_ios_sdk.git

And get the dependencies: 

	cd  bitly_ios_sdk
	git submodule update --init

####2) Open the workspace file, BitlySDK.xcworkspace. 

The workspace contains two projects, the Bitly library (BitlyLib) and a sample project that demonstrates usage of the library (BitlySample). Edit the sample project's applicationDidFinishLaunching method to include your bitly API keys. If you are supporting iOS 4.x, also include your twitter API keys (see documentation on key creation above.)

####3) Build and run the BitlySample target.

Select the BitlySample target (not BitlyLib!), and Build and Run the project. Verify that your keys are working properly by shortening links and tweeting.

####4) Add the Bitly Library to your own project 
The build creates a folder called "Bitly" in the workspace, at BitlyLibrary/Bitly. Locate the Bitly folder in Finder and drag it into to your own project, selecting "Copy items into destination group's folder (if necessary)."

Follow the directions under "Completing Setup", and "How to Use", below. 


###Completing Setup

	
#### 1) Link to the required frameworks

In the "Build Phases" tab of your project's target, open the "Link Binary with Libraries" item. Add these frameworks if you're not already linking to them:

	libBitly.a
	Security.framework
	QuartzCore.framework
	Accounts.framework *NOTE if you are supporting OS versions less than iOS5, this must be marked "Optional", not "Required"*
	Twitter.framework *NOTE if you are supporting OS versions less than iOS5, this must be marked "Optional", not "Required"*

####2) Set the -ObjC linker flag

In the "Build Settings" tab of your project's target, open "Other Linker Flags" and add "-ObjC" to it. 



####NOTE ON ARC 

The current version of this library is not built with ARC, because there were some known bugs in the early betas of iOS5 in the interaction between the twitter integration and ARC that prevented development using ARC.  
Using the static library as documented above should make this a non-issue, as it will work both with ARC and non-ARC projects. If for some reason you want to pull in the source files instead of using the static library, and your project uses ARC, you will have to turn this off on a per-file basis.  

	

##How to use

###Set your API key information

(See "Create api keys above"" if you don't have keys)

Call these two methods to set your credentials. You may want to do this in your application:didFinishLaunching implementation:

	[[BitlyConfig sharedBitlyConfig] setBitlyLogin:<your bitly login> bitlyAPIKey:<your bitly api key>];


If supporting iOS 4.x: 
    [[BitlyConfig sharedBitlyConfig] setTwitterOAuthConsumerKey:<your consumer key> twitterOAuthConsumerSecret:<your consumer secret> twitterOAuthSuccessCallbackURL:<your callback url>];
	

###Using the bitly TweetSheet

####1) Create the bitly TweetSheet
	
	BitlyTweetSheet *tweetsheet = [[BitlyTweetSheet alloc] init];

Set the delegate to the appropriate object:

	tweetsheet.delegate = self;
	
####2) Set the tweet contents

You can optionally set the initial text to populate the tweet:

	tweetsheet.initialText = @"Check out this link: http://some.domain.com/myLongURL?someQuery";
	
You can also append a URL to the text:
	
	[tweetsheet addURL:[NSURL URLWithString:@"http://another.domain.com/anotherLongURL?anotherQuery"]];
	
The TweetSheet will automatically convert all long URLs to short URLs.

####3) Implement the delegate methods

All BitlyTweetSheetDelegate methods are optional, however you will probably want to implement them to know when the operation is complete and the TweetSheet can be dismissed.

	- (void)bitlyTweetSheetDidSendTweet:(BitlyTweetSheet *)viewController;
	- (void)bitlyTweetSheet:(BitlyTweetSheet *)viewController didFailWithError:(NSError *)error;
	- (void)bitlyTweetSheetUserCancelledTweet:(BitlyTweetSheet *)viewController;
	- (void)bitlyTweetSheet:(BitlyTweetSheet *)viewController textDidChange:(NSString *)text;
	
	/*These two methods are only relevant when on iOS5+ since they refer to the Accounts framework. */
	- (void)bitlyTweetSheetAccountAccessDenied:(BitlyTweetSheet *)viewController;
	- (void)bitlyTweetSheetNoAccountsAvailable:(BitlyTweetSheet *)viewController;

####4) Display the TweetSheet

The BitlyTweetSheet can be displayed as a modal view on the iPhone, and either a popover or modal on the iPad.

To display modally on iPhone or iPad, call presentModallyFromViewController with the parent view controller for the modal, for example:
	
	[tweetsheet presentModallyFromViewController:self];
	
To display as a popover on iPad, get the popoverController instance from the TweetSheet and display it, for example:

	UIPopoverController *popoverController = self.bitlyShareController.popoverController;
    [popoverController presentPopoverFromRect:((UIView *)sender).frame 
                                                inView:self.view 
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:NO];
    
*Note:* while the popover is a nice UI choice for the iPad, the user can easily dismiss the popover by accident by tapping outside its bounds, possibly undoing work they've done to customize the tweet. You may want to remember the last text inside your underlying view controller, and present that text if the user raises the popover a second time. You can get access to that text by implementing this delegate method:

	- (void)bitlyTweetSheet:(BitlyTweetSheet *)viewController textDidChange:(NSString *)text;
	

###Using your own UI

To integrate bitly URL shortening with your own twitter UI, you can either use the BitlyTextView component, or the BitlyURLShortener

####1) Using BitlyTextView

Using BitlyTextView is an intermediate solution for when you want automatic URL shortening in a UITextView, but prefer to surround the textview with your own UI.

To use, add it to your interface the way you would any UIView instance, either by calling initWithFrame or adding it to a nib file. Set the delegate to the appropriate object:

	BitlyTextView *bitlyTextView = [[BitlyTextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
	bitlyTextView.delegate = self;
	
Implement the delegate callback if you need to know when the text has changed, for example to update a character count: 
	
	- (void)bitlyTextView:(BitlyTextView *)textView didShortenLinks:(NSDictionary *)linkDictionary 
	              oldText:(NSString *)oldText text:(NSString *)text;
	
####2) Using BitlyURLShortener

When you just want to shorten a link with bitly, use the BitlyURLShortener class. 

	BitlyURLShortener *bitly = [[BitlyURLShortener alloc] init];
	bitly.delegate = self;

This class can be called with a single NSURL:

	[bitly shortenURL:[NSURL URLWithString:@"http://www.mylongdomain.com/mylongurl"]];

Or with an NSString object, in which case it will shorten all URLs in the text:

	[bitly shortenLinksInText:@"Here are two links to shorten: http://www.longdomain1.com/longurl1 and http://www.longdomain2.com/longurl2"];
	
Implement the delegate callbacks appropriate to your needs:

	/* Called after all URLs in the text are either shortened, or have had shortening attempted and failed */
	- (void)bitlyURLShortenerDidShortenText:(BitlyURLShortener *)shortener oldText:(NSString *)text text:(NSString *)text linkDictionary:(NSDictionary *)dictionary;

	/* Called when each URL is successfully shortened. */ 
	- (void)bitlyURLShortenerDidShortenURL:(BitlyURLShortener *)shortener longURL:(NSURL *)longURL shortURLString:(NSString *)shortURLString; 

	/* Called whenever shortening fails for an individual link. Developers can choose to implement this if they need to debug problems with url shortening, such as an invalid api key. */
	- (void)bitlyURLShortener:(BitlyURLShortener *)shortener 
	        didFailForLongURL:(NSURL *)longURL 
	               statusCode:(NSInteger)statusCode
	               statusText:(NSString *)statusText;

##Troubleshooting tips

####1) Enable debugging output

Uncomment this line in BitlyDebug.h:

	#define BITLYDEBUG 1

####2) Implement delegate methods

Make sure you are implementing all methods that might be helpful from BitlyTweetSheetDelegate, BitlyTextViewDelegate, and BitlyURLShortenerDelegate.

####3) Run the sample project

Enter your bitly keys (and optionally twitter) api keys into the sample project. Run it to make sure key access is working.

####4) Get in touch

If you continue to have problems, open an issue here: https://github.com/bitly/bitly\_ios\_sdk/issues. The author of this SDK would like to shamelessly plead for your patience on the basis of being 9 months pregnant when she wrote this, see http://bit.ly/vInTHE :)

