/**
 * Created by Mateo Kozomara (mateo.kozomara@gmail.com) on 27/07/2017.
 */
package com.freshplanet.ane.AirCapabilities.events {
import flash.events.Event;

public class AirCapabilitiesLowMemoryEvent extends Event {


	static public const LOW_MEMORY_WARNING:String = "LOW_MEMORY_WARNING";
	private var _currentMemory:Number;


	public function AirCapabilitiesLowMemoryEvent(type:String, currentMemory:Number, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
		_currentMemory = currentMemory;
	}

	public function get currentMemory():Number {
		return _currentMemory;
	}
}
}
