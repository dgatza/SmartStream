//
//  PlayerView.h
//  SmartStream
//
//  Created by Douglas Gatza on 6/26/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerView : UIView

@property (strong, nonatomic) UIView            *playerViewObject;
@property (strong, nonatomic) AVPlayerLayer     *playerLayerObject;
@property (strong, nonatomic) UIView            *playerViewContainer;
@property (strong, nonatomic) UIView            *playerControlsContainer;

@property (strong, nonatomic) UIButton          *buttonPlay;
@property (strong, nonatomic) UIButton          *buttonPlayLarge;
@property (strong, nonatomic) UIButton          *buttonPause;
@property (strong, nonatomic) UIButton          *buttonStop;
@property (strong, nonatomic) UIButton          *buttonMute;
@property (strong, nonatomic) UIButton          *buttonUnmute;
@property (strong, nonatomic) UIButton          *buttonCC;
@property (strong, nonatomic) UIButton          *buttonLink;
@property (strong, nonatomic) MPVolumeView      *buttonAirPlay;
@property (strong, nonatomic) UIView            *componentProgressBar;
@property (strong, nonatomic) UIView            *componentVolumeBar;
@property (strong, nonatomic) UIImageView       *loadingSymbol;
@property (strong, nonatomic) UIImageView       *componentProgressDragBar;
@property (strong, nonatomic) UIImageView       *componentVolumeDragBar;
@property (strong, nonatomic) UIImageView       *componentProgressDragger;
@property (strong, nonatomic) UIImageView       *componentVolumeDragger;
@property (strong, nonatomic) UILabel           *textCurrentTime;
@property (strong, nonatomic) UILabel           *textDuration;



-(void)configurePlayerView:(AVPlayerLayer *)newPlayerView;
-(void)configurePlayerControls;
-(void)setFrame:(CGRect)frame;
-(void)removePlayerLayer;
-(BOOL)loadingSpinnerIsVisible;
-(void)showLoadingSpinner:(BOOL)showSpinner;
-(void)showPlayButton:(BOOL)showPlay showBigPlay:(BOOL)showBigPlay;
-(void)showMuteButton:(BOOL)showMute;
-(void)showProgressDragger:(BOOL)showDragger;
-(BOOL)volumeBarIsVisible;
-(void)showVolumeDraggerComponent:(BOOL)showComponent;
-(void)fadeOutControls;
-(void)fadeInControls;
-(void)fadeInControlsWithFadeOutOption;
-(void)fadeOutLinkButtonPartially;
-(void)updateProgressBarByPercentage:(float)barPercentage;
-(void)updateVolumeBarByPercentage:(float)barPercentage;
-(void)updatePlayTimeTextWithSeconds:(double)newTime;
-(void)updateDurationTextWithSeconds:(double)newTime;
-(void)resetProgressBarText;
-(CGRect)getProgressBarDragRect;
-(CGRect)getVolumeBarDragRect;

@end
