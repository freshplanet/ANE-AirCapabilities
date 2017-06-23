package com.freshplanet.ane.AirCapabilities;
import android.content.pm.PackageManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;


public class HasSMSFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		boolean value = arg0.getActivity().getPackageManager().hasSystemFeature(PackageManager.FEATURE_TELEPHONY);
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

}
