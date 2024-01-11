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
import android.net.Uri;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class RedirectToTwitterAccountFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String twitterAccount = null;
		try {
			twitterAccount = arg1[0].getAsString();
		} catch (Exception e) {
			e.printStackTrace();
		}

		Intent intent = null;
		
		
		if (twitterAccount != null)
		{
			try {
				arg0.getActivity().getPackageManager().getPackageInfo("com.twitter.android", 0);
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("twitter://user?screen_name="+twitterAccount));
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			} catch (Exception e) {
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/"+twitterAccount));
			}
		}
		
		if (intent != null)
		{
			arg0.getActivity().startActivity(intent);
		}
		return null;
	}

}
