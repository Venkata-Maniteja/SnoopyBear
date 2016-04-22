//
//  SeeThroughView.m
//  Newton
//
//  Created by Venkata Maniteja on 2016-04-14.
//  Copyright © 2016 comm.rbc. All rights reserved.
//

#import "SeeThroughView.h"

@implementation SeeThroughView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SeeThroughView" owner:self options:nil];
        self.temp.frame=frame;
        [self addSubview:self.temp];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
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
