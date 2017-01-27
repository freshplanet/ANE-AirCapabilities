package com.freshplanet.ane.AirCapabilities;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class SetLogging implements FREFunction 
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		boolean value = Extension.doLogging;
		try
		{
			value = arg1[0].getAsBool();
		}
		catch (IllegalStateException e)
		{
			e.printStackTrace();
		}
		catch (FRETypeMismatchException e)
		{
			e.printStackTrace();
		}
		catch (FREInvalidObjectException e)
		{
			e.printStackTrace();
		}
		catch (FREWrongThreadException e)
		{
			e.printStackTrace();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		Extension.doLogging = value;
		return null;
	}

}
