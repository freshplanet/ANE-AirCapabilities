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
public class AirCapabilitiesHapticFeedbackType {
	/***************************
	 *
	 * PUBLIC
	 *
	 ***************************/


	static public const SELECTION                      	: AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 0);
	static public const IMPACT_LIGHT                    : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 1);
	static public const IMPACT_MEDIUM                   : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 2);
	static public const IMPACT_HEAVY                    : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 3);
	static public const NOTIFICATION_SUCCESS            : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 4);
	static public const NOTIFICATION_WARNING            : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 5);
	static public const NOTIFICATION_ERROR              : AirCapabilitiesHapticFeedbackType = new AirCapabilitiesHapticFeedbackType(Private, 6);

	public static function fromValue(value:int):AirCapabilitiesHapticFeedbackType {

		switch (value)
		{
			case SELECTION.value:
				return SELECTION;
				break;
			case IMPACT_LIGHT.value:
				return IMPACT_LIGHT;
				break;
			case IMPACT_MEDIUM.value:
				return IMPACT_MEDIUM;
				break;
			case IMPACT_HEAVY.value:
				return IMPACT_HEAVY;
				break;
			case NOTIFICATION_SUCCESS.value:
				return NOTIFICATION_SUCCESS;
				break;
			case NOTIFICATION_WARNING.value:
				return NOTIFICATION_WARNING;
				break;
			case NOTIFICATION_ERROR.value:
				return NOTIFICATION_ERROR;
				break;
			default:
				return null;
				break;
		}
	}

	public function get value():int {
		return _value;
	}

	/***************************
	 *
	 * PRIVATE
	 *
	 ***************************/

	private var _value:int;

	public function AirCapabilitiesHapticFeedbackType(access:Class, value:int) {

		if (access != Private)
			throw new Error("Private constructor call!");

		_value = value;
	}
}
}
final class Private {}