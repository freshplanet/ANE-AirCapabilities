package com.freshplanet.ane.AirCapabilities;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.OutputStream;
import java.nio.ByteBuffer;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.net.Uri;
import android.util.Log;

import com.adobe.fre.FREBitmapData;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class PostPictureOnTwitterFunction implements FREFunction {

	private static String TAG = "postTwitter";
	
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

		if(Extension.doLogging)
			Log.d(TAG, "message acquired");


		// get bytes from bitmapdata
		FREBitmapData bitmap;
		ByteBuffer pixels = null;
		
        int srcWidth = 1;
        int srcHeight = 1;

        
        
        if(Extension.doLogging)
			Log.d(TAG, "image start");
        
		try {
			bitmap = (FREBitmapData)arg1[1];
			bitmap.acquire(); 
			pixels = bitmap.getBits(); 
			srcWidth = bitmap.getWidth();
			srcHeight = bitmap.getHeight();
			bitmap.release();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		}
		
		if(Extension.doLogging)
			Log.d(TAG, "image done");

		
    	String filename = "test.jpeg";
    	
		
		if (pixels == null)
		{
			if(Extension.doLogging)
				Log.d(TAG, "pixels is null");

			return null;
		}
		
		if(Extension.doLogging)
			Log.d(TAG, "convert to bitmap");
		
    	ByteBuffer argbPixels = null;
    	try {
    		argbPixels = swapColors(pixels);
    	} catch (Exception e)
    	{
			e.printStackTrace();
    	}
    	
    	if (argbPixels == null)
    	{
    		if(Extension.doLogging)
    			Log.d(TAG, "pixel is null");
			
			return null;
    	}
    	
    	Bitmap bm2 = Bitmap.createBitmap(srcWidth, srcHeight, Config.ARGB_8888);
    	bm2.copyPixelsFromBuffer( argbPixels );

    	if(Extension.doLogging)
			Log.d(TAG, "create output stream from path");

		
		OutputStream stream = null;
		try {
			stream = arg0.getActivity().openFileOutput(filename, Context.MODE_WORLD_READABLE);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		
		if (stream == null)
		{
			if(Extension.doLogging)
				Log.d(TAG, "stream is null");

			return null;
		}
		
		if(Extension.doLogging)
			Log.d(TAG, "compress to jepg");

		/* Write bitmap to file using JPEG and 80% quality hint for JPEG. */
		Boolean status = bm2.compress(CompressFormat.JPEG, 80, stream);

		if (status)
		{
			if(Extension.doLogging)
				Log.d(TAG, "succesfully compress");
		} 
		else
		{
			if(Extension.doLogging)
				Log.d(TAG, "not compressed");
			
	    	return null;
		}
		
		if(Extension.doLogging)
			Log.d(TAG, "send intent");

		
		Intent intent = new Intent(Intent.ACTION_SEND);
		if (message != null)
		{
			intent.putExtra(Intent.EXTRA_TEXT, message);
		}
		intent.setType("image/jpeg");

		intent = HasTwitterFunction.getRightIntent(arg0.getActivity(), intent);
		
		
		String absolute = arg0.getActivity().getFilesDir().getAbsolutePath()+"/"+filename;
		
		if (intent != null)
		{
			intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(new File(absolute)) );

			if(Extension.doLogging)
				Log.d(TAG, "start activity");

			arg0.getActivity().startActivity(intent);
		} else
		{
			if(Extension.doLogging)
				Log.d(TAG, "no intent found");
		}

		
		return null;
	}
	
	
	
	private ByteBuffer swapColors(ByteBuffer value)
	{
		ByteBuffer returnedValue = ByteBuffer.allocate(value.capacity());
		
		for (int i=0; i<returnedValue.capacity(); i+= 4)
		{
			byte b = value.get(i);
			byte g = value.get(i+1);
			byte r = value.get(i+2);
			byte a = value.get(i+3);
			
			returnedValue.put(i,   r);
			returnedValue.put(i+1, g);
			returnedValue.put(i+2, b);
			returnedValue.put(i+3, a);

		}
		
		
		return returnedValue;
	}

}
