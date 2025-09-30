package com.freshplanet.ane.AirCapabilities.functions;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.ByteBuffer;

public class LoadPackagedFile implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        FREByteArray freByteArray = null;

        try
        {
            String file = freObjects[0].getAsString();
            try (InputStream is = freContext.getActivity().getAssets().open(file)) {
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                byte[] buffer = new byte[2048 * 8];
                int readBytes = 0;

                while ((readBytes = is.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, readBytes);
                }

                freByteArray = FREByteArray.newByteArray();
                freByteArray.setProperty("length", FREObject.newObject(outputStream.size()));

                freByteArray.acquire();
                ByteBuffer byteBuffer = freByteArray.getBytes();
                byteBuffer.put(outputStream.toByteArray());
                freByteArray.release();
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }

        return freByteArray;
    }
}
