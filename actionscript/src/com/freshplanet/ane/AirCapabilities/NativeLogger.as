package com.freshplanet.ane.AirCapabilities
{
	import flash.external.ExtensionContext;

	internal class NativeLogger implements INativeLogger
	{
		private var _context:ExtensionContext;
		private static const VERBOSE:int = 2;
		private static const DEBUG:int = 3;
		private static const INFO:int = 4;
		private static const WARN:int = 5;
		private static const ERROR:int = 6;
		
		public function NativeLogger(ctx:ExtensionContext)
		{
			_context = ctx;	
		}
		
		public function verbose(tag:String, ...params):void
		{
			_context.call("traceLog", VERBOSE, tag, params.join(" - "));
		}
		
		public function debug(tag:String, ...params):void
		{
			_context.call("traceLog", DEBUG, tag, params.join(" - "));
		}
		
		public function info(tag:String, ...params):void
		{
			_context.call("traceLog", INFO, tag, params.join(" - "));
		}
		
		public function warn(tag:String, ...params):void
		{
			_context.call("traceLog", WARN, tag, params.join(" - "));
		}
		
		public function error(tag:String, ...params):void
		{
			_context.call("traceLog", ERROR, tag, params.join(" - ")); 
		}
		
	}
}