package com.freshplanet.ane.AirCapabilities.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirCapabilities.AirCapabilitiesExtensionContext;

public class DeleteLoadedFileData implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        try {
            String file = freObjects[0].getAsString();
            ((AirCapabilitiesExtensionContext)freContext).loadedFiles.remove(file);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
