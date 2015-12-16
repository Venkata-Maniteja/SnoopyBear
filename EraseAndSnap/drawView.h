//
//  drawView.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol DrawViewProtocolDelegate <NSObject>
@required
@property (assign) BOOL drawStarted;
@property (assign) BOOL  lineInteresctedInCropView;
-(void)sendBezierPath:(UIBezierPath *)path;
@end


@interface drawView : UIView{
    
    CGPoint		location;
    CGImageRef	imageRef;
    UIImage		*eraser;
    BOOL		wipingInProgress;
    UIColor		*maskColor;
    CGFloat		eraseSpeed;
    BOOL        imageDraw;
    
    
}
@property (assign) id<DrawViewProtocolDelegate> delegate;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong)  UIImage  *pic;
@property (assign) BOOL drawLock;

-(void)stopShot;
-(void)recordScreen;
- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed;
-(void)drawImage:(UIImage *) imageToDraw;
-(void)setErase:(UIImage *)img;
-(void)undoTheErasing;


@end
