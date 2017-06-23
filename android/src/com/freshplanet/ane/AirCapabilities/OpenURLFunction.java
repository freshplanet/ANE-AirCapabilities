package com.freshplanet.ane.AirCapabilities;

import android.content.Intent;
import android.net.Uri;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class OpenURLFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		try
		{
			String url = args[0].getAsString();
			
			Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			context.getActivity().startActivity(i); 
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return null;
	}
}
