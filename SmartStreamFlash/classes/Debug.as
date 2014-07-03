
/*************************************************************************************************************
**
**	Debug Class
**
**	DESC:			This class is simply used for runtime feedback of whatever swf that is being developed or
**					troubleshooted.
**
**	FILE:			/home/_includes/flash-as3/classes/videochat/Debug.as
**
**	USAGE:			Used when background processes need to be observed directly for development and 
**					troubleshooting purposes.  Developers are able to specify which level of messages to view.
**
**	DEPENDANCIES:	SavedUData
**
**	AUTHOR:			Doug Gatza
**
**	VERSION:		1.0.9
**
**
*************************************************************************************************************/

package classes {
	
	//Flash Classes
	import fl.controls.UIScrollBar;
	import fl.controls.Button;
	import fl.controls.ScrollBarDirection;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Debug extends MovieClip {
		
		//Debug Color Sets
		public static const WHITE:Object = {r:255, g:255, b:255};
		public static const BLACK:Object = {r:0, g:0, b:0};
		public static const RED:Object = {r:255, g:0, b:0};
		public static const MAROON:Object = {r:128, g:0, b:0};
		public static const GREEN:Object = {r:0, g:255, b:0};
		public static const BLUE:Object = {r:0, g:0, b:255};
		public static const YELLOW:Object = {r:255, g:255, b:0};
		public static const ORANGE:Object = {r:255, g:102, b:0};
		public static const MAGENTA:Object = {r:255, g:0, b:255};
		public static const CYAN:Object = {r:0, g:255, b:255};
		public static const PURPLE:Object = {r:128, g:0, b:128};
		
		//Regional Variables
		private static var STAGE:Stage; //Makes the global stage available to debug.
		
		private static var debugText:TextField = new TextField(); //The text field used to print debug messgaes
		private static var debugBackground:MovieClip = new MovieClip(); //The semi-opaque background
		private static var debugButton:Button = new Button(); //The hide/show button
		
		private static var debugWidth:Number; //The width of the debug window
		private static var debugHeight:Number; //The height of the debug window
		private static var debugLevel:int = 0; //The default debug level
		private static var debugHidden:Boolean = false; //Tells the window to hide or show
		private static var debugVisible:Boolean = false; //Tells the window to be visible or invisible
		private static var debugTimeStamps:Boolean = false; //Tells the window to show timestamps
		private static var previousKey:String; //Stores the previous key pressed when determining key access to debug
		private static var incrementKey:Number = 0; //Stores the number of times the 'D' key is pressed
		
		private static var vScrollBar:UIScrollBar = new UIScrollBar(); //The vertical scroll bar
		private static var hScrollBar:UIScrollBar = new UIScrollBar(); //The horizontal scroll bar
		
		private static var debugDisplayQueue:Array = new Array();
		private static var changingDebugDisplay:Boolean = false;
		private static var runOnce:Boolean = false; //Used to stop initilization code from being run more than once.
		
		
		/******************************************************************************/
		/**************************Initialization Functions****************************/
		/******************************************************************************/
		
				
		//Debug Constructor - Can alternatively initialize class by sending below values
		/******************************************************************************/
		function Debug(...debugProperties) {
			// Ex. ( [0]Stage, [1]Debug Visible, [2]Show Timestamps, [3]Debug Level )
			
			if (!runOnce) {				
				//If all four debug properties are sent, then proceed.
				if (debugProperties.length > 0) {
					init(debugProperties[0].stageWidth, debugProperties[0].stageHeight, debugProperties[0], debugProperties[1], debugProperties[2]);
					echoLevel(debugProperties[3]);
				}
				
				runOnce = true;
			}
		}
		
		
		//This function is sets all of the init functions into play. User passes the main display object's stage to this function.
		//Called With - debug.init(Number:StageWidth, Number:StageHeight, Stage:MainStageObject, Boolean:DebugVisible); 
		/******************************************************************************/
		public function init(w:Number, h:Number, mainStage:Stage, startDebugVisible:Boolean, showTimeStamps:Boolean = false){
			STAGE = mainStage; //Associates the main displayObject's stage with the debug stage object.	
			STAGE.addEventListener(Event.RESIZE, userInterfaceResizing); //Establish stage resize listener
			
			debugVisible = startDebugVisible;
			debugTimeStamps = showTimeStamps;
			
			print("DEBUG: Entering Debug Mode", 1);
			print("DEBUG: Debug Level: " + debugLevel, 1);
			
			initKeyListeners();			
			initWindow(w, h);
			initText();
			initButton();
						
			if (debugVisible) {
				hideDebug("visible");
			} else {
				hideDebug("invisible");
			}
		}
		
		
		//This function initializes the start debug overide keys.
		/******************************************************************************/
		private function initKeyListeners():void {
			STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		
		//This function initializes the debug textField.
		/******************************************************************************/
		private function initText(){
			debugText.border = false;
			debugText.background = false;
			debugText.selectable = true;
			debugText.backgroundColor = 0xFFFFFF;
			debugText.multiline = true;
			debugText.wordWrap = false;
			debugText.width = debugWidth - 15;
			debugText.height = debugHeight / 2 - 15;
			initScrollBars(debugText);
			STAGE.addChild(debugText);	// Add debug text element to the screen
		}
		
		
		//This function initializes the horizontal and vertical scrollbars for the debug window.
		/******************************************************************************/
		private function initScrollBars(target:*){
			vScrollBar.direction = ScrollBarDirection.VERTICAL;
			vScrollBar.move(target.x + target.width, target.y);
			vScrollBar.height = debugBackground.height - 22;
			vScrollBar.scrollTarget = target;
			STAGE.addChild(vScrollBar);
			
			hScrollBar.direction = ScrollBarDirection.HORIZONTAL;
			hScrollBar.move(target.x, target.y + target.height);
			hScrollBar.width = debugBackground.width - 100;
			hScrollBar.scrollTarget = target;
			STAGE.addChild(hScrollBar);
		}
		
		
		//This function initializes the slightly opaque debug background.
		/******************************************************************************/
		private function initWindow(w:int, h:int){
			debugWidth = w;
			debugHeight = h;
			
			debugBackground.graphics.beginFill(0xFFFFFF, 0.6);
			debugBackground.graphics.drawRect(0, 0, w, (h / 2));
			debugBackground.graphics.endFill();
						
			STAGE.addChild(debugBackground);
		}
		
		
		//This function initializes the debug hide/show toggle button.
		/******************************************************************************/
		private function initButton():void {
			debugButton.width = 100;
			debugButton.move(debugBackground.width - debugButton.width, debugBackground.height - debugButton.height);
			debugButton.label = "Hide Debug";
			debugButton.name = "debugButton";
			debugButton.addEventListener(MouseEvent.CLICK, debugButtonHandler);
			debugButton.focusRect = false;
			debugButton.tabEnabled = false;
			
			STAGE.addChild(debugButton);
		}
		
		
		//This function updates the size of the debug window when the interface is resizing
		/******************************************************************************/
		private function userInterfaceResizing(event:Event):void {
			resizeDebug(STAGE.stageWidth, STAGE.stageHeight);
		}
				
				
		/******************************************************************************/
		/****************************Operational Functions*****************************/
		/******************************************************************************/
		
		
		//This function passes all instance print requests to the static method below.
		/******************************************************************************/
		public function print(messageText:String, messageLevel:int, messageColorBase:Object = null, invertTimeStampSetting:Boolean = false):void{
			printStatic(messageText, messageLevel, messageColorBase, invertTimeStampSetting, true); //Forwards the debug message to the printStatic.
		}
		
		
		public function printPlain(messageText:String, messageLevel:int, invertTimeStampSetting:Boolean = false):void{
			printStatic(messageText, messageLevel, null, invertTimeStampSetting, false); //Forwards the debug message to the printStatic.
		}
		
		
		//This function is the primary function used in this class and it simply prints the latest message to the window.
		/******************************************************************************/
		public static function printStatic(messageText:String, messageLevel:int, messageColorBase:Object = null, invertTimeStampSetting:Boolean = false, enhancedStyles:Boolean = true):void{
			var colorValue:Object = (messageColorBase) ? messageColorBase : BLACK;
			var timeStampModifier:String; //Inserted everytime, but is only filled with data if permitted
			var levelModifier:String;
			var adjustedTimeStampSetting:Boolean = (invertTimeStampSetting) ? !debugTimeStamps : debugTimeStamps; //If timestamps are allowed, give the timestamp variable form now.
			
			
			// Note: If the message level is passed as 0, then debug inserts a blank line.
			
			
			//If the message is within the minimum debug level, execute the following code.
			if (messageLevel <= debugLevel){
				
				messageText = messageText/*((messageLevel > 0) ? messageText : "")*/ + "\n"; //Adds a line break after the messageText.
				timeStampModifier = (adjustedTimeStampSetting && messageLevel > 0) ? timeStamp() : "";
				levelModifier = (messageLevel > 0) ? "[" + messageLevel + "] " : "";
				
				if (!enhancedStyles) {
					debugText.appendText(timeStampModifier + levelModifier + String(messageText));
				} else {
					debugText.htmlText += "<font face=\"" + "Tahoma" + "\" size=\"" + 11 + "\" color=\"#" + getColorWithLevel(messageLevel, colorValue) + "\" >" + timeStampModifier + levelModifier + String(messageText) + "</font>";
				}
				
				trace(timeStampModifier + levelModifier + messageText); //Also traces the message for the sake of local testing.
				
				debugText.scrollV = debugText.length; //Updates the vertical scroll position of the debug window.
				
				//Updates both scrollbars
				hScrollBar.update();
    			vScrollBar.update();
				
				//Updates the scrollbar visibility only if the window is allowed to show.
				if (!debugHidden && debugVisible) {
					vScrollBar.visible = (debugText.maxScrollV > 1);
					hScrollBar.visible = (debugText.maxScrollH > 1);
				}
			}
		}
		
		
		//This function takes the message level and returns the message color.
		/******************************************************************************/
		private static function getColorWithLevel(messageLevel:int, messageColorBase:Object = null):String {
			var adjustedMessageLevel:int = (messageLevel < 7) ? ((messageLevel > 0) ? messageLevel : 1) : 6;
			var returnColor:String;
			
			if (messageColorBase.r == 0 && messageColorBase.g == 0 && messageColorBase.b == 0) {
				returnColor = displayRGBInHex((messageColorBase.r + ((adjustedMessageLevel - 1) * 30)), (messageColorBase.g + ((adjustedMessageLevel - 1) * 30)), (messageColorBase.b + ((adjustedMessageLevel - 1) * 30)));
			} else {
				returnColor = displayRGBInHex((messageColorBase.r - ((adjustedMessageLevel - 1) * (messageColorBase.r / 5))), (messageColorBase.g - ((adjustedMessageLevel - 1) * (messageColorBase.g / 5))), (messageColorBase.b - ((adjustedMessageLevel - 1) * (messageColorBase.b / 5))));
			}
			
			return returnColor;
		}
		
		
		//This function takes a plain RGB color value and returns the hex version in string form for display.
		/******************************************************************************/
		private static function displayRGBInHex(red:uint, green:uint, blue:uint):String {
			var c:uint = ((red << 16) | (green << 8) | blue);
			var r:String = uint((c >> 16) & 0xFF).toString(16).toUpperCase();
			var g:String = uint((c >> 8) & 0xFF).toString(16).toUpperCase();
			var b:String = uint(c & 0xFF).toString(16).toUpperCase();
			var zero:String = "0";
			
			if (r.length == 1) {
				r = zero.concat(r);
			}
			
			if (g.length == 1) {
				g = zero.concat(g);
			}
			
			if (b.length == 1) {
				b = zero.concat(b);
			}
			
			return r + g + b;
		}
		
		
		//This function passes all instance print requests to the static method below but requests the message level first.
		/******************************************************************************/
		public function log(messageLevel:int, messageText:String):void{
			printStatic(messageText, messageLevel); //Forwards the debug message to the printStatic.
		}
		
		
		//This function sets the debug elements to be on the top of the display list.
		/******************************************************************************/
		public function stayOnTop():void {
			STAGE.setChildIndex(debugBackground, STAGE.numChildren - 1);
			STAGE.setChildIndex(debugText, STAGE.numChildren - 1);
			STAGE.setChildIndex(vScrollBar, STAGE.numChildren - 1);
			STAGE.setChildIndex(hScrollBar, STAGE.numChildren - 1);
			STAGE.setChildIndex(debugButton, STAGE.numChildren - 1);
		}
		
		
		//This function sends its arguments to the static resize function.
		/******************************************************************************/
		public function resizeDebug(intendedWidth:Number, intendedHeight:Number):void {
			resizeDebugStatic(intendedWidth, intendedHeight);
		}
		
		
		//This function resizes the debug to updated stage dimensions.
		/******************************************************************************/
		public static function resizeDebugStatic(intendedWidth:Number, intendedHeight:Number):void {
			debugBackground.width = intendedWidth;
			debugBackground.height = intendedHeight / 2;
			
			debugText.width = intendedWidth - 15;
			debugText.height = (intendedHeight / 2) - 15;
			
			vScrollBar.move(debugText.x + debugText.width, debugText.y);
			vScrollBar.height = debugBackground.height - 22;
			
			hScrollBar.move(debugText.x, debugText.y + debugText.height);
			hScrollBar.width = debugBackground.width - 100;
			
			debugButton.move(debugBackground.width - debugButton.width, (!debugHidden && debugVisible) ? debugBackground.height - debugButton.height : 0);
		}
		
		
		//This function toggles the debug window to hide/show or be invisible/visible based on input var.
		/******************************************************************************/
		public function hideDebug(debugVisible:String):void {
			
			if (!changingDebugDisplay) {
				
				changingDebugDisplay = true;
				
				//Chooses the correct display state of the debug window based on the local debugVisible argument
				switch (debugVisible) {
					//Opens the debug window
					case "show" :
						debugText.visible = true;
						debugBackground.visible = true;
						vScrollBar.visible = (debugText.maxScrollV > 1);
						hScrollBar.visible = (debugText.maxScrollH > 1);
						debugButton.label = "Hide Debug";
						debugButton.move(debugBackground.width - debugButton.width, debugBackground.height - debugButton.height);
						debugHidden = false;
						
						break;
					//Closes the debug window
					case "hide" :
						debugText.visible = false;
						debugBackground.visible = false;
						vScrollBar.visible = false;
						hScrollBar.visible = false;
						debugButton.label = "Show Debug";
						debugButton.move(debugBackground.width - debugButton.width, 0);
						debugHidden = true;
						
						break;
					//Makes the debug window visible
					case "visible" :
						//If the debug window was previously open while visible, it opens the window as well
						if (!debugHidden) {
							debugText.visible = true;
							debugBackground.visible = true;
							vScrollBar.visible = (debugText.maxScrollV > 1);
							hScrollBar.visible = (debugText.maxScrollH > 1);
							debugButton.label = "Hide Debug";
							debugButton.move(debugBackground.width - debugButton.width, debugBackground.height - debugButton.height);
						} else {
							debugText.visible = false;
							debugBackground.visible = false;
							vScrollBar.visible = false;
							hScrollBar.visible = false;
							debugButton.label = "Show Debug";
							debugButton.move(debugBackground.width - debugButton.width, 0);
						}
						
						debugButton.visible = true;
						
						break;
					//Makes the debug window invisible
					case "invisible" :
						debugText.visible = false;
						debugBackground.visible = false;
						vScrollBar.visible = false;
						hScrollBar.visible = false;
						debugButton.label = "Show Debug";
						debugButton.move(debugBackground.width - debugButton.width, 0);
						debugButton.visible = false;
						
						break;
				}
				
				stayOnTop();
				changingDebugDisplay = false;
				displayQueue("process");
			} else {
				displayQueue("add", {action:debugVisible});
			}
		}
		
		
		//This function
		/******************************************************************************/
		private function displayQueue(actionMode:String, actionData:Object = null):void {
			switch (actionMode) {
				case "add" :
					if (debugDisplayQueue[debugDisplayQueue.length - 1] != actionData) {
						debugDisplayQueue[debugDisplayQueue.length] = actionData;
					}
					break;
				case "process" :
					if (debugDisplayQueue.length > 0) {
						for (var i:int = 0; i < debugDisplayQueue.length; i++) {
							hideDebug(debugDisplayQueue[i].action);
						}
						
						debugDisplayQueue = new Array();
					}
					break;
			}
		}
		
		
		//This function toggles the hideDebug function.
		/******************************************************************************/
		private function buttonToggle():void {
			if (debugBackground.visible) {
				hideDebug("hide");
			} else {
				hideDebug("show");
			}
		}
		
		
		//This function sets the echo level to whatever is specified and sets time stamps to be visible
		/******************************************************************************/
		public function echoLevel(messageLevel:Number){
			debugLevel = messageLevel;
		}
		
		
		//This function is used to generate the current system clock when requested for time stamping
		/******************************************************************************/
		private static function timeStamp():String {
			var returnVal:String;
			var now:Date = new Date();
			
			returnVal = "[" + ((now.getHours() >= 10) ? now.getHours() : "0" + now.getHours()) + ":" + ((now.getMinutes() >= 10) ? now.getMinutes() : "0" + now.getMinutes()) + ":" + ((now.getSeconds() >= 10) ? now.getSeconds() : "0" + now.getSeconds()) + " " + now.getMilliseconds() + " ms] ";
			
			return returnVal;
		}
				
				
		/******************************************************************************/
		/******************************Listener Handlers*******************************/
		/******************************************************************************/
				
				
		//This function is the debugButton handler and calls the buttonToggle function.
		/******************************************************************************/
		private function debugButtonHandler(event:MouseEvent):void {
			buttonToggle();
		}
		
		
		//This function triggers when a key is pressed, the function's switch looks for a continuous press and hold of the "D" key.
		//******************************************************************************/
		private function keyHandler(event:KeyboardEvent):void {
			if (event.charCode != 0) {				
				switch (event.charCode) {
					//If the 'D' key is pressed, execute the following code.
					case 100:
						//If the previous key is also 'D', then move on.
						if (previousKey == String(event.charCode)) {
							incrementKey++; //Keeps track of how many D's have been pressed.
							
							if (incrementKey > 120) {
								incrementKey = 0;
								
								if (!debugVisible) {
									print("DEBUG: Debug Activated by Key", 4);
									debugVisible = true;
									hideDebug("visible");
								} else {
									print("DEBUG: Debug Deactivated by Key", 4);
									debugVisible = false;
									hideDebug("invisible");
								}
							}
						//Otherwise, it resets the 'D' counter to zero since it was less than 120 and a different key was detected.
						} else {
							incrementKey = 0;
						}

						break;
				}
				
				//Stores the previous key's character code for comparison
				previousKey = String(event.charCode);
			}			
		}
	}
}