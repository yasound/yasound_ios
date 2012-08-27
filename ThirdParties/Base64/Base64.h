// Base64.h
//
// from https://github.com/mikeho/QSUtilities
//

#import <UIKit/UIKit.h>

@interface Base64 : NSObject



+ (NSString*)encodeBase64WithData:(NSData*)objData;
+ (NSData*)decodeBase64WithString:(NSString*)strBase64;

@end