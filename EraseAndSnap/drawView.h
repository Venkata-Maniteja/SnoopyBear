//
//  drawView.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface drawView : UIView{
    
    CGPoint		location;
    CGImageRef	imageRef;
    UIImage		*eraser;
    BOOL		wipingInProgress;
    UIColor		*maskColor;
    CGFloat		eraseSpeed;
    BOOL        imageDraw;
   
    
}

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong)  UIImage  *pic;

-(void)stopShot;
-(void)recordScreen;
- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed;
-(void)drawImage:(UIImage *) imageToDraw;
@end
