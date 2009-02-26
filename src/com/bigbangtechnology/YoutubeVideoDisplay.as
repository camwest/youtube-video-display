package com.bigbangtechnology
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.VideoDisplay;

	public class YoutubeVideoDisplay extends VideoDisplay
	{
		public var proxyUrl:String;		
		
		public function YoutubeVideoDisplay()
		{
			super();
		}
		
		//override the default source setter so that we can go get the proper youtube FLV file
		override public function set source(value:String):void
		{
			if(!proxyUrl) {
				throw new Error("A Proxy URL must be set for youtube display to work in flex");
			}
			
			pageSource = value;
			getFLVSourceUrl();
		}
		
		/** PRIVATE **/
		
		//starts the loading process by loading the video page
		private function getFLVSourceUrl():void
		{
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(proxyUrl + escape(pageSource));
			
			loader.addEventListener(Event.COMPLETE, eventCompleteListener);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
			loader.load(req);
		}
				
		private function getTFromPageData(pageData:String):String
		{
			var regex:RegExp = /"t": "(.*?)"/;
			var result:Array = pageData.match(regex);
			
			if (result.length < 2) { 
			    throw new Error("Error parsing YouTube page: Couldn't get 't' parameter"); 
			} 
			  
			return result[1];			 
		}
		
		private function getVideoIdFromPageData(pageData:String):String
		{
			var regex:RegExp = /"video_id": "(.*?)"/; 
			var result:Array = pageData.match(regex); 
			
			if (result.length < 2) { 
			    throw new Error("Error parsing YouTube page: Couldn't get 'video_id' parameter");  
			} 

			return result[1];			
		}
		
		private function constructFLVUrl (id:String, t:String):String
		{
			var str:String = "http://www.youtube.com/get_video.php?";
			str += "video_id=" + id;
			str += "&t=" + t;
			return str;
		}
		
		/** EVENTS **/
		
		private function eventCompleteListener(e:Event):void
		{
			var pageData:String = e.currentTarget.data;
			
			var t:String = getTFromPageData(pageData);
			var id:String = getVideoIdFromPageData(pageData);
			
			var flvUrl:String = constructFLVUrl(id, t);
			
			super.source = flvUrl;
			
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			throw new Error(e.text);
		}
				
		private var pageSource:String;
		
	}
}