//
//  SnappingView.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-11-27.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SnappingView : UIView

@property (nonatomic,strong)  UIImage  *pic;
-(void)drawImage:(UIImage *) imageToDraw;

- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToFitSize:(CGSize)size;

@end
