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


int controlsFadeIncrementor = -1;
int controlsFadeIncrementLimit = 15;
int controlsFadePartialLimit = 3;

int logIncrementor = 0;
int logLimit = 15;

NSTimer *controlsFadeTimer;
NSTimer *progressUpdateTimer;

BOOL isPlaying = NO;
BOOL isHLS = NO;

BOOL progressDragging = NO;
BOOL progressRecovering = NO;

BOOL volumeDragging = NO;
BOOL autoPlay = NO;


// Initialize the player and default content
//============================================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.viewOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.mediaURL = @"http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8";
    
    //@"http://smooth-las-akam.istreamplanet.com/vod/iphone/getgreek_clip.m3u8";
    //@"http://stream.flowplayer.org/big_buck_bunny_with_captions.mp4";
    //@"http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8";
    
    [self configurePlayer];
    [self configurePlayerControls];
    [self configureTimers];
}


// Configures the player object for video playback
//============================================================================================================
-(void)configurePlayer
{
    self.playerObject = [[Player alloc] init]; //[Player sharedInstance];
    self.playerViewObject = [[PlayerView alloc] initWithFrame:[self getOrientedFrame]]; //[PlayerView sharedInstanceWithFrame:[self getOrientedFrame]];
    
    [self loadNewMediaWithURL:self.mediaURL AutoPlay:NO];
    [self.view addSubview: self.playerViewObject];
}


// Configures the player controls for use
//============================================================================================================
-(void)configurePlayerControls
{
    [self.playerViewObject.buttonPlay addTarget:self action:@selector(playButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonPlayLarge addTarget:self action:@selector(playButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonPause addTarget:self action:@selector(pauseButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonStop addTarget:self action:@selector(stopButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonMute addTarget:self action:@selector(muteButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonUnmute addTarget:self action:@selector(muteButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonCC addTarget:self action:@selector(ccButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerViewObject.buttonLink addTarget:self action:@selector(linkButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
}


// Configures all timers required for video playback and responsiveness.
//============================================================================================================
-(void)configureTimers
{
    //Controls fadeout timer
    controlsFadeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementControlsFade) userInfo:nil repeats:YES];
    
    //Playhead progress timer
    progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updatePlayerProgress) userInfo:nil repeats:YES];
}


// Configures all needed media player notifcations
//============================================================================================================
-(void)configureMediaPlayerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerObject.mediaPlayerItem];
    
    [self.playerObject.mediaPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    [self.playerObject.mediaPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [self.playerObject.mediaPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerObject.mediaPlayerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerObject.mediaPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerObject.mediaPlayerItem addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}


// Removes all media player notifications
//============================================================================================================
- (void)removeAllObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerObject.mediaPlayerItem];
    
    [self.playerObject.mediaPlayer removeObserver:self forKeyPath:@"rate"];
    
    [self.playerObject.mediaPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.playerObject.mediaPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerObject.mediaPlayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [self.playerObject.mediaPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.playerObject.mediaPlayerItem removeObserver:self forKeyPath:@"error"];
}


// Loads new media with URL
//============================================================================================================
-(void)loadNewMediaWithURL:(NSString *)newMediaURL AutoPlay:(BOOL)autoplayVideo
{
    BOOL mediaLoaded = NO;
    
    isHLS = [self isStreamHLS:newMediaURL]; // substringFromIndex:[newMediaURL length] - 4] isEqualToString:@"m3u8"];
    
    NSLog(@"isHLS = %i", isHLS);
    
    if (autoplayVideo) {
        autoPlay = YES;
    }
    
    self.mediaURL = newMediaURL;
    mediaLoaded = [self.playerObject loadMediaWithURL:newMediaURL];
    
    if (mediaLoaded) {
        [self mediaPlayerDidLoad];
    }
}


// Looks at the mediaURL and determines whether the stream is HLS or not
//============================================================================================================
-(BOOL)isStreamHLS:(NSString *)newMediaURL
{
    return [[newMediaURL substringFromIndex:[newMediaURL length] - 4] isEqualToString:@"m3u8"];
}


// Clears out the existing media and sets up new media using the given URL
//============================================================================================================
-(void)replaceCurrentMediaWithNewMediaAtURL:(NSString *)newMediaURL
{
    
    if ([self.playerObject playerInitialized]) {
        [self resetMediaPlayback];
    }
    
    self.mediaURL = newMediaURL;
    [self loadNewMediaWithURL:self.mediaURL AutoPlay:YES];
    [self resetControlsFadeAndShowControls:NO];
    
}


// Sets up new observers and notifications as well as updates the player layer and player frame
//============================================================================================================
-(void)updatePlayerLinkageAndView
{
    [self configureMediaPlayerNotifications];
    
    [self.playerViewObject configurePlayerView: [self.playerObject getPlayerView]];
    [self updatePlayerFrame];
}


// This method updates the video frame to fit the device's boundaries using the orientation as a guide
//============================================================================================================
-(void)updatePlayerFrame
{
    //Update the player's frame with the adjusted dimensions.
    [self.playerViewObject setFrame:[self getOrientedFrame]];
}
     

// This method updates the frame dimensions based on the device orientation
//============================================================================================================
-(CGRect)getOrientedFrame
{
    int adjustedWidth = 0;
    int adjustedHeight = 0;
    
    //If the current orientation is one of the portrait orientations, then set the dimensions to fill vertically
    if (self.viewOrientation == UIInterfaceOrientationPortrait || self.viewOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        adjustedWidth = self.view.frame.size.width;
        adjustedHeight = self.view.frame.size.height;
    //If the current orientation is one of the landscape orientations, then set the dimensions to fill horizontally
    } else {
        adjustedWidth = self.view.frame.size.height;
        adjustedHeight = self.view.frame.size.width;
    }
    
    return CGRectMake(0, 0, adjustedWidth, adjustedHeight);
}


// Sets the player volume and controls position at the same time
//============================================================================================================
-(void)updatePlayerVolumeAndControlsWithValue:(float)newVolume
{
    [self.playerViewObject updateVolumeBarByPercentage:newVolume];
    [self.playerObject setVolume:newVolume];
}


//============================================================================================================
//==========================================Player Status Methods=============================================
//============================================================================================================


// Catches all observer data
//============================================================================================================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.playerObject.mediaPlayer) {
        if ([keyPath isEqualToString:@"rate"]) {
            //NSLog(@"Media Rate = %.02f", [self.playerObject.mediaPlayer rate]);
            
            if ([self.playerObject.mediaPlayer rate] != 0.0) {
                isPlaying = YES;
                [self.playerViewObject showPlayButton:NO showBigPlay:NO];
            } else {
                isPlaying = NO;
                [self.playerViewObject showPlayButton:YES showBigPlay:NO];
            }
            
        }
    }
    
    if (object == self.playerObject.mediaPlayerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.playerObject.mediaPlayer.status == AVPlayerItemStatusReadyToPlay) {
                [self mediaPlayBackIsReady];
            } else if (self.playerObject.mediaPlayer.status == AVPlayerItemStatusUnknown) {
                //NSLog(@"Status Unknown");
            } else if (self.playerObject.mediaPlayer.status == AVPlayerItemStatusFailed) {
                //NSLog(@"Status Failed");
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            //NSLog(@"Buffer Empty");
            [self.playerViewObject showLoadingSpinner:YES];
        } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
            //NSLog(@"Buffer Full");
            [self.playerViewObject showLoadingSpinner:NO];
        }  else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            if (!isHLS) {
                [self mediaPlayBackIsReady];
            }
        } else if ([keyPath isEqualToString:@"error"]) {
            if (self.playerObject.mediaPlayerItem.error) {
                [self showStandardAlertWithAlertTitle:@"Playback Error" AlertText:@"The player has encountered an error while attempting to load the requested media.  Please check the media URL and try again." ButtonText:@"OK"];
                [self resetMediaPlayback];
            }
        }
    }
}


// Responds to the media attempting to play
//============================================================================================================
-(void)mediaPlayerDidLoad
{
    //NSLog(@"Media Loaded");
    
    [self updatePlayerLinkageAndView];
    [self updatePlayerVolumeAndControlsWithValue:self.playerObject.currentVolume];
    
    [self.playerViewObject showLoadingSpinner:YES];
    //[self.playerViewObject showPlayButton:NO showBigPlay:NO];
}


// Responds to media playback successfully streaming
//============================================================================================================
-(void)mediaPlayBackIsReady
{
    NSLog(@"Media Is Ready");
    
    [self.playerViewObject showLoadingSpinner:NO];
    [self.playerViewObject showProgressDragger:YES];
    
    if (progressRecovering) {
        progressRecovering = NO;
    }
    
    if (autoPlay) {
        autoPlay = NO;
        
        [self.playerObject playMedia];
    }
}


// Responds to media playback successfully stopping
//============================================================================================================
-(void)mediaPlayBackDidStop
{
    //NSLog(@"Media Stopped");
    
    [self.playerViewObject showPlayButton:YES showBigPlay:YES];
    [self.playerViewObject updateProgressBarByPercentage:0.0f];
    [self clearControlsFadeAndShowControls:NO];
}


// Reset the progress bar and play time again
//============================================================================================================
-(void)resetProgressBarAndPlayTime
{
    [self.playerViewObject updateProgressBarByPercentage:0.0f];
    [self.playerViewObject updatePlayTimeTextWithSeconds:0.0];
    //[self.playerViewObject updateDurationTextWithSeconds:[self.playerObject getDuration]];
}


// Responds to media playback successfully resetting
//============================================================================================================
-(void)mediaPlayBackDidReset
{
    //NSLog(@"Media Reset");
    
    [self.playerViewObject removePlayerLayer];
    [self.playerViewObject showPlayButton:YES showBigPlay:NO];
    [self.playerViewObject showProgressDragger:NO];
    [self.playerViewObject resetProgressBarText];
}


// Responds to media playback finishing
//============================================================================================================
-(void)mediaPlayBackDidFinish:(NSNotification*)notification
{
    //NSLog(@"Media Finished");
    
    [self.playerObject stopMedia];
    [self mediaPlayBackDidStop];
}


// Responds to the media playback mute state being updated
//============================================================================================================
-(void)mediaPlayBackMuted:(BOOL)playerMuted
{
    //NSLog(@"Media Muted");
    
    [self.playerViewObject showMuteButton:!playerMuted];
    
    if (playerMuted) {
        [self.playerViewObject updateVolumeBarByPercentage:0.0f];
    } else {
        [self.playerViewObject updateVolumeBarByPercentage:self.playerObject.currentVolume];
    }
}


//============================================================================================================
//==========================================Player Control Methods============================================
//============================================================================================================



// Responds to a play button touch
//============================================================================================================
-(void)playButtonHandler:(UIButton *)sender
{
    //NSLog(@"Play Button Pressed");
    
    [self resetControlsFadeAndShowControls:NO];
    
    [self.playerObject playMedia];
}


// Responds to a pause button touch
//============================================================================================================
-(void)pauseButtonHandler:(UIButton *)sender
{
    //NSLog(@"Pause Button Pressed");
    
    [self clearControlsFadeAndShowControls:NO];
    
    if ([self.playerObject playerInitialized]) {
        [self.playerObject pauseMedia];
    }
}


// Responds to a stop button touch
//============================================================================================================
-(void)stopButtonHandler:(UIButton *)sender
{
    //NSLog(@"Stop Button Pressed");
    
    [self clearControlsFadeAndShowControls:NO];
    
    if ([self.playerObject playerInitialized]) {
        [self.playerObject stopMedia];
        [self mediaPlayBackDidStop];
    }
}


// Responds to a mute button touch
//============================================================================================================
-(void)muteButtonHandler:(UIButton *)sender
{
    //NSLog(@"Mute Button Pressed");
    
    [self resetControlsFadeAndShowControls:NO];
    
    //If the volume bar is hidden, then first show it before toggling mute/unmute
    if (!self.playerViewObject.volumeBarIsVisible) {
        [self.playerViewObject showVolumeDraggerComponent:YES];
    } else {
        if ([self.playerObject playerInitialized]) {
            [self mediaPlayBackMuted:[self.playerObject toggleMuteMedia]];
            [self.playerViewObject showVolumeDraggerComponent:YES];
        }
    }
}


// Responds to a closed caption button touch
//============================================================================================================
-(void)ccButtonHandler:(UIButton *)sender
{
    //NSLog(@"CC Button Pressed");
    
    [self resetControlsFadeAndShowControls:NO];
    
    [self.playerObject toggleClosedCaptions];
}


// Reponds to the link button being pressed
//============================================================================================================
-(void)linkButtonHandler:(UIButton *)sender
{
    [self resetControlsFadeAndShowControls:NO];
    
    [self showTextInputAlertWithAlertTitle:@"Video Linking" AlertText:@"Watch another video by typing or pasting a link in the text field below." ButtonText:@"Link Video"];
}


// Coordinates a full stop of media playback
//============================================================================================================
-(void)resetMediaPlayback
{
    [self removeAllObservers];
    [self.playerObject resetMedia];
    [self mediaPlayBackDidReset];
}


// Responds to all touches on the screen
//============================================================================================================
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touches began...");
    
    [self handleTouches:touches withEvent:event withType:@"began"];
}


// Responds to all touches ending on the screen
//============================================================================================================
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touches ended...");
    
    [self handleTouches:touches withEvent:event withType:@"ended"];
}


// Responds to all touches that result in movement
//============================================================================================================
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touches moved...");
    
    [self handleTouches:touches withEvent:event withType:@"moved"];
}


// Acts as a single point of handling for touches so that drags are handled in one spot
//============================================================================================================
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event withType:(NSString *)touchType
{
    if ([self.playerObject playerInitialized]) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self.view];
        
        if ([[touch.view class] isSubclassOfClass:[UIView class]]) {
            
            UIView *testView = (UIView *)touch.view;
            CGRect dragAreaProgress = [self.playerViewObject getProgressBarDragRect];
            CGRect dragAreaVolume = [self.playerViewObject getVolumeBarDragRect];
            float progressPercentage = -1.0f;
            float volumePercentage = -1.0f;
            
            //Catches touches and moves inside the boundaries of the progress bar
            if (testView == self.playerViewObject.componentProgressBar && touchLocation.x > dragAreaProgress.origin.x && touchLocation.x < (dragAreaProgress.origin.x + dragAreaProgress.size.width)){
                
                if ([touchType isEqualToString:@"began"]) {
                    progressDragging = YES;
                }
                
                [self resetControlsFadeAndShowControls:NO];
                
                progressPercentage = (touchLocation.x - dragAreaProgress.origin.x) / ((dragAreaProgress.origin.x + dragAreaProgress.size.width) - dragAreaProgress.origin.x);
                
                [self.playerViewObject updateProgressBarByPercentage:progressPercentage];
                
            //Catches touches and moves inside the boundaries of the volume bar
            } else if ([self.playerViewObject volumeBarIsVisible] && touchLocation.x > dragAreaVolume.origin.x && touchLocation.x < (dragAreaVolume.origin.x + dragAreaVolume.size.width) && touchLocation.y > dragAreaVolume.origin.y && touchLocation.y < (dragAreaVolume.origin.y + dragAreaVolume.size.height)){
                
                if ([touchType isEqualToString:@"began"]) {
                    volumeDragging = YES;
                }
                
                [self resetControlsFadeAndShowControls:NO];
                
                volumePercentage = (dragAreaVolume.size.height - (touchLocation.y - dragAreaVolume.origin.y)) / ((dragAreaVolume.origin.y + dragAreaVolume.size.height) - dragAreaVolume.origin.y);
                
                [self updatePlayerVolumeAndControlsWithValue:volumePercentage];
                
            //Catches errant touch ends out of bounds
            } else {
                if ([touchType isEqualToString:@"began"]) {
                    [self resetControlsFadeAndShowControls:YES];
                } else if ([touchType isEqualToString:@"ended"]) {
                    //Progress Bar Handling
                    if (progressDragging) {
                        progressPercentage = (touchLocation.x - dragAreaProgress.origin.x) / ((dragAreaProgress.origin.x + dragAreaProgress.size.width) - dragAreaProgress.origin.x);
                        
                        if (progressPercentage < 0.0f) {
                            progressPercentage = 0.0f;
                        } else if (progressPercentage > 1.0f) {
                            progressPercentage = 1.0f;
                        }
                        
                    //Volume Bar Handling
                    } else if (volumeDragging) {
                        volumePercentage = (dragAreaVolume.size.height - (touchLocation.y - dragAreaVolume.origin.y)) / ((dragAreaVolume.origin.y + dragAreaVolume.size.height) - dragAreaVolume.origin.y);
                        
                        if (volumePercentage < 0.0f) {
                            volumePercentage = 0.0f;
                        } else if (volumePercentage > 1.0f) {
                            volumePercentage = 1.0f;
                        }
                    }
                }
            }
            
            //Handle out
            if (progressPercentage > -1.0) {
                if ([touchType isEqualToString:@"ended"]) {
                    //End a dragging action for the progress bar
                    if (progressDragging) {
                        NSLog(@"Progress Drag Done");
                        progressDragging = NO;
                        progressRecovering = YES;
                        [self.playerObject seekToPlayPercentage:progressPercentage];
                        [self.playerViewObject showLoadingSpinner:YES];
                    }
                    
                    //End a dragging action for the volume bar
                    if (volumeDragging) {
                        volumeDragging = NO;
                    }
                }
            }
        }
    }
}


//============================================================================================================
//=============================================Timer Methods==================================================
//============================================================================================================


// Resets the fade wait timer and also tells the player controls to show
//============================================================================================================
-(void)resetControlsFadeAndShowControls:(BOOL)allowFadeOutToggle
{
    [self resetControlsFade];
    
    if (allowFadeOutToggle) {
        if ([self.playerViewObject volumeBarIsVisible]) {
            [self.playerViewObject showVolumeDraggerComponent:NO];
        } else {
            [self.playerViewObject fadeInControlsWithFadeOutOption];
        }
    } else {
        [self.playerViewObject fadeInControls];
    }
}


// Clears the fade wait timer and also shows the player controls
//============================================================================================================
-(void)clearControlsFadeAndShowControls:(BOOL)allowFadeOutToggle
{
    [self clearControlsFade];
    
    if (allowFadeOutToggle) {
        [self.playerViewObject fadeInControlsWithFadeOutOption];
    } else {
        [self.playerViewObject fadeInControls];
    }
}


// Resets the fade wait timer
//============================================================================================================
-(void)resetControlsFade
{
    controlsFadeIncrementor = 0;
}


// Clears the fade wait timer
//============================================================================================================
-(void)clearControlsFade
{
    controlsFadeIncrementor = -1;
}


// Called by a timer, increments the fade out integer and calls a fadeout when the incrementor surpasses the limit
//============================================================================================================
-(void)incrementControlsFade
{
    //If the incrementor is active proceed
    if (controlsFadeIncrementor > -1) {
        //If the fade out integer is less than the limit, increment once
        if (controlsFadeIncrementor < controlsFadeIncrementLimit) {
            controlsFadeIncrementor++;
            
            //Handles special partial fade controls
            if (controlsFadeIncrementor > controlsFadePartialLimit) {
                [self.playerViewObject fadeOutLinkButtonPartially];
            }
        //Deactivate fade out integer and call a fade out.
        } else {
            controlsFadeIncrementor = -1; //Deactivate
            
            [self.playerViewObject fadeOutControls];
        }
    }
}


// Called by a timer, it updates the progress bar as the video progresses
//============================================================================================================
-(void)updatePlayerProgress
{
    if (isPlaying && !progressDragging && !progressRecovering) {
        float playerProgress = [self.playerObject getCurrentTime] / [self.playerObject getDuration];
        
        [self.playerViewObject updateProgressBarByPercentage:playerProgress];
        
        [self.playerViewObject updatePlayTimeTextWithSeconds:[self.playerObject getCurrentTime]];
        [self.playerViewObject updateDurationTextWithSeconds:[self.playerObject getDuration]];
        
        //Logging
        if (logIncrementor < logLimit) {
            logIncrementor++;
        } else {
            logIncrementor = 0;
            
            [self logStats];
        }
    }
}


-(void)logStats
{
    NSLog(@"%@", [self getGraphEntryWithMin: ([self.playerObject getObservedMinBitrate] / 100000) Current:([self.playerObject getObservedBitrate] / 100000) Max:([self.playerObject getObservedMaxBitrate] / 100000)]);
    
    //** TODO Expand on the other stats
}


// Takes the raw data and uses that to create a record along with a hstograph bar for user friendly viewing.
//============================================================================================================
-(NSString *)getGraphEntryWithMin:(double)minValue Current:(double)currentValue Max:(double)maxValue
{
    NSString *graphEntry;
    NSMutableString *graphBar = [NSMutableString stringWithString:@""];
    int graphBars = (int)floor(((currentValue - minValue) / (maxValue - minValue)) * 20.0);
    
    for (int i = 0; i < 20; i++) {
        if (i < graphBars) {
            [graphBar appendString:@"█"];
        } else {
            [graphBar appendString:@"░"];
        }
    }
    
    NSString *minValueAdjusted = [NSString stringWithFormat:((minValue < 100) ? @" %.0f" : ((minValue < 10) ? @"  %.0f" : @"%.0f")), minValue];
    NSString *currentValueAdjusted = [NSString stringWithFormat:((currentValue < 100) ? @" %.0f" : ((currentValue < 10) ? @"  %.0f" : @"%.0f")), currentValue];
    NSString *maxValueAdjusted = [NSString stringWithFormat:((maxValue < 100) ? @" %.0f" : ((maxValue < 10) ? @"  %.0f" : @"%.0f")), maxValue];
    
    graphEntry = [NSString stringWithFormat:@"BITRATE:  [Min| %@kbps [%@kbps %@] %@kbps |Max]", minValueAdjusted, currentValueAdjusted, graphBar, maxValueAdjusted];
    
    return graphEntry;
}


// Shows a standard alert message
//============================================================================================================
-(void)showStandardAlertWithAlertTitle:(NSString *)alertTitle AlertText:(NSString *)messageText ButtonText:(NSString *)buttonText
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:messageText
                                                       delegate:self
                                              cancelButtonTitle:buttonText
                                              otherButtonTitles:nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
}


// Shows an alert with an input field
//============================================================================================================
-(void)showTextInputAlertWithAlertTitle:(NSString *)alertTitle AlertText:(NSString *)messageText ButtonText:(NSString *)buttonText
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:messageText
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:buttonText, nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}


//============================================================================================================
//============================================================================================================
//============================================================================================================


// Responds to the alert view user input
//============================================================================================================
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Alert View dismissed with button at index %ld",(long)buttonIndex);
    
    switch (alertView.alertViewStyle)
    {
        case UIAlertViewStylePlainTextInput:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSLog(@"Plain text input: %@",textField.text);
            
            if (![textField.text isEqualToString:@""]) {
                [self replaceCurrentMediaWithNewMediaAtURL:textField.text];
            }
        }
            break;
            
        case UIAlertViewStyleSecureTextInput:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSLog(@"Secure text input: %@",textField.text);
        }
            break;
            
        case UIAlertViewStyleLoginAndPasswordInput:
        {
            UITextField *loginField = [alertView textFieldAtIndex:0];
            NSLog(@"Login input: %@",loginField.text);
            
            UITextField *passwordField = [alertView textFieldAtIndex:1];
            NSLog(@"Password input: %@",passwordField.text);
        }
            break;
            
        default:
            break;
    }
}


// Specifies which orientations the app will support
//============================================================================================================
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; //All orientations
}


// Responds to device orientation changes and updates the player frame
//============================================================================================================
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    self.viewOrientation = orientation;
    [self updatePlayerFrame];
}


// Handle memory warnings
//============================================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
