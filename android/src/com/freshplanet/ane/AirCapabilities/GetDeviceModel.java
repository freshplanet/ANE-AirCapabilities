package com.freshplanet.ane.AirCapabilities;

import android.os.Build;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class GetDeviceModel implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String model = Build.MANUFACTURER + " " + Build.MODEL;
		
		FREObject retValue = null;
		
		try {
			retValue = FREObject.newObject(model);
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return retValue;
	}

}
