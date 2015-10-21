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

@interface ViewController : UIViewController


@property (retain) CaptureSessionManager *captureManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;


@end

