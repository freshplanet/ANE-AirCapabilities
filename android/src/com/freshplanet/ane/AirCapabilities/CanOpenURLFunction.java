package com.freshplanet.ane.AirCapabilities;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class CanOpenURLFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		FREObject result = null;
		
		try
		{
			String url = args[0].getAsString();
			
			Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			ResolveInfo resolveInfo = context.getActivity().getPackageManager().resolveActivity(i, PackageManager.MATCH_DEFAULT_ONLY);
			String defaultActivity = resolveInfo != null && resolveInfo.activityInfo != null ? resolveInfo.activityInfo.toString() : "None";
			
			if(Extension.doLogging)
				Log.d(Extension.TAG, "Resolved activity for URL \""+url+"\": " + defaultActivity);
			
			result = FREObject.newObject(resolveInfo != null && resolveInfo.activityInfo != null); 
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return result;
	}
}
