//
//  circleView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2016-01-06.
//  Copyright © 2016 Venkata Maniteja. All rights reserved.
//

#import "circleView.h"

@implementation circleView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
   
    [self drawCircleWIthSize:_circleSize withRect:rect];
   
}

-(void)drawCircleWIthSize:(CGSize) size withRect:(CGRect) rect{
    
//    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), size.width, size.height)];
//    [[UIColor clearColor] setFill];
//    [ovalPath fill];
    
}


@end
