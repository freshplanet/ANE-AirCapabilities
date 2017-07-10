/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package {

import com.freshplanet.ane.AirCapabilities.AirCapabilities;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;
import flash.text.TextField;

import ui.ScrollableContainer;
import ui.TestBlock;

[SWF(backgroundColor="#057fbc", frameRate='60')]
public class Main extends Sprite {

    public static var stageWidth:Number = 0;
    public static var indent:Number = 0;

    private var _scrollableContainer:ScrollableContainer = null;

    public function Main() {
        this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
    }

    private function _onAddedToStage(event:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        this.stage.align = StageAlign.TOP_LEFT;

        stageWidth = this.stage.stageWidth;
        indent = stage.stageWidth * 0.025;

        _scrollableContainer = new ScrollableContainer(false, true);
        this.addChild(_scrollableContainer);

        if (!AirCapabilities.isSupported) {

            trace("AirCapabilities ANE is NOT supported on this platform!");
            return;
        }

        AirCapabilities.instance.setLogging(true);

        var blocks:Array = [];

        blocks.push(new TestBlock("canPostPictureOnTwitter", function():void {
            trace("canPostPictureOnTwitter", AirCapabilities.instance.canPostPictureOnTwitter());
        }));
        blocks.push(new TestBlock("canRequestReview", function():void {
            trace("canRequestReview ", AirCapabilities.instance.canRequestReview());
        }));
        blocks.push(new TestBlock("requestReview", function():void {
            trace("requestReview ", AirCapabilities.instance.requestReview());
        }));
        blocks.push(new TestBlock("getCurrentMem", function():void {
            trace("getCurrentMem ", AirCapabilities.instance.getCurrentMem());
        }));
        blocks.push(new TestBlock("getCurrentVirtualMem", function():void {
            trace("getCurrentVirtualMem ", AirCapabilities.instance.getCurrentVirtualMem());
        }));
        blocks.push(new TestBlock("getDeviceModel", function():void {
            trace("getDeviceModel ", AirCapabilities.instance.getDeviceModel());
        }));
        blocks.push(new TestBlock("getMachineName", function():void {
            trace("getMachineName ", AirCapabilities.instance.getMachineName());
        }));
        blocks.push(new TestBlock("getOSVersion", function():void {
            trace("getOSVersion ", AirCapabilities.instance.getOSVersion());
        }));
        blocks.push(new TestBlock("hasInstagramEnabled", function():void {
            trace("hasInstagramEnabled ", AirCapabilities.instance.hasInstagramEnabled());
        }));
        blocks.push(new TestBlock("hasSmsEnabled", function():void {
            trace("hasSmsEnabled ", AirCapabilities.instance.hasSmsEnabled());
        }));
        blocks.push(new TestBlock("hasTwitterEnabled", function():void {
            trace("hasTwitterEnabled ", AirCapabilities.instance.hasTwitterEnabled());
        }));
        blocks.push(new TestBlock("openURL", function():void {
            AirCapabilities.instance.openURL("http://freshplanet.com");
        }));
        blocks.push(new TestBlock("sendMsgWithSms", function():void {
            AirCapabilities.instance.sendMsgWithSms("Hello World", "1234567");
        }));



        /**
         * add ui to screen
         */

        var nextY:Number = indent;

        for each (var block:TestBlock in blocks) {

            _scrollableContainer.addChild(block);
            block.y = nextY;
            nextY +=  block.height + indent;
        }
    }
}
}
