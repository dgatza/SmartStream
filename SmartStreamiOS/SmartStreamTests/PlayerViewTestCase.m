//
//  PlayerViewTestCase.m
//  SmartStream
//
//  Created by Douglas Gatza on 7/2/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PlayerView.h"

@interface PlayerViewTestCase : XCTestCase

@end

@implementation PlayerViewTestCase

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


-(void)testPlayerViewObjectInheritsFrameFromSuperviewInit
{
    CGRect frame1 = CGRectMake(10, 30, 50, 70);
    
    //The test rect should be passed upon init
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Check if the test rect is the same as the player view object frame rect
    BOOL playerViewObjectFrameMatchesFrame1 = CGRectEqualToRect(playerView.playerViewObject.frame, frame1);
    
    XCTAssertEqual(playerViewObjectFrameMatchesFrame1, YES, @"Player view object frame does not match superview frame.");
}


-(void)testPlayerViewObjectInheritsFrameFromSuperviewSetFrame
{
    NSLog(@"%s Testing video display subview inherits frame from superview setFrame method...", __PRETTY_FUNCTION__);
    
    CGRect frame1 = CGRectMake(10, 30, 50, 70);
    CGRect frame2 = CGRectMake(20, 40, 60, 80);
    
    //Init with rect 1
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Call setFrame passing rect 2
    [playerView setFrame:frame2];
    
    //Check whether the player view object is using rect 2
    BOOL playerViewObjectFrameMatchesFrame2 = CGRectEqualToRect(playerView.playerViewObject.frame, frame2);
   
    XCTAssertEqual(playerViewObjectFrameMatchesFrame2, YES, @"Player view object frame does not match superview frame.");
}


-(void)testControlsCenterXAlignsWithViewCenterX
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    //Initialization automatically configures the controls and should correctly center them.
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define where the center point.x should be
    float screenCenterX = playerView.frame.size.width / 2;
    
    //Compare the controls center.x with the defined center point
    BOOL controlsCenterXMatchesViewCenterX = (playerView.playerControlsContainer.center.x == screenCenterX);
    
    XCTAssertEqual(controlsCenterXMatchesViewCenterX, YES, @"Player controls are not automatically centering.");
}


-(void)testProgressBarFillMatchesStandardPercentage
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width
    float barPercentage = 0.33;
    float barRange = playerView.componentProgressBar.bounds.size.width - 59.0;
    float barWidth = barRange * barPercentage;
    
    //Call the actual tool that configures this component
    [playerView updateProgressBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barWidthMatchesEstimatedWidth = (playerView.componentProgressDragBar.bounds.size.width == barWidth);
    
    XCTAssertEqual(barWidthMatchesEstimatedWidth, YES, @"Progress bar width is not matching estimated width.");
}


-(void)testProgressBarFillSetToZeroUponNegativePercentageValue
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width
    float barPercentage = -0.33;
    float barWidth = 0.0;
    
    //Call the actual tool that configures this component
    [playerView updateProgressBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barWidthMatchesEstimatedWidth = (playerView.componentProgressDragBar.bounds.size.width == barWidth);
    
    XCTAssertEqual(barWidthMatchesEstimatedWidth, YES, @"Progress bar width is not matching estimated width.");
}


-(void)testProgressBarFillSetUsingInteger
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width using an int for percentage
    int barPercentage = 2;
    float barRange = playerView.componentProgressBar.bounds.size.width - 59.0;
    float barWidth = barRange;
    
    //Call the actual tool that configures this component
    [playerView updateProgressBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barWidthMatchesEstimatedWidth = (playerView.componentProgressDragBar.bounds.size.width == barWidth);
    
    XCTAssertEqual(barWidthMatchesEstimatedWidth, YES, @"Progress bar width is not matching estimated width.");
}


-(void)testVolumeBarFillMatchesStandardPercentage
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width
    float barPercentage = 0.33;
    float barRange = playerView.componentVolumeBar.bounds.size.height - 39.0;
    float barHeight = barRange * barPercentage;
    
    //Call the actual tool that configures this component
    [playerView updateVolumeBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barHeightMatchesEstimatedHeight = (playerView.componentVolumeDragBar.bounds.size.height == barHeight);
    
    XCTAssertEqual(barHeightMatchesEstimatedHeight, YES, @"Volume bar height is not matching estimated height.");
}


-(void)testVolumeBarFillSetToZeroUponNegativePercentageValue
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width
    float barPercentage = -0.33;
    float barHeight = 0.0;
    
    //Call the actual tool that configures this component
    [playerView updateVolumeBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barHeightMatchesEstimatedHeight = (playerView.componentVolumeDragBar.bounds.size.height == barHeight);
    
    XCTAssertEqual(barHeightMatchesEstimatedHeight, YES, @"Volume bar height is not matching estimated height.");
}


-(void)testVolumeBarFillSetUsingInteger
{
    CGRect frame1 = CGRectMake(0, 0, 1000, 500);
    
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:frame1];
    
    //Define estimated range and bar width using an int for percentage
    int barPercentage = 2;
    float barRange = playerView.componentVolumeBar.bounds.size.height - 39.0;
    float barHeight = barRange;
    
    //Call the actual tool that configures this component
    [playerView updateVolumeBarByPercentage:barPercentage];
    
    //Measure the bar width and compare to the estimated width
    BOOL barHeightMatchesEstimatedHeight = (playerView.componentVolumeDragBar.bounds.size.height == barHeight);
    
    XCTAssertEqual(barHeightMatchesEstimatedHeight, YES, @"Volume bar height is not matching estimated height.");
}

@end
