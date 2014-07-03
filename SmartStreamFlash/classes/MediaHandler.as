
/*************************************************************************************************************
**
**	Media Handler Class
**
**	DESC:			This class allows you to easily add media streaming functionality into any interface.
**
**	FILE:			/home/_includes/flash-as3/classes/common/MediaHandler.as
**
**	USAGE:			This class adds an additional layer of abstraction by automatically taking care
**					of processes like incremental initializations, reconnects and state tracking.  Doing this
**					allows the caller to completely control the initiated process but leaves the lower level
**					dirty work to this class, removing complexity from the calling class's order of operations.
**
**	DEPENDANCIES:	Debug.as
**
**	AUTHOR(S):		Doug Gatza
**
**	VERSION:		1.0.0 (Completed: 03/26/13)
**
**
*************************************************************************************************************/

package classes {
	
	//Flash Classes
	import flash.display.Sprite;
	
	//Custom Classes
	import classes.Debug;
	
	//OSMF Classes
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingURLResource;
    import org.osmf.containers.MediaContainer;
	import org.osmf.media.PluginInfoResource;
	
	//Plugins
	import org.denivip.osmf.plugins.HLSPluginInfo;
	import com.microsoft.azure.media.AdaptiveStreamingPluginInfo;
	
	
	
	public class MediaHandler extends Sprite {
		
		//Private Constants
		private static const DEBUG_LEVEL_LOCAL:int = 5;
		
		//Class Instances
		private var debug:Debug = new Debug();
		
		//Player Components
		private var _mediaPlayer:MediaPlayer;
		private var _mediaFactory:MediaFactory;
		private var _mediaContainer:MediaContainer;
		private var _mediaURL:String;
		
		//Player Variables
		private var _videoReconnectAttempts:Number = 0; //Indicates the number of consecutive times the client failed to connect to FMS.
		private var _videoReconnectThreshold:Number = 10; //Indicates the maximum number of consecutive times the client is allowed to attempt a reconnect.
		private var _videoAudioDisabled:Boolean = false; //Keeps track of the video audio disabled state. Disabled by default
		private var _videoAudioMuted:Boolean = false; //Keeps track of the video audio muted state.
		private var _videoAudioVolume:Number = 1.0; //Keeps track of the current volume
		private var _videoBufferLevel:Number = 0.04;
		
		//Player/Media Data
		private var mediaProperties:Object = {mediaDisplay:null, mediaURL:""};
		
		//Player Status Variables
		private var _videoStopping:Boolean = false; //Denotes that a video stream is being intentionally stopped.
		private var _videoFinishing:Boolean = false; //Denotes that a video stream is being intentionally shut down.
		
		//General Variables
		private var callbackFunction:Function; //This var stores the callback function used for communication with the calling class.
		private var delayedProcesses:Array = new Array(); //This array stores all action requests for later processing, which come in before their respective client isn't fully initialized.
		
		//Debug Variables
		private var objectDebugLevel:int = DEBUG_LEVEL_LOCAL; //Tells this class and the video player object what debug level to use.
		private var objectDebugLevelDeviation:int = 0; //Tells any connected classes how many debug levels they should deviate from this classes.
		
		
		//MediaHandler Constructor
		/******************************************************************************/
		public function MediaHandler(container:MediaContainer, callback:Function) {
			_mediaContainer = container;
			callbackFunction = callback;
		}
		
		
		/******************************************************************************/
		/********************************Public Methods********************************/
		/******************************************************************************/
		
		
		//Plays the optionally passed media URL or the one already stored
		/******************************************************************************/
		public function playMedia(mediaURL:String = null):void {
			if (mediaURL) {
				_mediaURL = mediaURL;
			}
			
			if (mediaPlayerInitialized) {
				configureMedia();
			} else {
				configurePlayer();
			}
		}
		
		
		//Pauses the active video session.
		/******************************************************************************/
		public function pauseMedia():void {
			_mediaPlayer.pause();
		}
		
		
		//Stops the active video session.
		/******************************************************************************/
		public function stopMedia():void {
			_videoStopping = true;
			stoppingMedia();
		}
		
		
		//Closes out the current media session.
		/******************************************************************************/
		public function closeMedia():void {
			_videoFinishing = true;
			
			stoppingMedia();
			closingMedia();
		}
		
		
		//Closes out the current media session.
		/******************************************************************************/
		public function destroyMedia():void {
			if (!_videoFinishing) {
				_videoFinishing = true;
			}
			
			stoppingMedia();
			closingMedia();
			destroyingMedia();
			
			callbackFunction({sender:"video_unload", data:true});
		}
		
		
		//Seeks media by time
		/******************************************************************************/
		public function seekMedia(seekTime:Number):void {
			mediaPlayer.seek(seekTime);
		}
		
		
		//Seeks media by percentage
		/******************************************************************************/
		public function seekMediaWithPercentage(progressPercentage:Number):void {
			seekMedia((mediaPlayer.duration * progressPercentage));
		}
		
		
		//This function completely resets the media handler. 
		/******************************************************************************/
		public function resetMedia():void {
			destroyMedia();
			
			_videoStopping = false;
			_videoFinishing = false;
			
			_videoReconnectAttempts = 0;
		}
		
		
		//Disables the video's audio, blocking any attempts to mute or unmute the audio.
		/******************************************************************************/
		public function disableMediaAudio(videoDisabled:Boolean, callerName:String = null):void {
			if (callerName) {
				debug.print("MEDIA HANDLER: Caller = " + callerName + ", Value = " + videoDisabled, 4);
			}
			
			//Replace the video audio disabled value.
			_videoAudioDisabled = videoDisabled;
			
			//If the video is completely initialized, then proceed with the audio disable.
			if (videoPlaying) {				
				mutingMedia(((_videoAudioDisabled) ? _videoAudioDisabled : _videoAudioMuted)); //If the audio is to be disabled, mute the stream now. Otherwise, set the audio mute to be the stored mute setting.
				
				callbackFunction({sender:"audio_disable", data:_videoAudioDisabled});
			
			//Otherwise, store this action into the queue for later.
			} else {
				actionQueue("add", {methodName:"disableMediaAudio", methodData:videoDisabled});
			}
			
			callbackFunction({sender:"audio_disable", data:videoDisabled});
		}
		
		
		//Mutes or unmutes the video's audio.
		/******************************************************************************/
		public function muteMediaAudio(videoMuted:Boolean, callerName:String = null):void {
			
			if (callerName) {
				debug.print("MEDIA HANDLER: Caller = " + callerName + ", Value = " + videoMuted, 4);
			}
			
			//Replaces the video mute value.
			_videoAudioMuted = videoMuted;
			
			//If the video is completely initialized, then proceed with the audio mute.
			if (videoPlaying) {
				
				//If the audio isn't disabled, update the mute setting now.
				if (!_videoAudioDisabled) {
					mutingMedia(_videoAudioMuted);
				}
				
				callbackFunction({sender:"audio_mute", data:_videoAudioMuted});
			
			//Otherwise, store this action into the queue for later.
			} else {
				actionQueue("add", {methodName:"muteMediaAudio", methodData:videoMuted});
			}
			
			callbackFunction({sender:"audio_mute", data:videoMuted});
		}
		
		
		public function updateVolume(newVolume:Number):void {
			_videoAudioVolume = newVolume;
			mediaPlayer.volume = _videoAudioVolume;
		}
		
		
		//This function updates the default debug level to the one specified by the caller.
		/******************************************************************************/
		public function updateDebugLevel(newDebugLevel:int, levelDeviation:int = 0):void {
			objectDebugLevel = newDebugLevel;
			objectDebugLevelDeviation = levelDeviation;
		}
		
		
		/******************************************************************************/
		/*****************************Getters and Setters******************************/
		/******************************************************************************/
		
		
		//Gets the media player
		/******************************************************************************/
		public function get mediaPlayer():MediaPlayer {
			
			//If the media player doesn't already exist, then create it now.
			if (!_mediaPlayer) {
				_mediaPlayer = getNewMediaPlayer();
			}
			
			return _mediaPlayer;
		}
		
		
		//Sets the media player to whatever you tell it to.
		/******************************************************************************/
		public function set mediaPlayer(newPlayer:MediaPlayer):void {
			_mediaPlayer = newPlayer;
		}
		
		
		//Tells the caller whether the media player has been initialized yet.
		/******************************************************************************/
		public function get mediaPlayerInitialized():Boolean {
			return (_mediaFactory && _mediaPlayer);
		}
		
		
		//Returns the media player's progress in percentage
		/******************************************************************************/
		public function get mediaProgressPercentage():Number {
			return (mediaPlayer.currentTime / mediaPlayer.duration);
		}
		
		
		//Returns the media player's current time
		/******************************************************************************/
		public function get currentTime():Number {
			return mediaPlayer.currentTime;
		}
		
		
		//Returns the media's duration
		/******************************************************************************/
		public function get duration():Number {
			return mediaPlayer.duration;
		}
		
		
		//Returns the current video audio disabled value.
		/******************************************************************************/
		public function get videoAudioDisabled():Boolean {
			return _videoAudioDisabled;
		}
		
		
		//Returns the current video audio muted value.
		/******************************************************************************/
		public function get videoAudioMuted():Boolean {
			return _videoAudioMuted;
		}
		
		
		//Returns the media volume level
		/******************************************************************************/
		public function get videoAudioVolume():Number {
			return _videoAudioVolume;
		}
		
		
		//Returns the current video audio muted value.
		/******************************************************************************/
		public function get videoPlaying():Boolean {
			return mediaPlayer.playing;
		}
		
		
		//Returns the current video audio muted value.
		/******************************************************************************/
		public function get videoPaused():Boolean {
			return mediaPlayer.paused;
		}
		
		
		//Returns the finished state of the current video.
		/******************************************************************************/
		public function get videoFinishing():Boolean {
			return _videoFinishing;
		}
		
		
		//This function gets the disconnect count for this object.
		/******************************************************************************/
		public function get videoDisconnects():Number {
			return _videoReconnectAttempts;
		}
		
		
		//This function sets the max disconnects value for this object.
		/******************************************************************************/
		public function get videoDisconnectsMax():Number {
			return _videoReconnectThreshold;
		}
		
		//This function sets the max disconnects value for this object.
		/******************************************************************************/
		public function set videoDisconnectsMax(newMaxValue:Number):void {
			_videoReconnectThreshold = newMaxValue;
		}
		
		
		//This function retrieves the video buffer level.
		/******************************************************************************/
		public function get videoBuffer():Number {
			return _videoBufferLevel;
		}
		
		
		//This function updates the video buffer level.
		/******************************************************************************/
		public function set videoBuffer(newBufferLevel:Number):void {
			_videoBufferLevel = newBufferLevel;
			
			if (mediaPlayer) {
				mediaPlayer.bufferTime = _videoBufferLevel;
			}
		}
		
		
		/******************************************************************************/
		/******************************Private Methods*********************************/
		/******************************************************************************/
		
		
		//Stops the proper media handler based on media provider.
		/******************************************************************************/
		private function stoppingMedia():void {
			if (mediaPlayer) {
				debug.print("MEDIA HANDLER: Stopping media...", 4);
				
				mediaPlayer.stop();
				callbackFunction({sender:"video_stop", data:true});
			}
		}
		
		
		//Closes the proper media handler based on media provider.
		/******************************************************************************/
		private function closingMedia():void {
			if (mediaPlayer) {					
				debug.print("MEDIA HANDLER: Closing media...", 4);
				
				mediaPlayer.media = null;
				callbackFunction({sender:"video_close", data:true});
			}
		}
		
		
		//Destroys the proper media handler based on media provider.
		/******************************************************************************/
		private function destroyingMedia():void {
			if (mediaPlayer) {					
				debug.print("MEDIA HANDLER: Destroying media player...", 4);
				
				destroyExistingMediaPlayer();
			}
		}
		
		
		//Mutes the proper media handler based on media provider.
		/******************************************************************************/
		private function mutingMedia(muteAudio:Boolean):void {
			var newVolumeLevel:Number = (muteAudio) ? 0.0 : _videoAudioVolume;
			
			if (mediaPlayer) {
				mediaPlayer.volume = newVolumeLevel;
			}
		}
		
		
		//Creates a new media player object and returns it to the caller.
		/******************************************************************************/
		private function getNewMediaPlayer():MediaPlayer {
			debug.print("MEDIA HANDLER: Creating a new MediaPlayer...", 4);
				
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			
			mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, mediaPlayerLoadChange);
			mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, mediaPlayerStateChange);
			mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, mediaPlayerErrorHandler);
			mediaPlayer.addEventListener(TimeEvent.COMPLETE, mediaPlayerFinished);
			
			return mediaPlayer;
		}
		
		
		//Destroys a given media player object.
		/******************************************************************************/
		private function destroyExistingMediaPlayer():void {
			if (mediaPlayer) {
				debug.print("MEDIA HANDLER: Destroying current MediaPlayer...", 4);
				
				mediaPlayer.removeEventListener(LoadEvent.BYTES_LOADED_CHANGE, mediaPlayerLoadChange);
				mediaPlayer.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, mediaPlayerStateChange);
				mediaPlayer.removeEventListener(MediaErrorEvent.MEDIA_ERROR, mediaPlayerErrorHandler);
				
				mediaPlayer = null;
			}
		}
		
		
		//Stores and processes queued actions.
		/******************************************************************************/
		private function actionQueue(actionMode:String, actionData:Object = null):void {
			var currentAction:Object;
			
			switch (actionMode) {
				//Add an action request to the queue
				case "add" :
					
					if (delayedProcesses[delayedProcesses.length - 1] != actionData) {
						debug.print("MEDIA HANDLER: Storing action: [ Name:" + actionData.methodName + ", Value:" + actionData.methodData + " ]", objectDebugLevel);
						actionData.processed = false;
						delayedProcesses[delayedProcesses.length] = actionData;
					}
					break;
				//Process all eligible queued requests
				case "process" :
					
					if (videoPlaying) {
						
						//Increments through each queued action request and processes if eligible
						for (var i:int = 0; i < delayedProcesses.length; i++) {
	
							debug.print("MEDIA HANDLER: Processing action: [ Name:" + delayedProcesses[i].methodName + ", Value:" + delayedProcesses[i].methodData + " ]", objectDebugLevel);
							
							currentAction = delayedProcesses[i];
							
							this[currentAction.methodName].apply(this, [currentAction.methodData]);
							currentAction = null;
							
							delayedProcesses[i].processed = true;
						}
						
						//Increments after the fact and removes all processed requests.
						for (var j:int = 0; j < delayedProcesses.length; j++) {
							if (delayedProcesses[j].processed) {
								delayedProcesses.splice(j, 1);
							}
						}
					}
					
					break;
			}
		}
		
		
		//Sets up the crucial player elements for playback
		/******************************************************************************/
		private function configurePlayer():void {
			_mediaFactory = new DefaultMediaFactory(); //Create a new DefaultMediaFactory
			
			mediaPlayer.bufferTime = _videoBufferLevel; //Initializes the media player in the process of setting the buffer.
			
			configurePlugins(_mediaFactory);
		}
		
		
		//Configures the media for playback
		/******************************************************************************/
		private function configureMedia():void {
			if (!mediaPlayer.media) {		
				var resource:URLResource = new URLResource(_mediaURL); // Create the resource to play.
				var mediaElement:MediaElement = _mediaFactory.createMediaElement(resource); // Create MediaElement using MediaFactory and add it to the container class.
				
				//if (mediaElement == null) throw new Error('Unsupported media type!');
				
				_mediaContainer.addMediaElement(mediaElement);
				
				mediaPlayer.bufferTime = _videoBufferLevel;
				mediaPlayer.media = mediaElement;
				
				updateVolume(_videoAudioVolume);
			} else {
				mediaPlayer.play();
			}
		}
		
		
		//Attempts to load all plugins
		/******************************************************************************/
		private function configurePlugins(factory:MediaFactory):void {
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
			
			factory.loadPlugin(new PluginInfoResource(new HLSPluginInfo()));
			factory.loadPlugin(new PluginInfoResource(new AdaptiveStreamingPluginInfo()));
		}		
		
		
		/******************************************************************************/
		/*********************************Listeners************************************/
		/******************************************************************************/
		
		
		//Fires when a plugin was successfully loaded
		/******************************************************************************/
		private function onPluginLoaded(event:MediaFactoryEvent):void {
			debug.print("MEDIA HANDLER: Plugin Loaded Successfully, Event = " + event, 4);
			
			playMedia();
		}
		
		
		//Fires when a plugin failed to load
		/******************************************************************************/
		private function onPluginLoadFailed( event:MediaFactoryEvent ):void {
			debug.print("MEDIA HANDLER: Plugin Failed To Load, Event = " + event, 4)
			callbackFunction({sender:"video_error", data:{errorCode:"Plugin Load Error", errorMessage:"SmartStream failed to load a crucial plugin resulting in media playback failure. Event Data = " + event, errorLevel:0, errorSource:"MediaHandlerClass-NetStatusHandler"}});
		}
		
		
		//This function handles all of the mediaPlayer state change events.
		/******************************************************************************/
		private function mediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			var eventData:Object;
			
			debug.print("MEDIA HANDLER: Media Player Current State = " + event.state, DEBUG_LEVEL_LOCAL);
			
			if (event.state == "ready") {
				callbackFunction({sender:"video_ready", data:true});
			} else if (event.state == "playing" || videoPlaying) {
				callbackFunction({sender:"video_play", data:true});
			} else if (videoPaused) {
				callbackFunction({sender:"video_paused", data:true});
			} else if (event.state == "buffering") {
				callbackFunction({sender:"video_buffer", data:true});
			} else if (event.state == "playbackError") {
				callbackFunction({sender:"video_error", data:{errorCode:event.state, errorMessage:"The chosen media was unable to be played.", errorLevel:0, errorSource:"MediaHandlerClass-NetStatusHandler"}});
			}
		}
		
		
		//This function handles all of the mediaPlayer load change events.
		/******************************************************************************/
		private function mediaPlayerLoadChange(event:LoadEvent):void {
			debug.print("MEDIA HANDLER: Media Player Bytes Loaded = " + event.bytes, 5);
			callbackFunction({sender:"video_loading", data:"empty"});
		}
		
		
		//This function fires when the media is finished playing
		/******************************************************************************/
		private function mediaPlayerFinished(event:TimeEvent):void {
			callbackFunction({sender:"video_finished", data:true});
		}
		
		
		//This function handles media errors.
		/******************************************************************************/
		private function mediaPlayerErrorHandler(event:MediaErrorEvent):void {
			debug.print("MEDIA HANDLER: Media Player Error [" + event.error.errorID + "] = " + event.error.message, objectDebugLevel);
			callbackFunction({sender:"video_error", data:{errorCode:event.error.errorID, errorMessage:event.error.message, errorLevel:0, errorSource:"MediaHandlerClass-NetStatusHandler"}});
		}
	}
}