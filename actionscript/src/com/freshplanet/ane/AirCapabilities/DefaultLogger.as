package com.freshplanet.ane.AirCapabilities
{
	internal class DefaultLogger implements INativeLogger
	{
		public function DefaultLogger()
		{
		}
		
		public function verbose(tag:String, ...params):void
		{
			log("[Verbose]", tag, params);
		}
		
		public function debug(tag:String, ...params):void
		{
			log("[Debug]", tag, params);
		}
		
		public function info(tag:String, ...params):void
		{
			log("[Info]", tag, params);
		}
		
		public function warn(tag:String, ...params):void
		{
			log("[Warn]", tag, params);
		}
		
		public function error(tag:String, ...params):void
		{
			log("[Error]", tag, params);
		}
		
		private function log(type:String, tag:String, params):void 
		{
			var str:String = "[NativeLogger]" + type + "[" + tag + "]";
			if(params.length) {
				str += ": " + params.join(" - ");
			}
			trace(str);
		}
		
		
	}
}