//
//  CropView.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-12-16.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CropViewProtocolDelegate <NSObject>
@required
@property (assign) BOOL drawStarted;
@property (assign) BOOL  lineInterescted;
@property (nonatomic,strong) UIBezierPath *sendPath;
-(void)sendBezierPath:(UIBezierPath *)path;
@end

@interface CropView : UIView

@property (assign) id<CropViewProtocolDelegate> delegate;
@property (nonatomic,strong) UIBezierPath *path;
@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,assign) NSUInteger lineWidth;
@property (nonatomic,strong) NSMutableArray *img;
@property (nonatomic,strong) UIImage *incrementalImage;


-(void)erase;

@end
