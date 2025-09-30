package com.freshplanet.ane.AirCapabilities.events {
    import flash.events.Event;

    public class AirCapabilitiesFileLoadEvent extends Event {

        public static const FILE_LOAD_FAILED:String = "fileLoadFailed";
        public static const FILE_LOAD_SUCCESS:String = "fileLoadSuccess";

        private var _fileName:String;

        public function AirCapabilitiesFileLoadEvent(type:String, fileName:String) {
            super(type, false, false);
            _fileName = fileName;
        }

        public function get fileName():String {
            return _fileName;
        }
    }
}
