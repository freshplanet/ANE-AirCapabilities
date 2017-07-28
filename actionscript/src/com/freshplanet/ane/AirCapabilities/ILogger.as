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
	/**
	 * 
	 * A logging interface patterned after android.utils.Log (i.e. please use short strings for 'tag' 
	 * and put any longer stuff in the additional arguments instead).
	 * 
	 */	
	public interface ILogger {
		function verbose(tag:String, ...params):void;
		function debug(tag:String, ...params):void;
		function info(tag:String, ...params):void;
		function warn(tag:String, ...params):void;
		function error(tag:String, ...params):void;
	}
}