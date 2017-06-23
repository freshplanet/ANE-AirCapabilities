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

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirCapabilities extends EventDispatcher {

        static public const LOW_MEMORY_WARNING:String = "LOW_MEMORY_WARNING";

        static private const EXTENSION_ID:String = "com.freshplanet.ane.AirCapabilities";

        static private var _instance:AirCapabilities = null;

        private var _extContext:ExtensionContext = null;
        private var _doLogging:Boolean = false;
		private var _logger:INativeLogger;
		
		public function AirCapabilities() {

            super();

            if (_instance)
                throw new Error("singleton class, use .instance");

			_extContext = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			_extContext.addEventListener(StatusEvent.STATUS, _handleStatusEvent);
			
			if (isSupported)
				_logger = new NativeLogger(_extContext);
			else
				_logger = new DefaultLogger();

			_instance = this;
		}

        static public function get isSupported():Boolean {
            return Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1;
        }

		public function setLogging(value:Boolean):void {

			_doLogging = value;
			_extContext.call("setLogging", value);
		}
		
		public function get nativeLogger():INativeLogger {
            return _logger;
        }

        /**
         *
         */
        static public function get instance():AirCapabilities {
			return _instance != null ? _instance : new AirCapabilities()
		}

        /**
         *
         * @return
         */
		public function hasSmsEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasSMS");

			return false;
		}

        /**
         *
         * @return
         */
		public function hasTwitterEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasTwitter");

			return false;
		}

        /**
         *
         * @param message
         * @param recipient
         */
		public function sendMsgWithSms(message:String, recipient:String = null):void {

			if (isSupported)
				_extContext.call("sendWithSms", message, recipient);
		}

        /**
         *
         * @param message
         */
		public function sendMsgWithTwitter(message:String):void {

			if (isSupported)
				_extContext.call("sendWithTwitter", message);
		}

        /**
         *
         * @param appId
         * @param appName
         */
		public function redirecToRating(appId:String, appName:String):void {

			if (isSupported)
				_extContext.call("redirectToRating", appId, appName);
		}

        /**
         *
         * @return
         */
		public function getDeviceModel():String {

			if (isSupported)
				return _extContext.call("getDeviceModel") as String;

            return "";
		}

        /**
         *
         * @return
         */
		public function getMachineName():String {

			if (isSupported)
				return _extContext.call("getMachineName") as String;

            return "";
		}

        /**
         *
         * @param url
         */
		public function processReferralLink(url:String):void {

			if (isSupported)
				_extContext.call("processReferralLink", url);
		}

        /**
         *
         * @param pageId
         */
		public function redirectToPageId(pageId:String):void {

			if (isSupported)
				_extContext.call("redirectToPageId", pageId);
		}

        /**
         *
         * @param twitterAccount
         */
		public function redirectToTwitterAccount(twitterAccount:String):void {

			if (isSupported)
				_extContext.call("redirectToTwitterAccount", twitterAccount);
		}

        /**
         *
         * @return
         */
		public function canPostPictureOnTwitter():Boolean {

			if (isSupported)
				return _extContext.call("canPostPictureOnTwitter");

			return false;
		}

        /**
         *
         * @param message
         * @param bitmapData
         */
		public function postPictureOnTwitter(message:String, bitmapData:BitmapData):void {

			if (isSupported)
				_extContext.call("postPictureOnTwitter", message, bitmapData);
		}

        /**
         *
         * @return
         */
		public function hasInstagramEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasInstagramEnabled");

			return false;
		}

        /**
         *
         * @param message
         * @param bitmapData
         * @param x
         * @param y
         * @param width
         * @param height
         */
		public function postPictureOnInstagram(message:String, bitmapData:BitmapData,
                                               x:int, y:int, width:int, height:int):void {

			if (isSupported)
				_extContext.call("postPictureOnInstagram", message, bitmapData, x, y, width, height);
		}
		
		/**
		 * Open an application (if installed on the Device) or send the player to the appstore.  iOS Only 
		 * @param schemes 		List of schemes (String) that the application accepts.  Examples : @"sms://", @"twit://".  You can find schemes in http://handleopenurl.com/
		 * @param appStoreURL 	(optional) Link to the AppStore page for the Application for the player to download. URL can be generated via Apple's linkmaker (itunes.apple.com/linkmaker?)
		 */		
		public function openExternalApplication(schemes:Array, appStoreURL:String = null):void {

			if (isSupported && Capabilities.manufacturer.indexOf("Android") == -1)
				_extContext.call("openExternalApplication", schemes, appStoreURL);
		}

        /**
         *
         * @param url
         * @return
         */
		public function canOpenURL(url:String):Boolean {
			return isSupported ? _extContext.call("canOpenURL", url) as Boolean : false;
		}

        /**
         *
         * @param url
         */
		public function openURL(url:String):void {

			if (isSupported)
				_extContext.call("openURL", url);
		}

		/**
		 *
		 * @param appStoreId	id of the app to open a modal view to (do not include the "id" at the beginning of the number)
		 */
		public function openModalAppStoreIOS(appStoreId:String):void {

			if (Capabilities.manufacturer.indexOf("iOS") > -1)
				_extContext.call("openModalAppStore", appStoreId);
		}

        /**
         *
         * @return
         */
        public function getOSVersion():String {

            var value:String = "";
            if (isSupported)
                value = _extContext.call("getOSVersion") as String;

            return value;
        }

        /**
         *
         * @return
         */
//        public function getLocale():String {
//
//            var value:String = null;
//            if (Capabilities.manufacturer.indexOf("iOS") > -1)
//                value = _extContext.call("getLocale") as String;
//
//            return value;
//        }

        /**
         * @return  current amount of RAM being used in bytes
         */
        public function getCurrentMem():Number {

			if (!isSupported)
				return -1;

            var ret:Object = _extContext.call("getCurrentMem");
            if (ret is Error)
                throw ret;
            else
                return ret ? ret as Number : 0;
        }

        /**
         * @return  amount of RAM used by the VM
         */
        public function getCurrentVirtualMem():Number {

            if (Capabilities.manufacturer.indexOf("iOS") == -1)
                return -1;

            var ret:Object = _extContext.call("getCurrentVirtualMem");
            if (ret is Error)
                throw ret;
            else
                return ret ? ret as Number : 0;
        }

		/**
		 * @return
		 */
		public function canRequestReview():Boolean {

			if (!isSupported)
				return false;

			if (Capabilities.manufacturer.indexOf("iOS") == -1)
				return false;

			return _extContext.call("canRequestReview");
		}

		/**
		 * @return
		 */
		public function requestReview():void {

			if (!canRequestReview())
				return;

			_extContext.call("requestReview");
		}

        /**
         *
         * PRIVATE
         *
         */

        private function _handleStatusEvent(event:StatusEvent):void {

            if (event.code == "log")
                trace("[AirCapabilities] " + event.level);
            else if (event.code == "OPEN_URL")
                this.dispatchEvent(new OpenURLEvent(OpenURLEvent.OPEN_URL_SUCCESS, event.level));
            else
                this.dispatchEvent(event);
        }
	}
}





