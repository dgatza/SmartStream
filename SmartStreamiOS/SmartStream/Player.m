//
//  Player.m
//  SmartStream
//
//  Created by Douglas Gatza on 6/26/14.
//  Copyright (c) 2014 Manta Innovations, LLC. All rights reserved.
//

#import "Player.h"

@implementation Player

BOOL playerMuted = NO; //Used to keep mute state between video sessions
BOOL firstPlayOccured = NO;


// Instantiates the video controller
//============================================================================================================
- (id)init
{
    self = [super init];
    
    if (self) {
        self.currentVolume = 1.0f;
    }
    
    return self;
}


// Loads new media with a URL and plays it
//============================================================================================================
-(BOOL)loadMediaWithURLAndPlay: (NSString *)mediaURL {
    BOOL returnVal = [self loadMediaWithURL:mediaURL];
    [self playMedia];
    
    return returnVal;
}


// Loads media from the passed URL
//============================================================================================================
-(BOOL)loadMediaWithURL: (NSString *)mediaURL
{
    NSURL *mediaURLObject = [NSURL URLWithString:mediaURL];
    self.mediaPlayerItem = [AVPlayerItem playerItemWithURL:mediaURLObject];
    self.mediaPlayer = [AVPlayer playerWithPlayerItem:self.mediaPlayerItem];
    
    if (playerMuted) {
        [self muteMedia];
    }
    
    return (self.mediaPlayerItem);
}


// Plays the player
//============================================================================================================
-(void)playMedia
{
    if (!firstPlayOccured) {
        firstPlayOccured = YES;
    }
    
    [self.mediaPlayer play];
}


// Pauses the player
//============================================================================================================
-(void)pauseMedia
{
    [self.mediaPlayer pause];
}


// Stops and resets the player
//============================================================================================================
-(void)stopMedia
{
    [self.mediaPlayer pause];
    [self seekToTime:0.0f];
}


// Resets the loaded media
//============================================================================================================
-(void)resetMedia
{
    [self stopMedia];
    
    self.mediaPlayerItem = nil;
    self.mediaPlayer = nil;
}


// Mutes the player
//============================================================================================================
-(BOOL)muteMedia
{
    [self.mediaPlayer setMuted:YES];
    
    playerMuted = self.mediaPlayer.muted;
    
    return (self.mediaPlayer.muted);
}


// Unmutes the player
//============================================================================================================
-(BOOL)unmuteMedia
{
    [self.mediaPlayer setMuted:NO];
    
    playerMuted = self.mediaPlayer.muted;
    
    return (!self.mediaPlayer.muted);
}


// Sets the player volume
//============================================================================================================
-(void)setVolume:(float)newVolume
{
    self.currentVolume = newVolume;
    self.mediaPlayer.volume = self.currentVolume;
}


// Toggles between muted and unmuted
//============================================================================================================
-(BOOL)toggleMuteMedia
{
    [self.mediaPlayer setMuted:!self.mediaPlayer.muted];
    
    playerMuted = self.mediaPlayer.muted;
    
    return self.mediaPlayer.muted;
}


// Toggles closed captions on and off - Note: Does not manipulate hls CC/Sub-Titles
//============================================================================================================
-(void)toggleClosedCaptions
{
    [self.mediaPlayer setClosedCaptionDisplayEnabled:!self.mediaPlayer.closedCaptionDisplayEnabled];
}


// Seeks to a point in the timeline using a percentage
//============================================================================================================
-(void)seekToPlayPercentage:(float)playPercentage
{
    [self seekToTime:([self getDuration] * playPercentage)];
}


// Seeks to a point in the timeline using a time value
//============================================================================================================
-(void)seekToTime:(float)newTime
{
    int32_t timeScale = self.mediaPlayer.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(newTime, timeScale);
    [self.mediaPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


// Returns the AVPlayer's init state
//============================================================================================================
-(BOOL)playerInitialized
{
    return (self.mediaPlayerItem);
}


// Tells the caller whether the first play has occurred
//============================================================================================================
-(BOOL)firstPlayOccured
{
    return firstPlayOccured;
}


// Returns the player's view object
//============================================================================================================
-(AVPlayerLayer *)getPlayerView
{
    AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.mediaPlayer];
    
    return playerLayer;
}


// Returns the current time
//============================================================================================================
-(Float64)getCurrentTime
{
    return CMTimeGetSeconds([self.mediaPlayer currentTime]);
}


// Returns the duration
//============================================================================================================
-(Float64)getDuration
{
    return CMTimeGetSeconds([[[self.mediaPlayer currentItem] asset] duration]);
}


// Returns the observed bitrate
//============================================================================================================
-(double)getObservedBitrate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject observedBitrate];
}


// Returns the minimum observed bitrate
//============================================================================================================
-(double)getObservedMinBitrate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject observedMinBitrate];
}


// Returns the maximum observed bitrate
//============================================================================================================
-(double)getObservedMaxBitrate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject observedMaxBitrate];
}


// Returns the standard deviation for observed bitrate
//============================================================================================================
-(double)getObservedBitrateStandardDeviation
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject observedBitrateStandardDeviation];
}


// Returns the indicated bitrate
//============================================================================================================
-(double)getIndicatedBitrate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject indicatedBitrate];
}


// Returns the switch bitrate
//============================================================================================================
-(double)getSwitchBitrate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject switchBitrate];
}


// Returns the dropped frames count
//============================================================================================================
-(NSInteger)getDroppedFrameCount
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject numberOfDroppedVideoFrames];
}


// Returns the stall count
//============================================================================================================
-(NSInteger)getStallCount
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject numberOfStalls];
}


// Returns the cumulative duration watched
//============================================================================================================
-(NSTimeInterval)getDurationWatched
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject durationWatched];
}


// Returns the total bytes transferred
//============================================================================================================
-(long long)getBytesTransferred
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject numberOfBytesTransferred];
}


// Returns the playback start date object
//============================================================================================================
-(NSDate *)getPlaybackStartDate
{
    return [self.mediaPlayer.currentItem.accessLog.events.lastObject playbackStartDate];
}


@end
