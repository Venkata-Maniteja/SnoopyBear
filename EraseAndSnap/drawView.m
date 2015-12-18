//
//  drawView.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "drawView.h"



@implementation drawView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        wipingInProgress = NO;
              [self setBackgroundColor:[UIColor clearColor]];
               
    }
    return self;
}



- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed {
    
    wipingInProgress = NO;
    
    eraseSpeed = speed;
    
    maskColor = color;
    
    [self setNeedsDisplay];
    
}

-(void)setErase:(UIImage *)img{
    
    eraser =img;

}

-(void)drawImage:(UIImage *) imageToDraw{
    
    self.pic=imageToDraw;
//    [imageToDraw drawInRect:self.frame];
    
    wipingInProgress = NO;
    
    eraseSpeed = 0.4;
    
//    maskColor = color;
    
    [self setNeedsDisplay];
    
}

-(void)undoTheErasing{
    
    wipingInProgress=NO;
    [self setNeedsDisplay];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.drawLock) {
    
        wipingInProgress = YES;
        
        [self.delegate setDrawStarted:YES];
        
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.drawLock) {
        
        if ([touches count] == 1) {
            UITouch *touch = [touches anyObject];
            location = [touch locationInView:self];
            location.x -= [eraser size].width/2;
            location.y -= [eraser size].width/2;
            [self setNeedsDisplay];
        }

    }
    
    
}

-(void)recordScreen{
    
    self.timer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(takeSnapShot) userInfo:nil repeats:YES];
    
}

-(void)takeSnapShot{
    
    //capture the screenshot of the uiimageview and save it in camera roll
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
     UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
}

-(void)stopShot{
    [self.timer invalidate];
}

- (void)drawRect:(CGRect)rect {
    
    
    
    
    UIImageView * iv_tap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_camera.png"]];
    [self addSubview:iv_tap];   //this could be self in your case
    iv_tap.tag = 779;
    
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        iv_tap.center=self.center;
        iv_tap.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
        [self layoutIfNeeded];    //this could be self in your case
        
    } completion:^(BOOL finished) {}];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (wipingInProgress) {
        if (imageRef) {
            // Restore the screen that was previously saved
            CGContextTranslateCTM(context, 0, rect.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, rect, imageRef);
            CGImageRelease(imageRef);
            
            CGContextTranslateCTM(context, 0, rect.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
        }
        
        // Erase the background -- raise the alpha to clear more away with eash swipe
        [eraser drawAtPoint:location blendMode:kCGBlendModeDestinationOut alpha:eraseSpeed];
    } else {
        
        
        CGRect targetBounds = self.layer.bounds;
        // fit the image, preserving its aspect ratio, into our target bounds
        CGRect imageRect = AVMakeRectWithAspectRatioInsideRect(self.pic.size,
                                                               targetBounds);
        
        
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:imageRect.size.height] forKey:@"height"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:imageRect.size.width] forKey:@"width"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:imageRect.origin.x] forKey:@"x"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:imageRect.origin.y] forKey:@"y"];
        
        // draw the image
        [self.pic drawInRect:imageRect];
        
//            [self.pic drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];//self.frame];
        }
    
    // Save the screen to restore next time around
    imageRef = CGBitmapContextCreateImage(context);
    
}

-(void)drawWithAnimation:(BOOL)value{
    
    
}


@end
