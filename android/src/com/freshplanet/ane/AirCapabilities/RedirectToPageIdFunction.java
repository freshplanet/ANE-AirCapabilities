package com.freshplanet.ane.AirCapabilities;

import android.content.Intent;
import android.net.Uri;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class RedirectToPageIdFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		String pageId = null;
		try {
			pageId = arg1[0].getAsString();
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
		
		Intent intent = null;

		if (pageId != null)
		{
			try {
				arg0.getActivity().getPackageManager().getPackageInfo("com.facebook.katana", 0);
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("fb://profile/"+pageId));
			} catch (Exception e) {
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.facebook.com/"+pageId));
			}
			
		}
		
		if (intent != null)
		{
			arg0.getActivity().startActivity(intent);
		}

		return null;
	}

}
