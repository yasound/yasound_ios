//
//  ProfilScrollviewRow
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilScrollviewRow.h"
#import "ProfilCellRadio.h"

@implementation ProfilScrollviewRow

@synthesize title;
@synthesize scrollview;
@synthesize items = _items;
@synthesize indicator;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(32, 72, 22, 22)];
		[self addSubview:indicator];
		self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[self.indicator startAnimating];
    }
    
    return self;
}


- (void)setItems:(NSArray *)items
{
    [self.indicator stopAnimating];
    [self.indicator release];
     
    if (_items != nil) {
        [_items release];
        _items = nil;
    }
    
    _items = items;
    [_items retain];
    
    for (UIView* child in self.scrollview.subviews) {
        if ([child isKindOfClass:[ProfilCellRadio class]]) {
            [child removeFromSuperview];
            [child release];
        }
    }
    
    CGFloat posX = 0;
    CGFloat delay = 0.1;
    
    for (Radio* radio in _items) {
        
        ProfilCellRadio* cell = [[ProfilCellRadio alloc] initWithRadio:radio target:self action:@selector(onRadioClicked:)];
        cell.frame = CGRectMake(posX, 0, cell.frame.size.width, cell.frame.size.height);
        cell.alpha = 0;
        [self.scrollview addSubview:cell];
        
        posX += cell.frame.size.width;
        posX += 4;

        // animation to delay the display
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:delay];
        [UIView setAnimationDuration:0.3];
        cell.alpha = 1;
        [UIView commitAnimations];
        
        delay += 0.1;
    }
    
    self.scrollview.contentSize = CGSizeMake(posX, self.scrollview.contentSize.height);


}

//- (void)onCellShow:(ProfilCellRadio*)cell
//{
//    
//}


- (void)onRadioClicked:(Radio*)radio {
    
}

@end
