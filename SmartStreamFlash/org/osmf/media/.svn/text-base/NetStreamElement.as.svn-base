package org.osmf.media  {
	
	import flash.media.Video;
	import flash.net.NetStream;
	
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class NetStreamElement extends MediaElement {

		public function set netStreamObject(netStream:NetStream):void{
			var video:Video = new Video();
			
			video.attachNetStream(netStream);
			video.smoothing = true;
			video.deblocking = 2;
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(video);
			addTrait(MediaTraitType.DISPLAY_OBJECT,displayObjectTrait);
		}

	}
	
}
