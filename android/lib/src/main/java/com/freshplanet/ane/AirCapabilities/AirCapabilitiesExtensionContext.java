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
package com.freshplanet.ane.AirCapabilities;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirCapabilities.functions.CanOpenURLFunction;
import com.freshplanet.ane.AirCapabilities.functions.GetCurrentMemFunction;
import com.freshplanet.ane.AirCapabilities.functions.GetDeviceModelFunction;
import com.freshplanet.ane.AirCapabilities.functions.GetOSVersionFunction;
import com.freshplanet.ane.AirCapabilities.functions.HasInstagramFunction;
import com.freshplanet.ane.AirCapabilities.functions.HasSMSFunction;
import com.freshplanet.ane.AirCapabilities.functions.HasTwitterFunction;
import com.freshplanet.ane.AirCapabilities.functions.LogFunction;
import com.freshplanet.ane.AirCapabilities.functions.OpenURLFunction;
import com.freshplanet.ane.AirCapabilities.functions.PostPictureOnInstagramFunction;
import com.freshplanet.ane.AirCapabilities.functions.PostPictureOnTwitterFunction;
import com.freshplanet.ane.AirCapabilities.functions.ProcessReferralLinkFunction;
import com.freshplanet.ane.AirCapabilities.functions.RedirectToPageIdFunction;
import com.freshplanet.ane.AirCapabilities.functions.RedirectToRatingFunction;
import com.freshplanet.ane.AirCapabilities.functions.RedirectToTwitterAccountFunction;
import com.freshplanet.ane.AirCapabilities.functions.SendWithSMSFunction;
import com.freshplanet.ane.AirCapabilities.functions.SendWithTwitterFunction;
import com.freshplanet.ane.AirCapabilities.functions.SetLoggingFunction;

public class AirCapabilitiesExtensionContext extends FREContext {

	public static final String TAG = "InAppExtensionContext";

	public AirCapabilitiesExtensionContext()
	{
		if(AirCapabilitiesExtension.doLogging)
			Log.d(TAG, "AirCapabilitiesExtensionContext.C2DMExtensionContext");
	}
	
	@Override
	public void dispose() 
	{
		if(AirCapabilitiesExtension.doLogging)
			Log.d(TAG, "AirCapabilitiesExtensionContext.dispose");
		
		AirCapabilitiesExtension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() 
	{
		if(AirCapabilitiesExtension.doLogging)
			Log.d(TAG, "AirCapabilitiesExtensionContext.getFunctions");
		
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("hasSMS", new HasSMSFunction());
		functionMap.put("hasTwitter", new HasTwitterFunction());
		functionMap.put("sendWithSms", new SendWithSMSFunction());
		functionMap.put("sendWithTwitter", new SendWithTwitterFunction());
		functionMap.put("redirectToRating", new RedirectToRatingFunction());
		functionMap.put("getDeviceModel", new GetDeviceModelFunction());
		functionMap.put("getMachineName", new GetDeviceModelFunction()); // in android these are the same
		functionMap.put("processReferralLink", new ProcessReferralLinkFunction());
		functionMap.put("redirectToPageId", new RedirectToPageIdFunction());
		functionMap.put("redirectToTwitterAccount", new RedirectToTwitterAccountFunction());
		functionMap.put("canPostPictureOnTwitter", new HasTwitterFunction());
		functionMap.put("postPictureOnTwitter", new PostPictureOnTwitterFunction());
		functionMap.put("canOpenURL", new CanOpenURLFunction());
		functionMap.put("openURL", new OpenURLFunction());
		functionMap.put("getOSVersion", new GetOSVersionFunction());
		functionMap.put("setLogging", new SetLoggingFunction());
		functionMap.put("traceLog", new LogFunction());
		functionMap.put("hasInstagramEnabled", new HasInstagramFunction());
        functionMap.put("postPictureOnInstagram", new PostPictureOnInstagramFunction());
        functionMap.put("getCurrentMem", new GetCurrentMemFunction());
		return functionMap;	
	}

}
