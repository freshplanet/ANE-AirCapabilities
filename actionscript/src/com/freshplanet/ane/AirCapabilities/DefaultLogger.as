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



	internal class DefaultLogger implements ILogger {

		public function DefaultLogger() {
		}
		
		public function verbose(tag:String, ...params):void {
			log("[AirCapabilities] [Verbose]", tag, params);
		}

		public function debug(tag:String, ...params):void {
			log("[AirCapabilities] [Debug]", tag, params);
		}
		
		public function info(tag:String, ...params):void {
			log("[AirCapabilities] [Info]", tag, params);
		}
		
		public function warn(tag:String, ...params):void {
			log("[AirCapabilities] [Warn]", tag, params);
		}
		
		public function error(tag:String, ...params):void {
			log("[AirCapabilities] [Error]", tag, params);
		}
		
		private function log(type:String, tag:String, params):void {
			var str:String = "[AirCapabilities]" + type + "[" + tag + "]";
			if(params.length) {
				str += ": " + params.join(" - ");
			}
			trace(str);
		}
		
		
	}
}