package com.freshplanet.ane.AirCapabilities;

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
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e)
		{
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
