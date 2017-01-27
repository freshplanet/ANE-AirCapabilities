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

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class ExtensionContext extends FREContext {

	public static final String TAG = "InAppExtensionContext";

	public ExtensionContext() 
	{
		if(Extension.doLogging)
			Log.d(TAG, "ExtensionContext.C2DMExtensionContext");
	}
	
	@Override
	public void dispose() 
	{
		if(Extension.doLogging)
			Log.d(TAG, "ExtensionContext.dispose");
		
		Extension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() 
	{
		if(Extension.doLogging)
			Log.d(TAG, "ExtensionContext.getFunctions");
		
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("hasSMS", new HasSMSFunction());
		functionMap.put("hasTwitter", new HasTwitterFunction());
		functionMap.put("sendWithSms", new SendWithSMSFunction());
		functionMap.put("sendWithTwitter", new SendWithTwitterFunction());
		functionMap.put("redirectToRating", new RedirectToRatingFunction());
		functionMap.put("getDeviceModel", new GetDeviceModel());
		functionMap.put("getMachineName", new GetDeviceModel()); // in android these are the same
		functionMap.put("processReferralLink", new ProcessReferralLinkFunction());
		functionMap.put("redirectToPageId", new RedirectToPageIdFunction());
		functionMap.put("redirectToTwitterAccount", new RedirectToTwitterAccount());
		functionMap.put("canPostPictureOnTwitter", new HasTwitterFunction());
		functionMap.put("postPictureOnTwitter", new PostPictureOnTwitterFunction());
		functionMap.put("canOpenURL", new CanOpenURLFunction());
		functionMap.put("openURL", new OpenURLFunction());
		functionMap.put("getOSVersion", new GetOSVersionFunction());
		functionMap.put("setLogging", new SetLogging());
		functionMap.put("traceLog", new LogFunction());
		functionMap.put("hasInstagram", new HasInstagramFunction());
		functionMap.put("postPictureOnInstagram", new PostPictureOnInstagramFunction());
		return functionMap;	
	}

}
