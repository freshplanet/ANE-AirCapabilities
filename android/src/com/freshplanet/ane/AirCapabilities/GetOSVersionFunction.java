package com.freshplanet.ane.AirCapabilities;

import android.os.Build;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class GetOSVersionFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		int version = Build.VERSION.SDK_INT;
		
		FREObject retValue = null;
		
		try {
			retValue = FREObject.newObject(Integer.toString(version));
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return retValue;
	}

}
