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

package com.freshplanet.nativeExtensions
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	
	
	public class AirCapabilities extends EventDispatcher
	{
		private var doLogging:Boolean = false;
		
		private static var extContext:ExtensionContext = null;
		
		private static var _instance:AirCapabilities = null;
		
		private var _logger:INativeLogger;
		
		public function AirCapabilities()
		{
			if(doLogging)
				trace("AirCapabilities Context Created Constructor");
			
			extContext = ExtensionContext.createExtensionContext("com.freshplanet.AirCapabilities", null);
			extContext.addEventListener(StatusEvent.STATUS, onStatus);
			
			if(this.useNativeExtension()) {
				_logger = new NativeLogger(extContext);
			} else {
				_logger = new DefaultLogger();
			}
			
			_instance = this;
		}
		
		public function setLogging(value:Boolean):void
		{
			doLogging = value;
			extContext.call("setLogging", value);
		}
		
		public function get nativeLogger():INativeLogger { return _logger; }
		
		public function onStatus(event:StatusEvent):void
		{
			if (event.code == "LOGGING" && doLogging)
			{
				trace("[AirCapabilities] " + event.level);
			}
			else if (event.code == "OPEN_URL")
			{
				var openEvent:OpenURLEvent = new OpenURLEvent(OpenURLEvent.OPEN_URL_SUCCESS, event.level);
				this.dispatchEvent(openEvent);
			}
		}
		
		public static function get instance():AirCapabilities {
			
			return _instance != null ? _instance : new AirCapabilities()
		} 
		
		public function hasSmsEnabled():Boolean
		{
			if (this.useNativeExtension())
			{
				return extContext.call("hasSMS");
			}
			return false;
		}
		
		
		public function hasTwitterEnabled():Boolean
		{
			if (this.useNativeExtension())
			{
				return extContext.call("hasTwitter");
			}
			return false;
		}
		
		public function sendMsgWithSms(message:String, recipient:String = null):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("sendWithSms", message, recipient);
			}
		}

		public function sendMsgWithTwitter(message:String):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("sendWithTwitter", message);
			}
		}

		public function redirecToRating(appId:String, appName:String):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("redirectToRating", appId, appName);
			}
		}

		public function getDeviceModel():String
		{
			if (this.useNativeExtension())
			{
				return extContext.call("getDeviceModel") as String;
			}
			return "";
		}
		public function getMachineName():String
		{
			if (this.useNativeExtension())
			{
				return extContext.call("getMachineName") as String;
			}
			return "";
		}
		
		public function processReferralLink(url:String):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("processReferralLink", url);
			}
		}
		
		
		public function redirectToPageId(pageId:String):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("redirectToPageId", pageId);
			}
		}
		
		public function redirectToTwitterAccount(twitterAccount:String):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("redirectToTwitterAccount", twitterAccount);
			}

		}
		
		public function canPostPictureOnTwitter():Boolean
		{
			if (this.useNativeExtension())
			{
				return extContext.call("canPostPictureOnTwitter");
			}
			return false;
		}
		
		public function postPictureOnTwitter(message:String, bitmapData:BitmapData):void
		{
			if (this.useNativeExtension())
			{
				extContext.call("postPictureOnTwitter", message, bitmapData);
			}
		}
		
		/**
		 * Open an application (if installed on the Device) or send the player to the appstore.  iOS Only 
		 * 
		 * @param schemes 		List of schemes (String) that the application accepts.  Examples : @"sms://", @"twit://".  You can find schemes in http://handleopenurl.com/
		 * @param appStoreURL 	(optional) Link to the AppStore page for the Application for the player to download. URL can be generated via Apple's linkmaker (itunes.apple.com/linkmaker?)
		 */		
		public function openExternalApplication( schemes : Array, appStoreURL : String = null ):void
		{
			if (this.useNativeExtension() && Capabilities.manufacturer.indexOf("Android") == -1)
			{
				extContext.call("openExternalApplication", schemes, appStoreURL);
			}
		}
		
		public function canOpenURL(url:String):Boolean
		{
			return useNativeExtension() ? extContext.call("canOpenURL", url) as Boolean : false;
		}
		
		public function openURL(url:String):void
		{
			if (useNativeExtension())
				extContext.call("openURL", url);
		}

		/**
		 *
		 * @param appStoreId	id of the app to open a modal view to (do not include the "id" at the beginning of the number)
		 */
		public function openModalAppStoreIOS(appStoreId:String):void
		{
			if (Capabilities.manufacturer.indexOf("iOS") > -1)
				extContext.call("openModalAppStore", appStoreId);
		}
		
		public function getOSVersion():String
		{
			var value:String = "";
			if (this.useNativeExtension())
			{
				value = extContext.call("getOSVersion") as String;
			}
			return value;
		}
		
		
		/**
		 * Check if the current device can use the native extension.
		 * For now, only iOS devices can do it.
		 */
		private function useNativeExtension():Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1;
		}

		
	}
}





