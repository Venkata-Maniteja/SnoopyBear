//
//  MyManager.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-12-15.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "MyManager.h"

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
@end
