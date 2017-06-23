package com.freshplanet.ane.AirCapabilities
{
	/**
	 * 
	 * A logging interface patterned after android.utils.Log (i.e. please use short strings for 'tag' 
	 * and put any longer stuff in the additional arguments instead).
	 * 
	 */	
	public interface INativeLogger
	{
		function verbose(tag:String, ...params):void;
		function debug(tag:String, ...params):void;
		function info(tag:String, ...params):void;
		function warn(tag:String, ...params):void;
		function error(tag:String, ...params):void;
	}
}