//
//  ViewController.h
//  SmartStream
//
//  Created by Douglas Gatza on 6/25/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Player.h"
#import "PlayerView.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) Player                    *playerObject;
@property (strong, nonatomic) PlayerView                *playerViewObject;
@property (strong, nonatomic) MPMoviePlayerController   *videoController;
@property (strong, nonatomic) NSString                  *mediaURL;
@property UIInterfaceOrientation                        viewOrientation;

-(CGRect)getOrientedFrame;
-(BOOL)isStreamHLS:(NSString *)newMediaURL;
-(void)updatePlayerVolumeAndControlsWithValue:(float)newVolume;

@end
