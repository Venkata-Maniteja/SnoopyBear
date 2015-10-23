//
//  ViewController.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "CaptureSessionManager.h"
#import "drawView.h"

@interface ViewController : UIViewController<DrawViewProtocolDelegate>


@property (retain) CaptureSessionManager *captureManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;

@property (nonatomic,strong) IBOutlet UIBarButtonItem *choosePic;

@property (nonatomic,strong) IBOutlet UIBarButtonItem *clear;


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;


@end

