//
//  SeeThroughView.h
//  Newton
//
//  Created by Venkata Maniteja on 2016-04-14.
//  Copyright © 2016 comm.rbc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeeThroughView : UIView

@property (assign) CGRect seeRect;
@property (assign) CGFloat maskAlpha;

@property (nonatomic, strong) IBOutlet UIView *temp;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;


@end
