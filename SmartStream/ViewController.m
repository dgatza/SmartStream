//
//  ViewController.m
//  SmartStream
//
//  Created by Douglas Gatza on 6/25/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self loadVideoWithURL: @"http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadVideoWithURL: (NSString *)videoURL {
    
    NSURL *mediaURL = [NSURL URLWithString:videoURL];
    
    self.videoController = [[MPMoviePlayerController alloc] init];
    
    [self declareMediaPlayerNotifications];
    
    [self.videoController setControlStyle:MPMovieControlStyleFullscreen];
    [self.videoController setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.videoController setFullscreen:YES];
    [self.videoController setContentURL:mediaURL];
    
    [self updatePlayerFrame];
    [self.view addSubview:self.videoController.view];
    
    [self.videoController prepareToPlay];
    [self.videoController play];
    
    //[self statusBarWillDisappear];
}


//This method updates the video frame to fit the device's boundaries using the orientation as a guide.
-(void)updatePlayerFrame {
    int adjustedWidth = 0;
    int adjustedHeight = 0;
    
    //Make sure the video controller is defined before attempting to manipulate it.
    if (self.videoController) {
        //  If the current orientation is one of the portrait orientations, then set the dimensions to fill vertically
        if (self.viewOrientation == UIInterfaceOrientationPortrait || self.viewOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            adjustedWidth = self.view.frame.size.width;
            adjustedHeight = self.view.frame.size.height;
        //  If the current orientation is one of the landscape orientations, then set the dimensions to fill horizontally
        } else {
            adjustedWidth = self.view.frame.size.height;
            adjustedHeight = self.view.frame.size.width;
        }
        
        //Update the player's frame with the adjusted dimensions.
        [self.videoController.view setFrame:CGRectMake(0, 0, adjustedWidth, adjustedHeight)];
    }
}


-(void)declareMediaPlayerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlayBackDidStart:)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}


-(void)mediaPlayBackDidStart:(NSNotification*)notification {
    NSLog(@"Media Started");
    //[self statusBarWillDisappear];
}


-(void)mediaPlayBackDidFinish:(NSNotification*)notification {
    NSLog(@"Media Finished");
    //[self statusBarWillAppear];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    self.viewOrientation = orientation;
    [self updatePlayerFrame];
}


- (void)statusBarWillAppear
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}


- (void)statusBarWillDisappear
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

@end
