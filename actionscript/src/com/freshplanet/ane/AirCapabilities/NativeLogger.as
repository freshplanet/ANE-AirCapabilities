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

	import flash.external.ExtensionContext;

	public class NativeLogger implements ILogger {

		private var _context:ExtensionContext;
		private static const VERBOSE:int = 2;
		private static const DEBUG:int = 3;
		private static const INFO:int = 4;
		private static const WARN:int = 5;
		private static const ERROR:int = 6;
		
		public function NativeLogger(ctx:ExtensionContext) {
			_context = ctx;	
		}
		
		public function verbose(tag:String, ...params):void {
			_context.call("traceLog", VERBOSE, tag, params.join(" - "));
		}
		
		public function debug(tag:String, ...params):void {
			_context.call("traceLog", DEBUG, tag, params.join(" - "));
		}
		
		public function info(tag:String, ...params):void {
			_context.call("traceLog", INFO, tag, params.join(" - "));
		}
		
		public function warn(tag:String, ...params):void {
			_context.call("traceLog", WARN, tag, params.join(" - "));
		}
		
		public function error(tag:String, ...params):void {
			_context.call("traceLog", ERROR, tag, params.join(" - ")); 
		}
		
	}
}