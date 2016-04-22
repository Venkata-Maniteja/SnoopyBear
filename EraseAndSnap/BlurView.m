//
//  BlurView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2016-01-06.
//  Copyright © 2016 Venkata Maniteja. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect transparentPart = self.seeRect;           //this is the rect of the circle view
//    CGContextAddEllipseInRect(ctx,transparentPart);  //make the circle shape
//    CGContextClip(ctx);
//    CGContextClearRect(ctx, transparentPart);
//   //added two more crazy lines
//    CGContextSetFillColorWithColor( ctx, [UIColor clearColor].CGColor );
//    CGContextFillRect( ctx, transparentPart);
//    
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Clear any existing drawing on this view
    // Remove this if the hole never changes on redraws of the UIView
    CGContextClearRect(context, self.bounds);
    
    // Create a path around the entire view
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    // Your transparent window. This is for reference, but set this either as a property of the class or some other way
    // Add the transparent window
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_seeRect cornerRadius:0.0f];
    [clipPath appendPath:path];
    
    // NOTE: If you want to add more holes, simply create another UIBezierPath and call [clipPath appendPath:anotherPath];
    
    // This sets the algorithm used to determine what gets filled and what doesn't
    clipPath.usesEvenOddFillRule = YES;
    // Add the clipping to the graphics context
    [clipPath addClip];
    
    // set your color
    UIColor *tintColor = [UIColor blackColor];
    
    // (optional) set transparency alpha
    CGContextSetAlpha(context, _maskAlpha);
    // tell the color to be a fill color
    [tintColor setFill];
    // fill the path
    [clipPath fill];
}

@end
