//
//  CropView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-12-16.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "CropView.h"
#import "Line.h"

@implementation CropView
{
    
    NSMutableArray *pathArray;
    Line  *line;
}

- (id)initWithCoder:(NSCoder *)aDecoder // (1)
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO]; // (2)
        _path = [UIBezierPath bezierPath];
        [_path setLineWidth:_lineWidth];
        pathArray=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect // (5)
{
    [_lineColor setStroke];
    [_path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [_path moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
     [self.delegate setDrawStarted:YES];
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [_path addLineToPoint:p]; // (4)
    
    
    CGPoint pointA = [touch previousLocationInView:touch.view];
    CGPoint pointB = [touch locationInView:touch.view];
    
    line = [[Line alloc]init];
    [line setPointA:pointA];
    [line setPointB:pointB];
    
    [pathArray addObject:line];
    
    for(Line *l in pathArray) {
        
        CGPoint pa = l.pointA;
        CGPoint pb = l.pointB;
        
        //NSLog(@"Point A: %@", NSStringFromCGPoint(pa));
        //NSLog(@"Point B: %@", NSStringFromCGPoint(pb));
        
        if ([self checkLineIntersection:pointA :pointB :pa :pb])
        {
            [pathArray removeAllObjects];
            //[_path removeAllPoints];
            [self.delegate sendBezierPath:_path];
            [self setNeedsDisplay];
            NSLog(@"Removed path!");
            return;
        }
    }

    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


-(void)erase{
    
    _path   = nil;  //Set current path nil
    _path   = [UIBezierPath bezierPath]; //Create new path
    [pathArray removeAllObjects];
   
     [self setNeedsDisplay];
}

-(BOOL)checkLineIntersection:(CGPoint)p1 :(CGPoint)p2 :(CGPoint)p3 :(CGPoint)p4
{
    CGFloat denominator = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y);
    CGFloat ua = (p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x);
    CGFloat ub = (p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x);
    if (denominator < 0) {
        ua = -ua; ub = -ub; denominator = -denominator;
    }
    return (ua > 0.0 && ua <= denominator && ub > 0.0 && ub <= denominator);
}


@end
