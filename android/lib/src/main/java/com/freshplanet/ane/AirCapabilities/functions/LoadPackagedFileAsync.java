package com.freshplanet.ane.AirCapabilities.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirCapabilities.AirCapabilitiesExtensionContext;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;

public class LoadPackagedFileAsync implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        AirCapabilitiesExtensionContext airCapabilitiesExtensionContext = ((AirCapabilitiesExtensionContext)freContext);

        String file;
        try {
            file = freObjects[0].getAsString();

            if (airCapabilitiesExtensionContext.loadedFiles.containsKey(file)) {
                freContext.dispatchStatusEventAsync("fileLoadSuccess", file);
            } else {
                startLoading(airCapabilitiesExtensionContext, file);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private static void startLoading(AirCapabilitiesExtensionContext context, String file) {
        new Thread(new Runnable() {
            @Override
            public void run() {

                try {
                    byte[] loadedBytes;
                    try (InputStream is = context.getActivity().getAssets().open(file);
                         ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {

                        byte[] buffer = new byte[2048 * 8];
                        int readBytes = 0;

                        while ((readBytes = is.read(buffer)) != -1) {
                            outputStream.write(buffer, 0, readBytes);
                        }
                        loadedBytes = outputStream.toByteArray();
                    }

                    context.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (context.loadedFiles != null) {
                                context.loadedFiles.put(file, loadedBytes);
                                context.dispatchStatusEventAsync("fileLoadSuccess", file);
                            }
                        }
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                    context.dispatchStatusEventAsync("fileLoadFailed", file);
                }
            }
        }).start();
    }
}
