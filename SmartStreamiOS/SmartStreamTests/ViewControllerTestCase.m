//
//  ViewControllerTestCase.m
//  SmartStream
//
//  Created by Douglas Gatza on 7/2/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface ViewControllerTestCase : XCTestCase

@end

@implementation ViewControllerTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testOrientedFrameIsReturnedBasedOnDeviceOrientation
{
    ViewController *viewController = [[ViewController alloc] init];
    
    //Pt. 1
    viewController.viewOrientation = UIInterfaceOrientationPortrait;
    
    CGRect portraitRect = [viewController getOrientedFrame];
    
    BOOL frameIsPortrait = (portraitRect.size.height > portraitRect.size.width);
    
    //Pt. 2
    viewController.viewOrientation = UIInterfaceOrientationLandscapeLeft;
    
    CGRect landscapeRect = [viewController getOrientedFrame];
    
    BOOL frameIsLandscape = (landscapeRect.size.width > landscapeRect.size.height);
    
    BOOL frameOrientedCorrectlyInBothCases = (frameIsPortrait && frameIsLandscape);
    
    XCTAssertEqual(frameOrientedCorrectlyInBothCases, YES, @"Method not correctly returning oriented frame rect");
}


-(void)testIsStreamHLS
{
    ViewController *viewController = [[ViewController alloc] init];
    
    NSString * hlsURL = @"http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8";
    
    NSString * mp4URL = @"http://stream.flowplayer.org/big_buck_bunny_with_captions.mp4";
    
    BOOL test1 = [viewController isStreamHLS:hlsURL];
    BOOL test2 = [viewController isStreamHLS:mp4URL];
    
    BOOL sucessfullyEvaluatedURLContents = (test1 && !test2);
    
    XCTAssertEqual(sucessfullyEvaluatedURLContents, YES, @"Method not properly searching for key values.");
}

/*
-(void)testUpdatePlayerVolumeAndControlsCorrectlySetsVolumeBar
{
    ViewController *viewController = [[ViewController alloc] init];
    
    [viewController.playerViewObject  updateVolumeBarByPercentage:0.66];
    
    float playerVolume = 0.33;
    float barRange = viewController.playerViewObject.componentVolumeBar.bounds.size.height - 39.0;
    float barHeight = barRange * playerVolume;
    
    [viewController updatePlayerVolumeAndControlsWithValue:playerVolume];
    
    BOOL barHeightCorrectlyReflectsValueChange = (viewController.playerViewObject.componentVolumeDragBar.bounds.size.height == barHeight);
    
    XCTAssertEqual(barHeightCorrectlyReflectsValueChange, YES, @"Problem translating new value to bar component");
}
*/

/*
-(void)testUpdatePlayerVolumeAndControlsCorrectlySetsVolumeLevel
{
    ViewController *viewController = [[ViewController alloc] init];
    
    [viewController.playerObject setVolume:0.66]; //Sets one value first
    
    float playerVolume = 0.33;
    
    [viewController updatePlayerVolumeAndControlsWithValue:playerVolume];  //Sets new value using the method in question.
    
    BOOL playerVolumeReflectsNewValue = (viewController.playerObject.mediaPlayer.volume == playerVolume);
    
    XCTAssertEqual(playerVolumeReflectsNewValue, YES, @"Problem translating new value to player component");
}
*/

@end
