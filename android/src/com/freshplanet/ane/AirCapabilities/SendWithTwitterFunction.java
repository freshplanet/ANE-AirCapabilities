package com.freshplanet.ane.AirCapabilities;

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class SendWithTwitterFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {

		String message = null;
		try {
			message = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}


		Intent intent = new Intent(Intent.ACTION_SEND);
		if (message != null)
		{
			intent.putExtra(Intent.EXTRA_TEXT, message);
		}
		intent.setType("text/plain");

		intent = HasTwitterFunction.getRightIntent(arg0.getActivity(), intent);
		if (intent != null)
		{
			arg0.getActivity().startActivity(intent);
		}
		
		return null;
	}

}
