/*************************************************************************************************************
**
**	Media Display Handler Class
**
**	DESC:			Creates and maintains a media container and a set of customer media player controls.
**
**	FILE:			/classes/MediaDisplayHandler.as
**
**	USAGE:			This class can be used in any flash video player project that uses Adobe's OSMF.
**
**	DEPENDANCIES:		Debug.as
**
**	AUTHOR(S):		Doug Gatza
**
**	VERSION:		1.0.0
**
**
*************************************************************************************************************/

﻿package classes  {
	
	import org.osmf.containers.MediaContainer;
	
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import classes.Debug;
	
	
	public class MediaDisplayHandler extends MovieClip {
		
		private var debug:Debug = new Debug();
		private var _mediaContainer:MediaContainer;
		private var _stageObject:Stage;
		      
		public var buttonPlayMC:MovieClip = new ButtonPlay();
		public var buttonPlayLargeMC:MovieClip = new ButtonPlayLarge();
		public var buttonPauseMC:MovieClip = new ButtonPause();
		public var buttonStopMC:MovieClip = new ButtonStop();
		public var buttonMuteMC:MovieClip = new ButtonMute();
		public var buttonUnmuteMC:MovieClip = new ButtonUnmute();
		public var buttonCCMC:MovieClip = new ButtonCC();
		public var barProgressMC:MovieClip = new BarProgressComponent();
		public var barVolumeMC:MovieClip = new BarVolumeComponent();
		public var loadingSpinnerMC:MovieClip = new LoadingGraphic();
		public var linkFieldMC:MovieClip = new LinkField();
		public var errorWindowMC:MovieClip = new ErrorWindow();
		public var playerControlsMC:MovieClip = new MovieClip();
		
		private var controlsBuffer:Number = 10.0;
		
		
		//Constructor
		/******************************************************************************/
		public function MediaDisplayHandler(stageObject:Stage) {
			_stageObject = stageObject;
			
			_mediaContainer = new MediaContainer();
			_mediaContainer.name = "mediaContainer";
			
			configureControls();
		}
		
		
		//Configures the controls for use and adds them to stage
		/******************************************************************************/
		private function configureControls():void {
			
			//Add all components to their respective containers
			_stageObject.addChild(_mediaContainer);
			_stageObject.addChild(playerControlsMC);
			_stageObject.addChild(buttonPlayLargeMC);
			_stageObject.addChild(loadingSpinnerMC);
			_stageObject.addChild(linkFieldMC);
			
			playerControlsMC.addChild(buttonPlayMC);
			playerControlsMC.addChild(buttonPauseMC);
			playerControlsMC.addChild(buttonStopMC);
			playerControlsMC.addChild(buttonMuteMC);
			playerControlsMC.addChild(buttonUnmuteMC);
			//playerControlsMC.addChild(buttonCCMC);
			playerControlsMC.addChild(barProgressMC);
			playerControlsMC.addChild(barVolumeMC);
			
			_stageObject.addChild(errorWindowMC);
			
			debug.stayOnTop();
			
			
			//Set the initial placement, size and visibility of all controls
			buttonPlayMC.x = 0.0;
			buttonPlayMC.y = -buttonPlayMC.height;
			
			buttonPauseMC.x = buttonPlayMC.x;
			buttonPauseMC.y = buttonPlayMC.y;
			buttonPauseMC.visible = false;
			
			buttonStopMC.x = buttonPlayMC.x + buttonPlayMC.width + controlsBuffer;
			buttonStopMC.y = buttonPlayMC.y + (buttonPlayMC.height - buttonStopMC.height);
			
			barProgressMC.x = buttonStopMC.x + buttonStopMC.width + controlsBuffer;
			barProgressMC.y = buttonStopMC.y;
			updateProgressBarWithPercentage(0.0);
			
			buttonMuteMC.x = barProgressMC.x + barProgressMC.width + controlsBuffer;
			buttonMuteMC.y = buttonStopMC.y;
			
			buttonUnmuteMC.x = buttonMuteMC.x;
			buttonUnmuteMC.y = buttonMuteMC.y;
			buttonUnmuteMC.visible = false;
			
			buttonCCMC.x = buttonMuteMC.x + buttonMuteMC.width + controlsBuffer;
			buttonCCMC.y = buttonStopMC.y;
			
			barVolumeMC.x = buttonMuteMC.x;
			barVolumeMC.y = buttonMuteMC.y - barVolumeMC.height - controlsBuffer;
			barVolumeMC.visible = false;
			
			loadingSpinnerMC.visible = false;
			errorWindowMC.visible = false;
			
			
			//Set up general resize listener
			_stageObject.addEventListener(Event.RESIZE, generalResizeHandler);
			_stageObject.addEventListener(Event.ENTER_FRAME, generalEnterFrameHandler);
			
			
			updateControls();
		}
		
		
		//Updates all controls and elements to fit the screen when called
		/******************************************************************************/
		public function updateControls():void {
			_mediaContainer.x = 0;
			_mediaContainer.y = 0;
			_mediaContainer.width = _stageObject.stageWidth;
			_mediaContainer.height = _stageObject.stageHeight;
			
			playerControlsMC.x = (_stageObject.stageWidth - playerControlsMC.width) / 2;
			playerControlsMC.y = _stageObject.stageHeight - controlsBuffer;
			
			buttonPlayLargeMC.x = (_stageObject.stageWidth - buttonPlayLargeMC.width) / 2;
			buttonPlayLargeMC.y = (_stageObject.stageHeight - buttonPlayLargeMC.height) / 2;
			
			loadingSpinnerMC.x = _stageObject.stageWidth / 2;
			loadingSpinnerMC.y = _stageObject.stageHeight / 2;
			
			linkFieldMC.x = (_stageObject.stageWidth - linkFieldMC.width) / 2;
			linkFieldMC.y = controlsBuffer;
			
			errorWindowMC.x = (_stageObject.stageWidth - errorWindowMC.width) / 2;
			errorWindowMC.y = (_stageObject.stageHeight - errorWindowMC.height) / 2;
		}
		
		
		//Updates the progress bar by percentage
		/******************************************************************************/
		public function updateProgressBarWithPercentage(progressPercentage:Number):void {
			if (progressPercentage >= 0.0 && progressPercentage <= 1.0) {
				barProgressMC.barProgress.width = barProgressMC.areaDrag.width * progressPercentage;
				barProgressMC.barDragger.x = barProgressMC.barProgress.x + barProgressMC.barProgress.width - (barProgressMC.barDragger.width / 2);
			}
		}
		
		
		//Updates the volume bar by progress
		/******************************************************************************/
		public function updateVolumeBarWithPercentage(volumePercentage:Number):void {
			if (volumePercentage >= 0.0 && volumePercentage <= 1.0) {
				barVolumeMC.barProgress.height = barVolumeMC.areaDrag.height * volumePercentage;
				barVolumeMC.barProgress.y = (barVolumeMC.areaDrag.height - barVolumeMC.barProgress.height) + barVolumeMC.areaDrag.y;
				barVolumeMC.barDragger.y = barVolumeMC.barProgress.y - (barVolumeMC.barDragger.height / 2);
			}
		}
		
		
		//Shows or hides the play/pause buttons
		/******************************************************************************/
		public function showPlayButton(showPlay:Boolean):void {
			buttonPlayMC.visible = showPlay;
			buttonPauseMC.visible = !showPlay;
		}
		
		
		//Shows/hides the mute/unmute buttons
		/******************************************************************************/
		public function showMuteButton(showMute:Boolean):void {
			buttonMuteMC.visible = showMute;
			buttonUnmuteMC.visible = !showMute;
		}
		
		
		//Shows/hides the loading symbol
		/******************************************************************************/
		public function showLoadingSymbol(showLoading:Boolean):void {
			loadingSpinnerMC.visible = showLoading;
		}
		
		
		//Shows/hides the volume bar
		/******************************************************************************/
		public function showVolumeBar(showVolume:Boolean):void {
			barVolumeMC.visible = showVolume;
		}
		
		
		//Shows/hides the player controls
		/******************************************************************************/
		public function showPlayerControls(showControls:Boolean):void {
			playerControlsMC.visible = showControls;
		}
		
		
		//Shows/hides the player controls
		/******************************************************************************/
		public function showPlayLarge(showButton:Boolean):void {
			buttonPlayLargeMC.visible = showButton;
		}
		
		
		//Shows/hides the link bar
		/******************************************************************************/
		public function showLinkBar(showBar:Boolean):void {
			linkFieldMC.visible = showBar;
		}
		
		
		//Shows/hides the error window
		/******************************************************************************/
		public function showErrorWindow(showError:Boolean, errorTitle:String = null, errorMessage:String = null):void {
			errorWindowMC.visible = showError;
			
			if (showError) {
				errorWindowMC.errorTitle.text = errorTitle;
				errorWindowMC.errorMessage.text = errorMessage;
			}
		}
		
		
		//Determins if the user's mouse is within the boundaries of a passed display object
		/******************************************************************************/
		public function mouseWithinBoundariesOfDisplayObject(displayObject:DisplayObject):Boolean {
			if (mouseX > displayObject.x && mouseX < (displayObject.x + displayObject.width) && mouseY > displayObject.y && mouseY < (displayObject.y + displayObject.height)) {
				return true;
			}
			
			return false;
		}
		
		
		//Updates the play time indicator
		/******************************************************************************/
		public function updatePlayTimeText(playTimeSeconds:Number):void {
			barProgressMC.playTimeText.text = returnFormattedTimeCode(playTimeSeconds);
		}
		
		
		//Clears the play time text field
		/******************************************************************************/
		public function clearPlayTimeText():void {
			barProgressMC.playTimeText.text = "";
		}
		
		
		//Updates the duration indicator
		/******************************************************************************/
		public function updateDurationText(durationSeconds:Number):void {
			barProgressMC.durationText.text = returnFormattedTimeCode(durationSeconds);
		}
		
		
		//Clears the play time text field
		/******************************************************************************/
		public function clearDurationText():void {
			barProgressMC.durationText.text = "";
		}
		
		
		//Clears the play time text field
		/******************************************************************************/
		public function clearPlayTimeAndDurationText():void {
			clearPlayTimeText();
			clearDurationText();
		}
		
		
		//Returns a formatted time code from the seconds value passed
		/******************************************************************************/
		public function returnFormattedTimeCode(timeInSeconds:Number):String {
			var minutes:Number = Math.floor(timeInSeconds / 60);
			var seconds:Number = Math.floor(timeInSeconds - (minutes * 60));
			
			return minutes + ":" + ((seconds < 10) ? ("0" + seconds): seconds );
		}
		
		
		//General enter frame handler which is being used for animation and transitions in the future
		/******************************************************************************/
		private function generalEnterFrameHandler(event:Event):void {
			if (loadingSpinnerMC.visible) {
				loadingSpinnerMC.rotation += 4;
			}
		}
		
		
		//Returns the media container object
		/******************************************************************************/
		public function get mediaContainer():MediaContainer {
			return _mediaContainer;
		}
		
		
		//Returns the display state of the volume bar
		/******************************************************************************/
		public function get isVolumeVisible():Boolean {
			return barVolumeMC.visible;
		}
		
		
		//Returns the display state of the player controls
		/******************************************************************************/
		public function get isControlsVisible():Boolean {
			return playerControlsMC.visible;
		}
		
		
		//Returns the display state of the play large button
		/******************************************************************************/
		public function get isPlayLargeVisible():Boolean {
			return buttonPlayLargeMC.visible;
		}

		
		//General resize handler used to update the player controls and elements on the screen
		/******************************************************************************/
		private function generalResizeHandler(event:Event):void {
			updateControls();
		}
	}
}
