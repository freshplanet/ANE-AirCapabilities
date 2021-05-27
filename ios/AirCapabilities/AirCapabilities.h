/*
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
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
    #import <MessageUI/MFMessageComposeViewController.h>
    #import <StoreKit/StoreKit.h>
#endif
#import "FPANEUtils.h"

#if TARGET_OS_IPHONE
@interface AirCapabilities : NSObject<MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate> {
    FREContext _context;
    NSURL* _iTunesURL;
}
#else
@interface AirCapabilities : NSObject {
    FREContext _context;
    NSURL* _iTunesURL;
}
#endif
@end

void AirCapabilitiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirCapabilitiesContextFinalizer(FREContext ctx);
void AirCapabilitiesInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirCapabilitiesFinalizer(void *extData);
