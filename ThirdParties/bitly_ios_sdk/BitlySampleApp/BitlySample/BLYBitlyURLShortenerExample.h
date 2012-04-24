//
//  BLYBitlyURLShortenerExample.h
//  BitlySample
//
//  Created by tracy pesin on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BitlyURLShortener.h"

@interface BLYBitlyURLShortenerExample : UIViewController <BitlyURLShortenerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *linkLabel;

- (IBAction)shortenLink:(id)sender;

@end
