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
    
    
    [self.pic drawInRect:imageRect];
    
}

-(void)drawImage:(UIImage *) imageToDraw{
    
    self.pic=imageToDraw;
    
    [self setNeedsDisplay];
    
}

@end
