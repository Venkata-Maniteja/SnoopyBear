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


-(void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message  buttonTitles:(NSArray *)titleArray selectorArray:(NSArray*)customSELArray showOnViewController:(UIViewController *)con{
    
    if (!titleArray) {
        titleArray=@[@"save",@"do nothing",@"cancel"];
    }
    
    UIAlertController *aCon=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    id cancelButton = [titleArray lastObject];
    
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        SEL customSEL=[[customSELArray objectAtIndex:idx]pointerValue];
        
        if (obj==cancelButton) {
            UIAlertAction *action=[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if (!con) { return; }
                IMP imp=[con methodForSelector:customSEL];
                void (*func)(id,SEL)=(void*)imp;
                func(con,customSEL);
                [aCon dismissViewControllerAnimated:YES completion:nil];
            }];
            [aCon addAction:action];
        }else{
            
            UIAlertAction *action=[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (!con) { return; }
                IMP imp=[con methodForSelector:customSEL];
                void (*func)(id,SEL)=(void*)imp;
                func(con,customSEL);
                [aCon dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [aCon addAction:action];
        }
    }];
    
    
    [con presentViewController:aCon animated:YES completion:nil];
    
}


@end
