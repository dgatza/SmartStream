//
//  ViewController.h
//  SmartStream
//
//  Created by Douglas Gatza on 6/25/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (readwrite) UIInterfaceOrientation viewOrientation;

@end
