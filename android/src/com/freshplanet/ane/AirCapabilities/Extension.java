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

package com.freshplanet.ane.AirCapabilities;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

import android.util.Log;

public class Extension implements FREExtension {

	public static String TAG = "AirCapabilities";
	
	public static FREContext context;
	public static boolean doLogging = false;
	
	/**
	 * Create the context (AS to Java).
	 */
	public FREContext createContext(String extId) {
		Log.d(TAG, "Extension.createContext extId: ");
		return context = new ExtensionContext();
	}

	/**
	 * Dispose the context.
	 */
	public void dispose() {
		if(doLogging)
			Log.d(TAG, "Extension.dispose");
		
		context = null;
	}
	
	/**
	 * Initialize the context.
	 * Doesn't do anything for now.
	 */
	public void initialize() {
		if(doLogging)
			Log.d(TAG, "Extension.initialize");
	}
	
	public static void log(String message)
	{
		if(doLogging)
			Log.d(TAG, message);
		
		if (context != null && message != null)
		{	
			context.dispatchStatusEventAsync("LOGGING", message);
		}
	}
}
