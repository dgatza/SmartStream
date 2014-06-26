//
//  AppDelegate.h
//  SmartStream
//
//  Created by Douglas Gatza on 6/25/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow        *window;
    ViewController  *viewController;
}

@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) ViewController	*viewController;

@end
