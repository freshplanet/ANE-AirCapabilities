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

import android.content.pm.PackageManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class HasPackageInstalledFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		FREObject result = null;

		try
		{
			String packageName = args[0].getAsString();
			try {
				context.getActivity().getPackageManager().getPackageGids(packageName);
				result = FREObject.newObject(true);
			} catch (PackageManager.NameNotFoundException e) {
				result = FREObject.newObject(false);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}

		return result;
	}
}
