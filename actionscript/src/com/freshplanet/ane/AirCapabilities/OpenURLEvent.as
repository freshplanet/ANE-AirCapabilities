//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirCapabilities {

	import flash.events.Event;
	
	public class OpenURLEvent extends Event {

		static public const OPEN_URL_SUCCESS:String = "OpenUrlSuccess";
		static public const TO_APP_STORE:String = "STORE";
		static public const TO_APP:String = "APP";
		
		private var _openType:String;
		
		public function OpenURLEvent(type:String, openType:String, bubbles:Boolean = false, cancelable:Boolean = false) {

			_openType = openType;
			super(type, bubbles, cancelable);
		}
		
		public function get openType():String {
			return this._openType;
		}
	}
}