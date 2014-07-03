package classes  {
	
	//Flash Classes
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import classes.Debug;
	import classes.MediaHandler;
	import classes.MediaDisplayHandler;
	
	
	[SWF(width="1024", height="768", backgroundColor='#000000', frameRate="30")]
	public class SmartStreamMain extends Sprite {

		private const APPVERSION = "1.0.0";
		private const DEBUG_LEVEL = 4;
		
		private var mediaURL:String = "http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8";
		
		private var mediaHandler:MediaHandler;
		private var mediaDisplay:MediaDisplayHandler;
		private var debug:Debug = new Debug();
		
		private var progressScrolling:Boolean = false;
		private var progressRecovering:Boolean = false;
		private var volumeScrolling:Boolean = false;
		
		private var playheadUpdateTimer:Timer;
		
		//HLS Test Streams
		// http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8
		// http://smooth-las-akam.istreamplanet.com/vod/iphone/getgreek_clip.m3u8
		
		//IIS Smooth Streaming Test Streams
		// http://playready.directtaps.net/smoothstreaming/SSWSS720H264/SuperSpeedway_720.ism/Manifest
		
		//MP4 Test Streams
		// http://stream.flowplayer.org/big_buck_bunny_with_captions.mp4
		
		
		//Constructor
		/******************************************************************************/
		public function SmartStreamMain() {
			stage.quality = StageQuality.HIGH;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			debug.init(stage.stageWidth, stage.stageHeight, stage, false, true); //Initialize the debug tool
			debug.echoLevel(DEBUG_LEVEL); //Sets the current debug echo level.
			debug.print("SMARTSTREAM MAIN: Initializing SmartStream Client, v" + APPVERSION + "\n", 1);
			
			configurePlayer();
		}
		
		
		//Configures the player object and the player display/controls
		/******************************************************************************/
		private function configurePlayer():void {
			mediaDisplay = new MediaDisplayHandler(stage);
			mediaHandler = new MediaHandler(mediaDisplay.mediaContainer, playerHandlerCallback);
			
			mediaDisplay.linkFieldMC.urlText.text = mediaURL;
			
			connectControls();
		}
		
		
		//Connects all of the controls to event handlers
		/******************************************************************************/
		private function connectControls():void {
			mediaDisplay.buttonPlayMC.buttonObject.addEventListener(MouseEvent.CLICK, playButtonHandler);
			mediaDisplay.buttonPlayLargeMC.buttonObject.addEventListener(MouseEvent.CLICK, playButtonHandler);
			mediaDisplay.buttonPauseMC.buttonObject.addEventListener(MouseEvent.CLICK, pauseButtonHandler);
			mediaDisplay.buttonStopMC.buttonObject.addEventListener(MouseEvent.CLICK, stopButtonHandler);
			mediaDisplay.buttonMuteMC.buttonObject.addEventListener(MouseEvent.CLICK, muteButtonHandler);
			mediaDisplay.buttonUnmuteMC.buttonObject.addEventListener(MouseEvent.CLICK, unmuteButtonHandler);
			mediaDisplay.buttonCCMC.buttonObject.addEventListener(MouseEvent.CLICK, ccButtonHandler);
			mediaDisplay.mediaContainer.addEventListener(MouseEvent.CLICK, mediaContainerHandler);
			mediaDisplay.linkFieldMC.buttonObject.addEventListener(MouseEvent.CLICK, videoLinkHandler);
			mediaDisplay.errorWindowMC.buttonObject.addEventListener(MouseEvent.CLICK, errorClickHandler);
			 
			mediaDisplay.barProgressMC.areaDrag.addEventListener(MouseEvent.MOUSE_DOWN, progressDownHandler);
			mediaDisplay.barVolumeMC.areaDrag.addEventListener(MouseEvent.MOUSE_DOWN, volumeDownHandler);
			
			stage.addEventListener(Event.ENTER_FRAME, generalEnterFrameHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, generalMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, generalMouseDownHandler);
			
			playheadUpdateTimer = new Timer(200, 0);
			playheadUpdateTimer.addEventListener("timer", playheadProgressHandler);
			playheadUpdateTimer.start();
		}
		
		
		//Unloads old media and loads new media
		/******************************************************************************/
		private function unloadMediaAndLoadNew():void {
			if (mediaHandler.mediaPlayerInitialized) {			
				mediaHandler.closeMedia();
			}
			
			mediaDisplay.showPlayLarge(false);
			mediaDisplay.showPlayButton(false);
			mediaDisplay.showLoadingSymbol(true);
			mediaHandler.playMedia(mediaURL);
		}
		
		
		//Evecutes a play event
		/******************************************************************************/
		private function playButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: Play Pressed", 4);
			
			mediaDisplay.showLoadingSymbol(true);
			mediaDisplay.showPlayLarge(false);
			mediaHandler.playMedia(mediaURL);
		}
		
		
		//Executes a pause event
		/******************************************************************************/
		private function pauseButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: Pause Pressed", 4);
			
			mediaHandler.pauseMedia();
		}
		
		
		//Executes a stop event
		/******************************************************************************/
		private function stopButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: Stop Pressed", 4);
			mediaHandler.stopMedia();
		}
		
		
		//Executes a mute event
		/******************************************************************************/
		private function muteButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: Mute Pressed", 4);
			if (!mediaDisplay.barVolumeMC.visible) {
				mediaDisplay.barVolumeMC.visible = true;
			} else {
				mediaHandler.muteMediaAudio(true);
			}
		}
		
		
		//Executes an unmute event
		/******************************************************************************/
		private function unmuteButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: Unmute Pressed", 4);
			mediaHandler.muteMediaAudio(false);
		}
		
		
		//Handles the CC visibility
		/******************************************************************************/
		private function ccButtonHandler(event:MouseEvent):void {
			debug.print("SMARTSTREAM MAIN: CC Pressed", 4);
			
			//** TODO - Need to add this functionality
		}
		
		
		//Handles click events on the media container for the sake of controlling player controls visibility
		/******************************************************************************/
		private function mediaContainerHandler(event:MouseEvent):void {
			updateGeneralControlsVisibility();
		}
		
		
		//Mouse down event handler to capture the start of drag actions over the progress bar
		/******************************************************************************/
		private function progressDownHandler(event:MouseEvent):void {
			progressScrolling = true;
		}
		
		
		//Mouse down event handler to capture the start of drag actions over the volume bar
		/******************************************************************************/
		private function volumeDownHandler(event:MouseEvent):void {
			volumeScrolling = true;
		}
		
		
		//Captures a new video link from the link container when called and updates the mediaURL
		/******************************************************************************/
		private function videoLinkHandler(event:MouseEvent):void {
			mediaURL = mediaDisplay.linkFieldMC.urlText.text;
			
			debug.print("SMARTSTREAM MAIN: New Media URL = " + mediaURL, 4);
			
			unloadMediaAndLoadNew();
		}
		
		
		//General enter frame handler used to update all dragging actions
		/******************************************************************************/
		private function generalEnterFrameHandler(event:Event):void {
			if (progressScrolling) {
				var progressDragMin:Number = mediaDisplay.playerControlsMC.x + mediaDisplay.barProgressMC.x + mediaDisplay.barProgressMC.areaDrag.x;
				var progressDragMax:Number = progressDragMin + mediaDisplay.barProgressMC.areaDrag.width;
				var progressPercentage:Number = (mouseX - progressDragMin) / mediaDisplay.barProgressMC.areaDrag.width; 
				
				mediaDisplay.updateProgressBarWithPercentage(progressPercentage);
			}
			
			
			if (volumeScrolling) {
				var volumeDragMin:Number = mediaDisplay.playerControlsMC.y + mediaDisplay.barVolumeMC.y + mediaDisplay.barVolumeMC.areaDrag.y + mediaDisplay.barVolumeMC.areaDrag.height;
				var volumeDragMax:Number = volumeDragMin - mediaDisplay.barVolumeMC.areaDrag.height;
				var volumePercentage:Number = (volumeDragMin - mouseY) / mediaDisplay.barVolumeMC.areaDrag.height; 
				
				if (volumePercentage < 0.0) {
					volumePercentage = 0.0;
				} else if (volumePercentage > 1.0) {
					volumePercentage = 1.0;
				}
				
				mediaDisplay.updateVolumeBarWithPercentage(volumePercentage);
				mediaHandler.updateVolume(volumePercentage);
				
				if (volumePercentage <= 0.0) {
					if (!mediaHandler.videoAudioMuted) {
						mediaHandler.muteMediaAudio(true);
					}
				} else {
					if (mediaHandler.videoAudioMuted) {
						mediaHandler.muteMediaAudio(false);
					}
				}
			}
		}
		
		
		//General mouse down handler used to look for clicks of the background
		/******************************************************************************/
		private function generalMouseDownHandler(event:MouseEvent):void {
			//If the background is clicked, then update the controls' visibility
			if (!event.target.name) {
				updateGeneralControlsVisibility();
			}
		}
		
		
		//Updates the player controls visibility based aon a couple different variables
		/******************************************************************************/
		private function updateGeneralControlsVisibility():void {
			if (mediaDisplay.isVolumeVisible) {
				mediaDisplay.showVolumeBar(false);
			} else {
				if (mediaDisplay.isControlsVisible) {				
					mediaDisplay.showPlayerControls(false);
					mediaDisplay.showLinkBar(false);
				} else {
					mediaDisplay.showPlayerControls(true);
					mediaDisplay.showLinkBar(true);
				}
				
			}
		}
		
		
		//General mouse up handler though used specifically to end all dragging actions
		/******************************************************************************/
		private function generalMouseUpHandler(event:MouseEvent):void {
			
			if (progressScrolling) {
				progressScrolling = false;
				progressRecovering = true;
				
				var progressDragMin:Number = mediaDisplay.playerControlsMC.x + mediaDisplay.barProgressMC.x + mediaDisplay.barProgressMC.areaDrag.x;
				var progressDragMax:Number = progressDragMin + mediaDisplay.barProgressMC.areaDrag.width;
				var progressPercentage:Number = (mouseX - progressDragMin) / mediaDisplay.barProgressMC.areaDrag.width; 
				
				if (progressPercentage < 0.0) {
					progressPercentage = 0.0;
				} else if (progressPercentage > 1.0) {
					progressPercentage = 1.0;
				}
				
				mediaDisplay.updateProgressBarWithPercentage(progressPercentage);
				mediaHandler.seekMediaWithPercentage(progressPercentage);
			}
			
			if (volumeScrolling) {
				volumeScrolling = false;
			}
		}
		
		
		//Updates the progress of the playhead as the media plays
		/******************************************************************************/
		private function playheadProgressHandler(...timerData):void {
			if (mediaHandler.videoPlaying && !progressScrolling && !progressRecovering) {
				mediaDisplay.updateProgressBarWithPercentage(mediaHandler.mediaProgressPercentage);
				
				mediaDisplay.updatePlayTimeText(mediaHandler.currentTime);
				mediaDisplay.updateDurationText(mediaHandler.duration);
			}
		}
		
		
		//This function resets both the current time and bar width in one function
		/******************************************************************************/
		private function resetProgressBar():void {
			mediaDisplay.updateProgressBarWithPercentage(0.0);
			mediaDisplay.updatePlayTimeText(0.0);
		}
		
		
		//This function handles all callbacks from the video class.
		/******************************************************************************/
		private function playerHandlerCallback(callbackData:Object):void {
			//debug.print("SMARTSTREAM MAIN: " + callbackData.sender, 4);
			
			//Performs different actions based on the callback sender.
			switch (callbackData.sender) {
				case "video_ready" :
					//debug.print("VIDEO CALLBACK: Video Connect Status = " + callbackData.data, 4);
					//mediaDisplay.showLoadingSymbol(false);
					break;
				case "video_play" :
					mediaDisplay.showLoadingSymbol(false);
					mediaDisplay.showPlayButton(false);
					
					if (progressRecovering) {
						progressRecovering = false;
					}
					
					break;
				case "video_paused" :
					mediaDisplay.showPlayButton(true);
					break;
				case "video_stop" :
				case "video_finished" :
				case "video_close" :
					mediaDisplay.showPlayLarge(true);
					mediaDisplay.showPlayButton(true);
					resetProgressBar();
					break;
				case "video_unload" :
					mediaDisplay.showPlayButton(true);
					mediaDisplay.clearPlayTimeAndDurationText();
					break;
				case "video_buffering" :
					mediaDisplay.showLoadingSymbol(true);
					break;
				case "video_loading" :
					//** Add if neccessary
					break;
				case "audio_disable" :
					if (callbackData.data) {
						mediaDisplay.showMuteButton(false);
						mediaDisplay.updateVolumeBarWithPercentage(0.0);
					} else if (!mediaHandler.videoAudioMuted) {
						mediaDisplay.showMuteButton(true);
						mediaDisplay.updateVolumeBarWithPercentage(mediaHandler.videoAudioVolume);
					}
					break;
				case "audio_mute" :					
					if (callbackData.data) {
						mediaDisplay.showMuteButton(false);
						mediaDisplay.updateVolumeBarWithPercentage(0.0);
					} else if (!mediaHandler.videoAudioDisabled) {
						mediaDisplay.showMuteButton(true);
						mediaDisplay.updateVolumeBarWithPercentage(mediaHandler.videoAudioVolume);
					}
					break;
				case "video_error" :
					debug.print("SMARTSTREAM MAIN: Error " + callbackData.data.errorCode + ": " + callbackData.data.errorMessage, 2);
					
					mediaDisplay.showErrorWindow(true, "Error " + callbackData.data.errorCode, callbackData.data.errorMessage);
					break;
			}
		}
		
		
		//Handles error button click events
		/******************************************************************************/
		private function errorClickHandler(event:MouseEvent):void {
			mediaDisplay.showErrorWindow(false);
			
			//** Add Handling as needed.
		}
	}
}
