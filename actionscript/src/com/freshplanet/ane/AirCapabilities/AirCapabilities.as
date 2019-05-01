/*
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.freshplanet.ane.AirCapabilities {

import com.freshplanet.ane.AirCapabilities.events.AirCapabilitiesLowMemoryEvent;
import com.freshplanet.ane.AirCapabilities.events.AirCapabilitiesOpenURLEvent;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirCapabilities extends EventDispatcher {

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		/**
		 * Is the ANE supported on the current platform
		 */
        static public function get isSupported():Boolean {
            return (Capabilities.manufacturer.indexOf("iOS") > -1 && Capabilities.os.indexOf("x86_64") < 0 && Capabilities.os.indexOf("i386") < 0) || Capabilities.manufacturer.indexOf("Android") > -1;
        }

		/**
		 * If <code>true</code>, logs will be displayed at the ActionScript and native level.
		 */
		public function setLogging(value:Boolean):void {

			_doLogging = value;
			if (isSupported)
				_extContext.call("setLogging", value);
		}
		
		public function get nativeLogger():ILogger {
            return _logger;
        }

        /**
         * AirCapabilities instance
         */
        static public function get instance():AirCapabilities {
			return _instance != null ? _instance : new AirCapabilities()
		}

        /**
         * Is SMS available
         * @return
         */
		public function hasSmsEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasSMS");

			return false;
		}

        /**
         * Is Twitter available
         * @return
         */
		public function hasTwitterEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasTwitter");

			return false;
		}

        /**
         * Sends an SMS message
         * @param message to send
         * @param recipient phonenumber
         */
		public function sendMsgWithSms(message:String, recipient:String = null):void {

			if (isSupported)
				_extContext.call("sendWithSms", message, recipient);
		}

        /**
         * Sends a Twitter message
         * @param message
         */
		public function sendMsgWithTwitter(message:String):void {

			if (isSupported)
				_extContext.call("sendWithTwitter", message);
		}

        /**
         * Redirect user to Rating page
         * @param appId
         * @param appName
         */
		public function redirecToRating(appId:String, appName:String):void {

			if (isSupported)
				_extContext.call("redirectToRating", appId, appName);
		}

        /**
         * Model of the device
         * @return
         */
		public function getDeviceModel():String {

			if (isSupported)
				return _extContext.call("getDeviceModel") as String;

            return "";
		}

        /**
         * Name of the machine
         * @return
         */
		public function getMachineName():String {

			if (isSupported)
				return _extContext.call("getMachineName") as String;

            return "";
		}

        /**
         * Opens the referral link URL
         * @param url
         */
		public function processReferralLink(url:String):void {

			if (isSupported)
				_extContext.call("processReferralLink", url);
		}

        /**
         * Opens Facebook page
         * @param pageId id of the facebook page
         */
		public function redirectToPageId(pageId:String):void {

			if (isSupported)
				_extContext.call("redirectToPageId", pageId);
		}

        /**
         * Opens Twitter account
         * @param twitterAccount
         */
		public function redirectToTwitterAccount(twitterAccount:String):void {

			if (isSupported)
				_extContext.call("redirectToTwitterAccount", twitterAccount);
		}

        /**
         * Is posting pictures on Twitter enabled
         * @return
         */
		public function canPostPictureOnTwitter():Boolean {

			if (isSupported)
				return _extContext.call("canPostPictureOnTwitter");

			return false;
		}

        /**
         * Post new picture on Twitter
         * @param message
         * @param bitmapData
         */
		public function postPictureOnTwitter(message:String, bitmapData:BitmapData):void {

			if (isSupported)
				_extContext.call("postPictureOnTwitter", message, bitmapData);
		}

        /**
         * Is Instagram enabled
         * @return
         */
		public function hasInstagramEnabled():Boolean {

			if (isSupported)
				return _extContext.call("hasInstagramEnabled");

			return false;
		}

        /**
         * Post new picture on Instagram
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
         * Is opening URLs available
         * @param url
         * @return
         */
		public function canOpenURL(url:String):Boolean {
			return isSupported ? _extContext.call("canOpenURL", url) as Boolean : false;
		}

        /**
         * Open URL
         * @param url
         */
		public function openURL(url:String):void {

			if (canOpenURL(url))
				_extContext.call("openURL", url);
		}

		/**
		 * Opens modal app store. Available on iOS only
		 * @param appStoreId	id of the app to open a modal view to (do not include the "id" at the beginning of the number)
		 */
		public function openModalAppStoreIOS(appStoreId:String):void {

			if (Capabilities.manufacturer.indexOf("iOS") > -1)
				_extContext.call("openModalAppStore", appStoreId);
		}

        /**
         * Version of the operating system
         * @return
         */
        public function getOSVersion():String {

            if (isSupported)
                return _extContext.call("getOSVersion") as String;

            return "";
        }


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

			if(!isSupported)
				return -1;

            if (Capabilities.manufacturer.indexOf("iOS") == -1)
                return -1;

            var ret:Object = _extContext.call("getCurrentVirtualMem");
            if (ret is Error)
                throw ret;
            else
                return ret ? ret as Number : 0;
        }

		/**
		 * @return  is requesting review available. Available on iOS only
		 */
		public function canRequestReview():Boolean {

			if (!isSupported)
				return false;

			if (Capabilities.manufacturer.indexOf("iOS") == -1)
				return false;

			return _extContext.call("canRequestReview");
		}

		/**
		 * Request AppStore review. Available on iOS only
		 */
		public function requestReview():void {

			if (!canRequestReview())
				return;

			_extContext.call("requestReview");
		}
		/**
		 * Generate haptic feedback - iOS only
		 */
		public function generateHapticFeedback(feedbackType:AirCapabilitiesHapticFeedbackType):void {

			if (Capabilities.manufacturer.indexOf("iOS") < 0)
				return;

			if(!feedbackType)
				return

			_extContext.call("generateHapticFeedback", feedbackType.value);
		}

		public function getNativeScale():Number 
		{
			if (Capabilities.manufacturer.indexOf("iOS") < 0)
				return 1;
			return _extContext.call("getNativeScale") as Number;
		}

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		static private const EXTENSION_ID:String = "com.freshplanet.ane.AirCapabilities";

		static private var _instance:AirCapabilities = null;

		private var _extContext:ExtensionContext = null;
		private var _doLogging:Boolean = false;
		private var _logger:ILogger;

		/**
		 * "private" singleton constructor
		 */
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

        private function _handleStatusEvent(event:StatusEvent):void {

            if (event.code == "log")
	            _doLogging && trace("[AirCapabilities] " + event.level);
            else if (event.code == "OPEN_URL")
                this.dispatchEvent(new AirCapabilitiesOpenURLEvent(AirCapabilitiesOpenURLEvent.OPEN_URL_SUCCESS, event.level));
            else if (event.code == AirCapabilitiesLowMemoryEvent.LOW_MEMORY_WARNING) {
	            var memory:Number = Number(event.level);
	            this.dispatchEvent(new AirCapabilitiesLowMemoryEvent(event.code, memory));
            }
            else
                this.dispatchEvent(event);
        }
	}
}





