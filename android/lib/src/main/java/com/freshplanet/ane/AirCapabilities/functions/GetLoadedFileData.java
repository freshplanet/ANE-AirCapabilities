package com.freshplanet.ane.AirCapabilities.functions;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirCapabilities.AirCapabilitiesExtensionContext;

import java.nio.ByteBuffer;
import java.util.HashMap;

public class GetLoadedFileData implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {

        try {
            String file = freObjects[0].getAsString();
            HashMap<String, byte[]> loadedFiles = ((AirCapabilitiesExtensionContext)freContext).loadedFiles;

            if (loadedFiles.containsKey(file)) {
                byte[] loadedBytes = loadedFiles.get(file);
                FREByteArray freByteArray = FREByteArray.newByteArray();
                freByteArray.setProperty("length", FREObject.newObject(loadedBytes.length));

                freByteArray.acquire();
                ByteBuffer byteBuffer = freByteArray.getBytes();
                byteBuffer.put(loadedBytes);
                freByteArray.release();
                return freByteArray;
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
