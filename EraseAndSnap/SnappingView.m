//
//  SnappingView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-11-27.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "SnappingView.h"

@implementation SnappingView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGRect targetBounds = self.layer.bounds;
    // fit the image, preserving its aspect ratio, into our target bounds
    CGRect imageRect = AVMakeRectWithAspectRatioInsideRect(self.pic.size,
                                                           targetBounds);
    
    
//    [self.pic drawInRect:imageRect];

     [self.pic drawInRect:rect];
    
    
}

-(void)drawImage:(UIImage *) imageToDraw{
    
    self.pic=imageToDraw;
    
    [self setNeedsDisplay];
    
    
}

- (UIImage *)imageScaledToSize:(CGSize)size
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    
    //draw
    [self.pic drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    _pic = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //return image
    return _pic;
}

- (UIImage *)imageScaledToFitSize:(CGSize)size
{
    //calculate rect
    CGFloat aspect = self.frame.size.width / self.frame.size.height;
    if (size.width / aspect <= size.height)
    {
        return [self imageScaledToSize:CGSizeMake(size.width, size.width / aspect)];
    }
    else
    {
        return [self imageScaledToSize:CGSizeMake(size.height * aspect, size.height)];
    }
}


@end
