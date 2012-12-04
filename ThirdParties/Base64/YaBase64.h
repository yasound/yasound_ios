// Base64.h
//
// from https://github.com/mikeho/QSUtilities
//

#import <UIKit/UIKit.h>

@interface YaBase64 : NSObject



+ (NSString*)encodeBase64WithData:(NSData*)objData;
+ (NSData*)decodeBase64WithString:(NSString*)strBase64;

@end