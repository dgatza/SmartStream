//
//  PlayerView.m
//  SmartStream
//
//  Created by Douglas Gatza on 6/26/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView


CGPoint progressBarMin;
CGPoint progressBarMax;
CGRect progressBarDragRect;

CGPoint volumeBarMin;
CGPoint volumeBarMax;
CGRect volumeBarDragRect;


// Overrides UIView's initWithFrame method so that it calls the configurePlayerControls method.
//============================================================================================================
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.playerViewObject = [[UIView alloc] initWithFrame:self.frame];
        [self addSubview:self.playerViewObject];
        
        NSLog(@"%s Initializing Media Display", __PRETTY_FUNCTION__);
        
        [self configurePlayerControls];
    }
    
    return self;
}


// Overrides UIView's setFrame method so that the call to updatePlayerComponentsWithFrame: can be added.
//============================================================================================================
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self updatePlayerComponentsWithFrame:frame];
}


// Updates the orientation and position of the player components based on the new frame.
//============================================================================================================
-(void)updatePlayerComponentsWithFrame:(CGRect)frame
{
    [self.playerViewObject setFrame:frame];
    self.playerLayerObject.frame = self.playerViewObject.bounds;
    
    [self updateControlsCenter];
    [self updateProgressDragArea];
    [self updateVolumeDragArea];
    [self updateLoadingSpinnerCenter];
    [self updatePlayLargeButtonCenter];
    [self updateLinkButtonCenter];
}


// Removes the AV player's layer from the playerViewObject
//============================================================================================================
-(void)removePlayerLayer
{
    if (self.playerLayerObject) {
        [self.playerLayerObject removeFromSuperlayer];
    }
}


// Updates the player view object and replaces and existing one if needed
//============================================================================================================
-(void)configurePlayerView:(AVPlayerLayer *)newPlayerView
{
    [self removePlayerLayer];
    
    self.playerLayerObject = newPlayerView;
    
    self.playerLayerObject.frame = self.playerViewObject.bounds;
    [self.playerViewObject.layer addSublayer: newPlayerView];
    
    //Arrange the player view to that it's behind the controls
    [self sendSubviewToBack:self.playerViewObject];
    [self bringSubviewToFront:self.playerControlsContainer];
}


// Configures the player controls for use.
//============================================================================================================
-(void)configurePlayerControls {
    float controlsContainerWidth = 0;
    
    //Define controls container
    self.playerControlsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 580, 220)];
    [self addSubview:self.playerControlsContainer];
    
    
    //Loading Symbol
    UIImage *loadingSymbolImage = [UIImage imageNamed:@"LoadingSymbol.png"];
    self.loadingSymbol = [[UIImageView alloc] initWithImage:loadingSymbolImage];
    //self.loadingSymbol.center = CGPointMake((self.frame.size.width / 2), (self.frame.size.height / 2));
    [self updateLoadingSpinnerCenter];
    
    [self addSubview:self.loadingSymbol];
    [self showLoadingSpinner:NO];
    
    
    //Play Big Button
    self.buttonPlayLarge = [self createButtonWithFileName: @"PlayButtonLarge.png" LocationX:0 LocationY:0];
    //self.buttonPlayLarge.hidden = YES;
    [self updatePlayLargeButtonCenter];
    
    [self addSubview:self.buttonPlayLarge];
    
    
    //Link Button
    self.buttonLink = [self createButtonWithFileName: @"LinkButton.png" LocationX:0 LocationY:0];
    //self.buttonPlayLarge.hidden = YES;
    [self updateLinkButtonCenter];
    
    [self addSubview:self.buttonLink];
    
    
    //Play Button
    self.buttonPlay = [self createButtonWithFileName: @"PlayButton.png" LocationX:0 LocationY:0];
    
    controlsContainerWidth += self.buttonPlay.frame.size.width;
    
    [self.playerControlsContainer addSubview:self.buttonPlay];
    
    
    //Pause Button
    self.buttonPause = [self createButtonWithFileName: @"PauseButton.png" LocationX:0 LocationY:0];
    self.buttonPause.hidden = YES;
    
    [self.playerControlsContainer addSubview:self.buttonPause];
    
    
    //Stop Button
    self.buttonStop = [self createButtonWithFileName: @"StopButton.png" LocationX:controlsContainerWidth LocationY:0];
    
    controlsContainerWidth += self.buttonStop.frame.size.width;
    
    [self.playerControlsContainer addSubview:self.buttonStop];
    
    float heightDifference = self.buttonPlay.frame.size.height - self.buttonStop.frame.size.height;
    CGPoint newStopButtonCenter = CGPointMake(self.buttonStop.center.x, self.buttonStop.center.y + heightDifference);
    self.buttonStop.center = newStopButtonCenter;
    
    CGFloat smallButtonPositionY = self.buttonStop.frame.origin.y;
    
    
    
    //Media Progress Component
    UIImage *progressBarImage = [UIImage imageNamed:@"DragBarBack_iPhone.png"];
    UIImageView *progressBarImageView = [[UIImageView alloc] initWithImage:progressBarImage];
    self.componentProgressBar = [[UIView alloc] initWithFrame:CGRectMake(controlsContainerWidth, smallButtonPositionY, progressBarImage.size.width, progressBarImage.size.height)];
    
    [self.componentProgressBar addSubview:progressBarImageView];
    [self.playerControlsContainer addSubview:self.componentProgressBar];
    
    
    progressBarMin = CGPointMake((self.componentProgressBar.bounds.origin.x + 29.5), (self.componentProgressBar.bounds.origin.y + 29.5));
    
    progressBarMax = CGPointMake((self.componentProgressBar.bounds.origin.x + self.componentProgressBar.bounds.size.width - 29.5), (self.componentProgressBar.bounds.origin.y + 29.5));
    
    [self updateProgressDragArea];
    
    
    controlsContainerWidth += self.componentProgressBar.frame.size.width;
    
    //Progress Drag Bar
    UIImage *progressDragBarImage = [UIImage imageNamed:@"ProgressBarHorizontal.png"];
    self.componentProgressDragBar = [[UIImageView alloc] initWithImage:progressDragBarImage];
    [self.componentProgressBar addSubview:self.componentProgressDragBar];


    self.textCurrentTime = [[UILabel alloc] initWithFrame:CGRectMake(self.componentProgressBar.bounds.origin.x + 31.0, self.componentProgressBar.bounds.origin.y + 25.5, 100, 20)];
     
    self.textCurrentTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    self.textCurrentTime.text = @"";
    self.textCurrentTime.textAlignment = NSTextAlignmentLeft;
    self.textCurrentTime.textColor = [UIColor whiteColor];
    self.textCurrentTime.backgroundColor = [UIColor clearColor];
    
    [self.componentProgressBar addSubview:self.textCurrentTime];
    
    
    self.textDuration = [[UILabel alloc] initWithFrame:CGRectMake(self.componentProgressBar.bounds.origin.x + self.componentProgressBar.bounds.size.width - 131.0, self.componentProgressBar.bounds.origin.y + 25.5, 100, 20)];
    
    self.textDuration.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    self.textDuration.text = @"";
    self.textDuration.textAlignment = NSTextAlignmentRight;
    self.textDuration.textColor = [UIColor whiteColor];
    self.textDuration.backgroundColor = [UIColor clearColor];
    
    [self.componentProgressBar addSubview:self.textDuration];
    
    
    //PlayHead Dragger
    UIImage *progressDraggerImage = [UIImage imageNamed:@"DragSymbol.png"];
    self.componentProgressDragger = [[UIImageView alloc] initWithImage:progressDraggerImage];
    [self.componentProgressBar addSubview:self.componentProgressDragger];
    
    
    
    [self updateProgressBarByPercentage:0.0f];
    [self showProgressDragger:NO];
    
    
    
    //Mute Button
    self.buttonMute = [self createButtonWithFileName: @"MuteButton.png"
                                           LocationX:controlsContainerWidth
                                           LocationY:smallButtonPositionY];
    
    controlsContainerWidth += self.buttonMute.frame.size.width;
    [self.playerControlsContainer addSubview:self.buttonMute];
    
    
    //Unmute Button
    self.buttonUnmute = [self createButtonWithFileName: @"UnmuteButton.png" LocationX:self.buttonMute.frame.origin.x LocationY:smallButtonPositionY];
    self.buttonUnmute.hidden = YES;
    
    [self.playerControlsContainer addSubview:self.buttonUnmute];
    
    
    //Volume Dragger
    UIImage *volumeBarImage = [UIImage imageNamed:@"VolumeBarBack.png"];
    UIImageView *volumeBarImageView = [[UIImageView alloc] initWithImage:volumeBarImage];
    self.componentVolumeBar = [[UIView alloc] initWithFrame:CGRectMake(self.buttonMute.frame.origin.x, (smallButtonPositionY - volumeBarImage.size.height), volumeBarImage.size.width, volumeBarImage.size.height)];
    self.componentVolumeBar.alpha = 0.0;
    
    [self.componentVolumeBar addSubview:volumeBarImageView];
    [self.playerControlsContainer addSubview:self.componentVolumeBar];
    
    
    volumeBarMin = CGPointMake((self.componentVolumeBar.bounds.origin.x + 19.5), (self.componentVolumeBar.bounds.origin.y + 19.5));
    
    volumeBarMax = CGPointMake((self.componentVolumeBar.bounds.origin.x + 19.5), (self.componentVolumeBar.bounds.origin.y + self.componentVolumeBar.bounds.size.height - 19.5));
    
    [self updateVolumeDragArea];
    
    
    //Progress Drag Bar
    UIImage *volumeDragBarImage = [UIImage imageNamed:@"ProgressBarVertical.png"];
    self.componentVolumeDragBar = [[UIImageView alloc] initWithImage:volumeDragBarImage];
    [self.componentVolumeBar addSubview:self.componentVolumeDragBar];
    
    
    //PlayHead Dragger
    UIImage *volumeDraggerImage = [UIImage imageNamed:@"DragSymbol.png"];
    self.componentVolumeDragger = [[UIImageView alloc] initWithImage:volumeDraggerImage];
    [self.componentVolumeBar addSubview:self.componentVolumeDragger];
    
    [self updateVolumeBarByPercentage:0.50f];
    
    
    
    //CC Button
    self.buttonCC = [self createButtonWithFileName: @"CCButton.png" LocationX:controlsContainerWidth LocationY:smallButtonPositionY];
    self.buttonCC.hidden = YES;
    
    controlsContainerWidth += self.buttonCC.frame.size.width;
    
    [self.playerControlsContainer addSubview:self.buttonCC];
    
    
    //Airplay Button
    MPVolumeView *volumeView = [[MPVolumeView alloc] init] ;
    [volumeView setShowsVolumeSlider:NO];
    
    for (UIButton *button in volumeView.subviews)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            [button setImage:[UIImage imageNamed:@"AirPlayButton.png"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"AirPlayButton.png"] forState:UIControlStateSelected];
            [button sizeToFit];
        }
    }
    
    self.buttonAirPlay = volumeView;
    self.buttonAirPlay.center = CGPointMake(self.buttonCC.center.x - 37, self.buttonCC.center.y - 37);
    
    [self.playerControlsContainer addSubview:self.buttonAirPlay];
    
    
    //Update controls container
    [self bringSubviewToFront:self.playerControlsContainer];
    [self updateControlsCenter];
    
}


// Formats the progress bar drag rect using the current layout and placement of components so that it's automatically configured despite orientation changes
//============================================================================================================
-(void)updateProgressDragArea
{
    float containerFloatValueX = (self.frame.size.width / 2) - (self.playerControlsContainer.frame.size.width / 2);
    float containerFloatValueY = self.playerControlsContainer.center.y - (self.playerControlsContainer.frame.size.height / 2);
    
    progressBarDragRect = CGRectMake((containerFloatValueX + self.componentProgressBar.frame.origin.x + 29.5), (containerFloatValueY + self.componentProgressBar.frame.origin.y), (self.componentProgressBar.bounds.size.width - 59.0), self.componentProgressBar.frame.size.height);
}


//  Updates the playtime text field
//============================================================================================================
-(void)updatePlayTimeTextWithSeconds:(double)newTime
{
    self.textCurrentTime.text = [self returnTimeCodeFormattedStringWithSeconds:newTime];
}


//  Updates the duration text field
//============================================================================================================
-(void)updateDurationTextWithSeconds:(double)newTime
{
    self.textDuration.text = [self returnTimeCodeFormattedStringWithSeconds:newTime];
}


//  Updates the duration text field
//============================================================================================================
-(void)resetProgressBarText
{
    self.textCurrentTime.text = @"";
    self.textDuration.text = @"";
}


//  Returns a formatted time code from the passed in seconds value
//============================================================================================================
-(NSString *)returnTimeCodeFormattedStringWithSeconds:(double)secondsToDisplay
{
    int minutes = (int)floor(secondsToDisplay / 60);
    int seconds = (int)floor(secondsToDisplay - (minutes * 60));
    
    return [NSString stringWithFormat: ((seconds < 10) ? @"%i:0%i" : @"%i:%i"), minutes, seconds];
}


// Formats the volume bar drag rect using the current layout and placement of components so that it's automatically configured despite orientation changes
//============================================================================================================
-(void)updateVolumeDragArea
{
    float containerFloatValueX = (self.frame.size.width / 2) - (self.playerControlsContainer.frame.size.width / 2);
    float containerFloatValueY = self.playerControlsContainer.center.y - (self.playerControlsContainer.frame.size.height / 2);
    
    volumeBarDragRect = CGRectMake((containerFloatValueX + self.componentVolumeBar.frame.origin.x), (containerFloatValueY + self.componentVolumeBar.frame.origin.y + 19.5), self.componentVolumeBar.bounds.size.width, (self.componentVolumeBar.bounds.size.height - 39.0));
}


// Returns the progress bar's drag rect
//============================================================================================================
-(CGRect)getProgressBarDragRect
{
    return progressBarDragRect;
}


// Returns the volume bar's drag rect
//============================================================================================================
-(CGRect)getVolumeBarDragRect
{
    return volumeBarDragRect;
}


// Updates the progress bar by percentage
//============================================================================================================
-(void)updateProgressBarByPercentage:(float)barPercentage
{
    barPercentage = [self adjustRawPercentageToBeInRangePercentage:barPercentage];
    
    float barRange = progressBarMax.x - progressBarMin.x;
    float barWidth = barRange * barPercentage;
    
    CGRect newProgressFrame = CGRectMake(progressBarMin.x, progressBarMin.y, barWidth, 11.0);
    
    self.componentProgressDragBar.frame = newProgressFrame;
    self.componentProgressDragger.center = CGPointMake(self.componentProgressDragBar.frame.origin.x + self.componentProgressDragBar.bounds.size.width, self.componentProgressDragBar.frame.origin.y + (self.componentProgressDragBar.bounds.size.height / 2));
}


// Updates the volume bar by percentage
//============================================================================================================
-(void)updateVolumeBarByPercentage:(float)barPercentage
{
    barPercentage = [self adjustRawPercentageToBeInRangePercentage:barPercentage];
    
    float barRange = volumeBarMax.y - volumeBarMin.y;
    float barHeight = barRange * barPercentage;
    
    CGRect newVolumeFrame = CGRectMake(volumeBarMin.x, (volumeBarMin.y + (barRange - barHeight)), 11.0, barHeight);
    
    self.componentVolumeDragBar.frame = newVolumeFrame;
    self.componentVolumeDragger.center = CGPointMake(self.componentVolumeDragBar.frame.origin.x + (self.componentVolumeDragBar.bounds.size.width / 2), self.componentVolumeDragBar.frame.origin.y);
}


// Takes a raw percentage value pulled from UI calculations and formats it to be a 0.0 - 1.0 percentage range
//============================================================================================================
-(float)adjustRawPercentageToBeInRangePercentage:(float)barPercentage
{
    if (barPercentage < 0.0) {
        barPercentage = 0.0;
    } else if (barPercentage > 1.0) {
        barPercentage = 1.0;
    }
    
    return barPercentage;
}


// Gets the progress percentage by current progress bar width
//============================================================================================================
-(float)getPercentageByProgressBarWidth
{
    float barRange = progressBarMax.x - progressBarMin.x;
    
    return (self.componentProgressDragBar.bounds.size.width / barRange);
}


// Updates the controls container center using the main view's width and height.
//============================================================================================================
-(void)updateControlsCenter
{
    CGPoint newControlsCenter = CGPointMake((self.bounds.size.width / 2), (self.bounds.size.height + 20.0));
    self.playerControlsContainer.center = newControlsCenter;
}


// Updates the loading spinner center using the main view's width and height.
//============================================================================================================
-(void)updateLoadingSpinnerCenter
{
    CGPoint newLoadingSpinnerCenter = CGPointMake((self.frame.size.width / 2), (self.frame.size.height / 2));
    self.loadingSymbol.center = newLoadingSpinnerCenter;
}


// Updates the play large button center using the main view's width and height.
//============================================================================================================
-(void)updatePlayLargeButtonCenter
{
    CGPoint newButtonLargeCenter = CGPointMake((self.frame.size.width / 2), (self.frame.size.height / 2));
    self.buttonPlayLarge.center = newButtonLargeCenter;
}


// Updates the link button center using the main view's width and height.
//============================================================================================================
-(void)updateLinkButtonCenter
{
    CGPoint newButtonLinkCenter = CGPointMake((self.frame.size.width / 2), ((self.buttonLink.bounds.size.height / 2) + 20));
    self.buttonLink.center = newButtonLinkCenter;
}


// A reusable create button method using a few parameters
//============================================================================================================
-(UIButton *)createButtonWithFileName:(NSString *)fileName LocationX:(float)locationX LocationY:(float)locationY
{
    UIImage *buttonImage = [UIImage imageNamed:fileName];
    UIButton *buttonSubview = [[UIButton alloc] init];
    
    [buttonSubview setImage:buttonImage forState:UIControlStateNormal];
    [buttonSubview setEnabled:YES];
    
    buttonSubview.frame = CGRectMake(locationX, locationY, buttonImage.size.width, buttonImage.size.height);
    
    return buttonSubview;
}


// Returns the loading spinner's display state
//============================================================================================================
-(BOOL)loadingSpinnerIsVisible
{
    return !self.loadingSymbol.hidden;
}


// Shows or hides the loading spinner and defines the spinner's animation the first time it's shown.
//============================================================================================================
-(void)showLoadingSpinner:(BOOL)showSpinner
{
    if (showSpinner) {
        if ([self.layer animationForKey:@"loadingAnimation"] == nil) {
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2.0f * M_PI];
            animation.duration = 2.0f;
            animation.repeatCount = INFINITY;
            [self.loadingSymbol.layer addAnimation:animation forKey:@"loadingAnimation"];
        }
        
        [self fadeInUIView:self.loadingSymbol];
        //self.loadingSymbol.hidden = NO;
    } else {
        [self fadeOutUIView:self.loadingSymbol];
        //self.loadingSymbol.hidden = YES;
    }
}


// Used to toggle the play and pause buttons so that they never show up at the same time.
//============================================================================================================
-(void)showPlayButton:(BOOL)showPlay showBigPlay:(BOOL)showBigPlay
{
    if (showPlay){
        self.buttonPlay.hidden = NO;
        self.buttonPause.hidden = YES;
        
        if (showBigPlay) {
            [self fadeInUIView:self.buttonPlayLarge];
            //self.buttonPlayLarge.hidden = NO;
        }
    } else {
        self.buttonPlay.hidden = YES;
        self.buttonPause.hidden = NO;
        
        [self fadeOutUIView:self.buttonPlayLarge];
        //self.buttonPlayLarge.hidden = YES;
    }
}


// Used to toggle the mute and unmute buttons so that they never show up at the same time.
//============================================================================================================
-(void)showMuteButton:(BOOL)showMute
{
    self.buttonMute.hidden = !showMute;
    self.buttonUnmute.hidden = showMute;
}


// Shows or hides the progress dragger
//============================================================================================================
-(void)showProgressDragger:(BOOL)showDragger
{
    self.componentProgressDragger.hidden = !showDragger;
}


// Returns the volume bar visibility state [UNIT]
//============================================================================================================
-(BOOL)volumeBarIsVisible
{
    return !self.componentVolumeBar.hidden && self.componentVolumeBar.alpha == 1.0;
}


// Shows or hides the volume bar
//============================================================================================================
-(void)showVolumeDraggerComponent:(BOOL)showComponent
{
    if (showComponent) {
        [self fadeInUIView:self.componentVolumeBar];
        //self.componentVolumeBar.hidden = NO;
    } else {
        [self fadeOutUIView:self.componentVolumeBar];
        //self.componentVolumeBar.hidden = YES;
    }
}


// Fades out the player controls
//============================================================================================================
-(void)fadeOutControls
{
    [self fadeOutUIView:self.playerControlsContainer];
    [self fadeOutUIView:self.buttonLink];
    [self showVolumeDraggerComponent:NO]; //Hide the volume dragger when controls hide
}


// Fades in the player controls
//============================================================================================================
-(void)fadeInControls
{
    [self fadeInUIView:self.playerControlsContainer];
    [self fadeInUIView:self.buttonLink];
}


// Fades in the player controls with an additional option to fadeout if already faded in
//============================================================================================================
-(void)fadeInControlsWithFadeOutOption
{
    if (self.playerControlsContainer.alpha < 1.0f) {
        [self fadeInControls];
    } else {
        [self fadeOutControls];
    }
}


// Fades out the link button partially
//============================================================================================================
-(void)fadeOutLinkButtonPartially
{
    [self fadeOutButtonPartially:self.buttonLink];
}


// Fades out any button control partially that's passed
//============================================================================================================
-(void)fadeOutButtonPartially:(UIButton *)buttonObject
{
    buttonObject.alpha = buttonObject.alpha;
    [UIButton beginAnimations:@"fadeOutUIViewAnimation" context:NULL];
    [UIButton setAnimationDuration:0.75];
    buttonObject.alpha = 0.3f;
    [UIButton commitAnimations];
}


// Fades out a passed UIView object
//============================================================================================================
-(void)fadeOutUIView:(UIView *)viewToFade
{
    viewToFade.alpha = viewToFade.alpha;
    [UIView beginAnimations:@"fadeOutUIViewAnimation" context:NULL];
    [UIView setAnimationDuration:0.75];
    viewToFade.alpha = 0.0f;
    [UIView commitAnimations];
}


// Fades in a passed UIView object
//============================================================================================================
-(void)fadeInUIView:(UIView *)viewToFade
{
    //Only fade out if the object's alpha is less than 1.0f
    if (viewToFade.alpha < 1.0f) {
        viewToFade.alpha = viewToFade.alpha;
        [UIView beginAnimations:@"fadeInUIViewAnimation" context:NULL];
        [UIView setAnimationDuration:0.75];
        viewToFade.alpha = 1.0f;
        [UIView commitAnimations];
    }
}


@end
