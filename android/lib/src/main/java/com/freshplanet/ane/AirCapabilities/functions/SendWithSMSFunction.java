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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class SendWithSMSFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String message = null;
		String recipient = null;
		
		try {
			message = arg1[0].getAsString();
			recipient = arg1[1].getAsString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		Intent sendIntent = new Intent(Intent.ACTION_VIEW);
		if (message != null)
		{
			sendIntent.putExtra("address", recipient);
			sendIntent.putExtra("sms_body", message); 
		}
		sendIntent.setType("vnd.android-dir/mms-sms");
		arg0.getActivity().startActivity(sendIntent);
		
		return null;
	}

}
