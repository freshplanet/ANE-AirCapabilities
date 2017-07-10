package com.freshplanet.ane.AirCapabilities
{
	internal class DefaultLogger implements ILogger
	{
		public function DefaultLogger()
		{
		}
		
		public function verbose(tag:String, ...params):void
		{
			log("[AirCapabilities] [Verbose]", tag, params);
		}
		
		public function debug(tag:String, ...params):void
		{
			log("[AirCapabilities] [Debug]", tag, params);
		}
		
		public function info(tag:String, ...params):void
		{
			log("[AirCapabilities] [Info]", tag, params);
		}
		
		public function warn(tag:String, ...params):void
		{
			log("[AirCapabilities] [Warn]", tag, params);
		}
		
		public function error(tag:String, ...params):void
		{
			log("[AirCapabilities] [Error]", tag, params);
		}
		
		private function log(type:String, tag:String, params):void 
		{
			var str:String = "[AirCapabilities]" + type + "[" + tag + "]";
			if(params.length) {
				str += ": " + params.join(" - ");
			}
			trace(str);
		}
		
		
	}
}