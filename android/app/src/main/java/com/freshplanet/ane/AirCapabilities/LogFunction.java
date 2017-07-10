/**
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
package com.freshplanet.ane.AirCapabilities;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class LogFunction implements FREFunction {
	
	private static final int VERBOSE = 2;
	private static final int DEBUG = 3;
	private static final int INFO = 4;
	private static final int WARN = 5;
	private static final int ERROR = 6; 

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) 
	{
		try {
			int level = arg1[0].getAsInt();
			switch (level) {
			case VERBOSE:
				Log.v(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case DEBUG:
				Log.d(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case INFO:
				Log.i(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case WARN:
				Log.w(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case ERROR:
				Log.e(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			}
		} catch (Exception e) {
			Log.wtf(ExtensionContext.TAG, e);
		}
		return null;
	}

}
