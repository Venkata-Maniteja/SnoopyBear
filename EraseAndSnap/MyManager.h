//
//  MyManager.h
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-12-15.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyManager : NSObject

//my singleton model

//when menu is opened

//when menu option is selected

//draw mode is on/off

//first pic mode, second pic mode,

//front cam/back cam mode



//how can i use my manager for, other than saving the flags ?

@property (strong,nonatomic) UIImage *chooseImage;

+ (instancetype)sharedInstance;
-(void)showOverlay;
-(void)removeOverlay;
-(void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message  buttonTitles:(NSArray *)titleArray selectorArray:(NSArray*)customSELArray showOnViewController:(UIViewController *)con;
@end
