//
//  MyManager.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-12-15.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "MyManager.h"
#import "SeeThroughView.h"

@interface MyManager()

@property (strong,nonatomic) SeeThroughView *blurEffectView;
@end

@implementation MyManager

+ (instancetype)sharedInstance
{
    static MyManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MyManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)showOverlay{
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"OverlayShown"]) {
        
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            
            _blurEffectView = [[SeeThroughView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame]; //frame
            [_blurEffectView setBackgroundColor:[UIColor clearColor]];
            [_blurEffectView setAlpha:0.9];
            [_blurEffectView setMaskAlpha:0.85];
            [_blurEffectView setOpaque:NO];
            
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissOverlayView)];
            
            [_blurEffectView addGestureRecognizer:tapGesture];
            
            [[UIApplication sharedApplication].keyWindow addSubview:_blurEffectView];
            
            [self addCloseButton];
            
            //pop up animation
            _blurEffectView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _blurEffectView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                //animate arrow if needed
            }];
        }
        
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"OverlayShown"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    
}

-(void)addCloseButton{
    
    [_blurEffectView.closeButton addTarget:self action:@selector(dismissOverlayView) forControlEvents:UIControlEventTouchUpInside];
}


-(void)dismissOverlayView{
    
    [_blurEffectView removeFromSuperview];
}


-(void)removeOverlay{
    
}





@end
