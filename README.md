SmartStream
===========

iOS/Flash Video Player Suite for HTTP Adaptive Bitrate Streaming


##Working Example##
Here is an example of SmartStream Flash player in action.  You can link to any of the test streams listed below using the link bar at the top of the player.

http://www.mantainnovations.com/SmartStreamPlayerFlash.swf


##Test Streams##
MP4 Test Stream

http://stream.flowplayer.org/big_buck_bunny_with_captions.mp4 (Captions)

HLS Test Stream

http://now.video.nfl.com/i/captiontest/closedcaptiontest_,350k,550k,.mp4.csmil/master.m3u8 (Captions)

HDS Test Stream

http://office.realeyes.com:8134/vod/hds-sample/sample.f4m

IIS Smooth Streaming Test Stream

http://playready.directtaps.net/smoothstreaming/SSWSS720H264/SuperSpeedway_720.ism/Manifest


##SmartStream iOS##
This player supports the playback of HLS and MP4 content with the following features:
 - Adaptive Bitrate Streaming
 - Closed Caption support
 - AirPlay Remoting
 - On-demand HLS playback (Play, Pause, Seek, Stop)
 - Support for video codecs - H.264
 - Support for Audio codecs - AAC
 - Video Linking Bar

###Build Instructions###
 - Download/Clone/Fork the contents of SmartStreamiOS
 - Open SmartStream.xcodeproj in XCode
 - Compile the player for iPad or iPhone
 - Use the in-player link bar to run other streams


##SmartStream Flash
This player supports the playback of HDS, HLS, IIS Smooth Streaming and MP4 content with the following features:
 - Adaptive Bitrate Streaming
 - On-demand HLS/HDS/IIS Smooth Streaming playback (Play, Pause, Seek, Stop)
 - Support for video codecs - H.264
 - Support for Audio codecs - AAC
 - Video Linking Bar

###The following are unsupported features for IIS Smooth Streaming:
 - VC-1 and WMA codec
 - Content protection (PlayReady)
 - Text and Sparse Tracks
 - Trickplay (slow motion, fast-forward, and rewind)

###Build Instructions
 - Download/Clone/Fork the contents of SmartStreamFlash
 - Make edits to SmartStreamPlayerFlash.fla and SmartStreamMain.as as well as MediaHandler.as and MediaDisplayHandler.as within the classes directory.
 - Embed SmartStreamPlayerFlash.swf on a web page or you can export this project as a standalone projector.










