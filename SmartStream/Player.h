//
//  Player.h
//  SmartStream
//
//  Created by Douglas Gatza on 6/26/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Player : NSObject


@property (strong, nonatomic) MPMoviePlayerController   *videoController;
@property (strong, nonatomic) AVPlayerItem              *mediaPlayerItem;
@property (strong, nonatomic) AVPlayer                  *mediaPlayer;
@property float                                         currentVolume;


-(BOOL)loadMediaWithURL: (NSString *)mediaURL;
-(BOOL)loadMediaWithURLAndPlay: (NSString *)mediaURL;
-(void)playMedia;
-(void)pauseMedia;
-(void)stopMedia;
-(void)resetMedia;
-(BOOL)muteMedia;
-(BOOL)unmuteMedia;
-(BOOL)toggleMuteMedia;
-(void)setVolume:(float)newVolume;
-(void)toggleClosedCaptions;
-(void)seekToTime:(float)newTime;
-(void)seekToPlayPercentage:(float)playPercentage;
-(BOOL)playerInitialized;
-(BOOL)firstPlayOccured;
-(AVPlayerLayer *)getPlayerView;
-(Float64)getCurrentTime;
-(Float64)getDuration;
-(double)getObservedBitrate;
-(double)getObservedMinBitrate;
-(double)getObservedMaxBitrate;
-(double)getObservedBitrateStandardDeviation;
-(double)getIndicatedBitrate;
-(double)getSwitchBitrate;
-(NSInteger)getDroppedFrameCount;
-(NSInteger)getStallCount;
-(NSTimeInterval)getDurationWatched;
-(long long)getBytesTransferred;
-(NSDate *)getPlaybackStartDate;

@end
