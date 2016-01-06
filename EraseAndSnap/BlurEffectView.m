//
//  BlurEffectView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2016-01-06.
//  Copyright © 2016 Venkata Maniteja. All rights reserved.
//

#import "BlurEffectView.h"

@implementation BlurEffectView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect transparentPart = self.seeRect;           //this is the rect of the circle view
    CGContextAddEllipseInRect(ctx,transparentPart);  //make the circle shape
    CGContextClip(ctx);
    CGContextClearRect(ctx, transparentPart);
}


@end
