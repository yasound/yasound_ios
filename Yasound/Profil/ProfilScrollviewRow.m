//
//  ProfilScrollviewRow
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilScrollviewRow.h"
#import "ProfilCellRadio.h"
#import "ProfilCellUser.h"



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

        if ([child isKindOfClass:[ProfilCellUser class]]) {
            [child removeFromSuperview];
            [child release];
        }
    }
    
    
    if ((items == nil) || (items.count == 0))
        return;
    
    id item = [items objectAtIndex:0];
    
    if ([item isKindOfClass:[YasoundRadio class]]) {
        
        [self setRadios:items];
        return;
    }

    else if ([item isKindOfClass:[User class]]) {
        
        [self setUsers:items];
        return;
    }
}

    
- (void)setRadios:(NSArray*)items {
    
    CGFloat posX = 0;
    CGFloat delay = 0.1;

    for (YasoundRadio* radio in _items) {
        
        ProfilCellRadio* cell = [[ProfilCellRadio alloc] initWithRadio:radio];
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



- (void)setUsers:(NSArray*)items {
    
    CGFloat posX = 0;
    CGFloat delay = 0.1;
    
    for (User* user in _items) {
        
        ProfilCellUser* cell = [[ProfilCellUser alloc] initWithUser:user];
        cell.frame = CGRectMake(posX, 0, cell.frame.size.width, cell.frame.size.height);
        cell.alpha = 0;
        [self.scrollview addSubview:cell];
        
        posX += cell.frame.size.width;
        posX += 24;
        
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


@end
