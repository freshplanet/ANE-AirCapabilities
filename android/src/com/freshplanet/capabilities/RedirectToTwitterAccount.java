package com.freshplanet.capabilities;

import java.util.List;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class RedirectToTwitterAccount implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String twitterAccount = null;
		try {
			twitterAccount = arg1[0].getAsString();
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

		if (twitterAccount != null)
		{
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("twitter://user?screen_name="+twitterAccount));
			final PackageManager packageManager = arg0.getActivity().getPackageManager();
			List<ResolveInfo> list = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
			if(list.size() == 0) {
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/#!/"+twitterAccount));
			}
			arg0.getActivity().startActivity(intent);
		}
		return null;
	}

}
