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

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class HasTwitterFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		
		Intent intent = new Intent(Intent.ACTION_SEND);
		intent.putExtra(Intent.EXTRA_TEXT, "Test");
		intent.setType("text/plain");
		intent = getRightIntent(arg0.getActivity(), intent);
		boolean value = (intent != null);
		
		FREObject retValue = null;
		
		try {
			retValue = FREObject.newObject(value);
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return retValue;
	}

	
	public static final String[] twitterApps = {
			// package // name - nb installs (thousands)
			"com.twitter.android", // official - 10 000
			"com.twidroid", // twidroyd - 5 000
			"com.handmark.tweetcaster", // Tweecaster - 5 000
			"com.thedeck.android" // TweetDeck - 5 000 
			};

	
	public static Intent getRightIntent(Context context, Intent intent) {
		if (intent == null)
		{
			return intent;
		}
		PackageManager packageManager = context.getPackageManager();
		List<ResolveInfo> list = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);

		for (int i=0; i < twitterApps.length; i++)
		{
			for (ResolveInfo resolveInfo : list) 
			{
				String p = resolveInfo.activityInfo.packageName;
				if (p != null && p.startsWith(twitterApps[i])) {
					intent.setPackage(p);
					return intent;
				}
			}

		}
		return null;
	}
	
	
}
