//
//  AirCapabilities.h
//  AirCapabilities
//
//  Created by Thibaut Crenn on 05/06/12.
//  Copyright 2017 Freshplanet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <StoreKit/StoreKit.h>
#import "FPANEUtils.h"

@interface AirCapabilities : NSObject<MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate> {
    FREContext _context;
    NSURL* _iTunesURL;
}

@end

void AirCapabilitiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirCapabilitiesContextFinalizer(FREContext ctx);
void AirCapabilitiesInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirCapabilitiesFinalizer(void *extData);
