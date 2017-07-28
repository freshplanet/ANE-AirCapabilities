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
package com.freshplanet.ane.AirCapabilities.functions;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirCapabilities.AirCapabilitiesExtension;

public class CanOpenURLFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		FREObject result = null;
		
		try
		{
			String url = args[0].getAsString();
			
			Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			ResolveInfo resolveInfo = context.getActivity().getPackageManager().resolveActivity(i, PackageManager.MATCH_DEFAULT_ONLY);
			String defaultActivity = resolveInfo != null && resolveInfo.activityInfo != null ? resolveInfo.activityInfo.toString() : "None";
			
			if(AirCapabilitiesExtension.doLogging)
				Log.d(AirCapabilitiesExtension.TAG, "Resolved activity for URL \""+url+"\": " + defaultActivity);
			
			result = FREObject.newObject(resolveInfo != null && resolveInfo.activityInfo != null); 
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return result;
	}
}
