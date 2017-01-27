package com.freshplanet.ane.AirCapabilities;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class LogFunction implements FREFunction {
	
	private static final int VERBOSE = 2;
	private static final int DEBUG = 3;
	private static final int INFO = 4;
	private static final int WARN = 5;
	private static final int ERROR = 6; 

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) 
	{
		try {
			int level = arg1[0].getAsInt();
			switch (level) {
			case VERBOSE:
				Log.v(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case DEBUG:
				Log.d(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case INFO:
				Log.i(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case WARN:
				Log.w(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			case ERROR:
				Log.e(arg1[1].getAsString(), arg1[2].getAsString());
				break;
			}
		} catch (Exception e) {
			Log.wtf(ExtensionContext.TAG, e);
		}
		return null;
	}

}
