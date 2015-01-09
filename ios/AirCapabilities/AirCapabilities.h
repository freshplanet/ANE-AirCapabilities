//
//  AirCapabilities.h
//  AirCapabilities
//
//  Created by Thibaut Crenn on 05/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import "FlashRuntimeExtensions.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <Twitter/TWTweetComposeViewController.h>

@interface AirCapabilities : NSObject<MFMessageComposeViewControllerDelegate>
{
    NSURL* iTunesURL;
}

+(id) sharedInstance;

@property (nonatomic, retain) NSURL* iTunesURL;

@end




FREObject hasSMS(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject hasTwitter(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject sendSms(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject sendWithTwitter(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject redirectToRating(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getDeviceModel(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getMachineName(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject processReferralLink(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject redirectToPageId(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject redirectToTwitterAccount(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject canPostPictureOnTwitter(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject postPictureOnTwitter(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject openExternalApplication(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getOSVersion(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject AirCapabilitiesCanOpenURL(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject AirCapabilitiesOpenURL(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject AirCapabilitiesSetLogging(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject traceLog(FREContext, void* functionData, uint32_t argc, FREObject argv[]);



void AirCapabilitiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                       uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AirCapabilitiesContextFinalizer(FREContext ctx);

void AirCapabilitiesInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );
void AirCapabilitiesFinalizer(void *extData);