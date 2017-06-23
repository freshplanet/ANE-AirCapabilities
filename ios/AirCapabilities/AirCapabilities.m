//
//  AirCapabilities.m
//  AirCapabilities
//
//  Created by Thibaut Crenn on 05/06/12.
//  Copyright 2017 Freshplanet. All rights reserved.
//

#import "AirCapabilities.h"

#import <mach/mach.h>
#import <sys/utsname.h>
#import <UIKit/UIApplication.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <StoreKit/SKStoreReviewController.h>

@implementation AirCapabilities

- (id) initWithContext:(FREContext)extensionContext {
    
    if (self = [super init]) {
        
        _context = extensionContext;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void) sendLog:(NSString*)log {
    [self sendEvent:@"log" level:log];
}

- (void) sendEvent:(NSString*)code {
    [self sendEvent:code level:@""];
}

- (void) sendEvent:(NSString*)code level:(NSString*)level {
    FREDispatchStatusEventAsync(_context, (const uint8_t*)[code UTF8String], (const uint8_t*)[level UTF8String]);
}

- (void) messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self sendEvent:@"DISMISS" level:@"OK"];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    [[[delegate window] rootViewController] dismissViewControllerAnimated:NO completion:^{}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) openReferralURL:(NSURL*)referralURL {
    [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
}

- (NSURLRequest*) connection:(NSURLConnection*)connection willSendRequest:(NSURLRequest*)request redirectResponse:(NSURLResponse*)response {
    
    _iTunesURL = [response URL];
    
    if ([_iTunesURL.host hasSuffix:@"itunes.apple.com"]) {
        
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        return nil;
    }
    else {
        return request;
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    [[UIApplication sharedApplication] openURL:_iTunesURL];
}

- (void) openApplication:(NSArray*)schemes appStoreURL:(NSURL*)appStoreURL {
    
    BOOL canOpenApplication = NO;
    
    for (NSString* scheme in schemes) {
        
        canOpenApplication = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
        
        if (canOpenApplication) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            break;
        }
    }
        
    if (!canOpenApplication) {
        
        if (appStoreURL != nil)
            [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController*)viewController {
    
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
    [self sendEvent:@"CLOSED_MODAL_APP_STORE"];
}

- (void) openModalAppStore:(NSString*)appStoreID {
    
    if (!NSClassFromString(@"SKStoreProductViewController")) // if feature is not available
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appStoreID]]];
    else {
        
        SKStoreProductViewController* storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self;
        
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:storeController animated:YES completion:^{}];
        
        [storeController loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier: appStoreID }
                                   completionBlock:^(BOOL result, NSError *error) {
                                       
                                       if (!result) {
                                           
                                           [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appStoreID]]];
                                       }
                                   }];
    }
}

- (void) handleMemoryWarning:(NSNotification*)notification {
    
    NSString* memUse = [NSString stringWithFormat:@"%f", [AirCapabilities currentMemUse]];
    [self sendEvent:@"LOW_MEMORY_WARNING" level:memUse];
}

+ (double) currentMemUse {
    
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

+ (double) currentVirtualMemUse {
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
   
    if (kernReturn != KERN_SUCCESS)
        return LONG_MAX;
   
    return vm_page_size * vmStats.free_count;
}

@end

AirCapabilities* GetAirCapabilitiesContextNativeData(FREContext context) {
    
    CFTypeRef controller;
    FREGetContextNativeData(context, (void**)&controller);
    return (__bridge AirCapabilities*)controller;
}

DEFINE_ANE_FUNCTION(hasSMS) {
    
    BOOL value = [MFMessageComposeViewController canSendText];
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

DEFINE_ANE_FUNCTION(hasTwitter) {
    
    BOOL value = false;
    value = [TWTweetComposeViewController canSendTweet];
    
    if (!value) {
        
        NSArray* schemeArray = [NSArray arrayWithObjects:@"twitter:///post?message=Hello", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
        
        for (NSString* scheme in schemeArray) {
            
            value = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
            
            if (value)
                break;
        }
    }
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    return retBool;
}

DEFINE_ANE_FUNCTION(sendWithSms) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    NSString* message;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
        message = [NSString stringWithUTF8String:(char*) utf8_message];

    const uint8_t *utf8_recipient;
    NSString* recipientString = nil;
    if (FREGetObjectAsUTF8(argv[1], &string_length, &utf8_recipient) == FRE_OK)
        recipientString = [NSString stringWithUTF8String:(char*) utf8_recipient];

    if (message != nil) {
        
        MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
        viewController.body = message;
        
        if (recipientString != nil)
            viewController.recipients = [NSArray arrayWithObject:recipientString];
        
        viewController.messageComposeDelegate = controller;
        
        id delegate = [[UIApplication sharedApplication] delegate];
        [[[delegate window] rootViewController] presentViewController:viewController animated:YES completion:^{}];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(sendWithTwitter) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    NSString* message = nil;
    NSString* urlEncodedMessage = nil;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK) {
        
        message = [NSString stringWithUTF8String:(char*) utf8_message];
        urlEncodedMessage = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)message, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingISOLatin1);
    }
    
    if (message != nil) {
        
        if ([TWTweetComposeViewController canSendTweet]) {
            
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            
            // Set the initial tweet text. See the framework for additional properties that can be set.
            [tweetViewController setInitialText:message];            
            
            // Create the completion handler block.
            [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                NSString *output;
                
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        // The cancel button was tapped.
                        output = @"Tweet cancelled.";
                        break;
                    case TWTweetComposeViewControllerResultDone:
                        // The tweet was sent.
                        output = @"Tweet done.";
                        break;
                    default:
                        break;
                }
                
                id delegate = [[UIApplication sharedApplication] delegate];
                // Dismiss the tweet composition view controller.
                [[[delegate window] rootViewController] dismissViewControllerAnimated:YES completion:^{}];
            }];
            
            // Present the tweet composition view controller modally.
            id delegate = [[UIApplication sharedApplication] delegate];
            [[[delegate window] rootViewController] presentViewController:tweetViewController animated:YES completion:^{}];

        }
        else {
//            NSArray* schemeArray = [NSArray arrayWithObjects:@"twitter://", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
//            for (NSString* scheme in schemeArray) {
//                NSString *fullScheme = [NSString stringWithFormat:@"%@/post?message=%@", scheme, urlEncodedMessage];
//                NSURL *url = [NSURL URLWithString:fullScheme];
//                if ([[UIApplication sharedApplication] canOpenURL:url])
//                {
//                    [[UIApplication sharedApplication] openURL:url];
//                    break;
//                }
//            }
            // Build our schemes
            NSArray* schemes = [NSArray arrayWithObjects:@"twitter://", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
            NSMutableArray* fullSchemes = [[NSMutableArray alloc] init];
            for (NSString *scheme in schemes)
                [fullSchemes addObject:[NSString stringWithFormat:@"%@/post?message=%@", scheme, urlEncodedMessage]];

            [controller openApplication:fullSchemes appStoreURL:nil];
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(redirectToRating) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    const uint8_t *utf8_appId;
    
    NSString* url;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_appId) == FRE_OK) {
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
            url = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", [NSString stringWithUTF8String:(char*) utf8_appId]]; //@"518042655"
        else
            url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [NSString stringWithUTF8String:(char*) utf8_appId]]; //@"518042655"
    }

    if (url != nil) {
//        NSURL *urlScheme = [NSURL URLWithString:url];
//        if ([[UIApplication sharedApplication] canOpenURL:urlScheme])
//        {
//            [[UIApplication sharedApplication] openURL:urlScheme];
//        }
        [controller openApplication:[NSArray arrayWithObject:url] appStoreURL:nil];
    }
    
    return nil;
}


DEFINE_ANE_FUNCTION(getDeviceModel) {
    
    NSString* model = [[UIDevice currentDevice] model];
    FREObject retStr = FPANE_NSStringToFREObject(model);

    return retStr;
}

DEFINE_ANE_FUNCTION(getMachineName) {
    
	struct utsname systemInfo;
	uname(&systemInfo);
	const char *str = systemInfo.machine;
	FREObject retStr;
	FRENewObjectFromUTF8(strlen(str)+1, (const uint8_t*)str, &retStr);
	return retStr;
}

DEFINE_ANE_FUNCTION(processReferralLink) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    const uint8_t *utf8_itunesUrl;
    
    NSString* url;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_itunesUrl) == FRE_OK)
    {
        url = [NSString stringWithUTF8String:(char*) utf8_itunesUrl];
    }
    
    NSURL* nsUrl = [NSURL URLWithString:url];
    [controller openReferralURL:nsUrl];
    
    return NULL;
}


DEFINE_ANE_FUNCTION(redirectToPageId) {
    
    uint32_t string_length;
    const uint8_t *utf8_pageId;
    
    NSString* pageId;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_pageId) == FRE_OK)
        pageId = [NSString stringWithUTF8String:(char*) utf8_pageId];

    NSString* schemeString = [NSString stringWithFormat:@"fb://profile/%@", pageId];
    NSURL* schemeUrl = [NSURL URLWithString:schemeString];
    
    if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
        schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", pageId]];
    
    [[UIApplication sharedApplication] openURL:schemeUrl];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(redirectToTwitterAccount) {
    
    uint32_t string_length;
    const uint8_t *utf8_pageId;
    
    NSString* pageId;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_pageId) == FRE_OK)
        pageId = [NSString stringWithUTF8String:(char*) utf8_pageId];
    
    NSString* schemeString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", pageId];
    NSURL* schemeUrl = [NSURL URLWithString:schemeString];

    if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
        schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@", pageId]];
    
    [[UIApplication sharedApplication] openURL:schemeUrl];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(canPostPictureOnTwitter) {
    
    BOOL value = false;
    value = [TWTweetComposeViewController canSendTweet];
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

DEFINE_ANE_FUNCTION(getOSVersion) {
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    const uint8_t *utf8_message = (const uint8_t*)  [systemVersion UTF8String];
    uint32_t string_length = [systemVersion length];
    FREObject retString = nil;
    FRENewObjectFromUTF8(string_length, utf8_message, &retString);
    
    return retString;
}

DEFINE_ANE_FUNCTION(postPictureOnTwitter) {
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    
    NSString* message;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
        message = [NSString stringWithUTF8String:(char*) utf8_message];

    FREBitmapData bitmapData;
    UIImage *rewardImage;
    if (FREAcquireBitmapData(argv[1], &bitmapData) == FRE_OK) {
        
        // make data provider from buffer
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (bitmapData.width * bitmapData.height * 4), NULL);
        
        // set up for CGImage creation
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * bitmapData.width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo            bitmapInfo;
        
        if (bitmapData.hasAlpha) {
            
            if (bitmapData.isPremultiplied)
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            else
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
        else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(bitmapData.width, bitmapData.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
        // make UIImage from CGImage
        rewardImage = [UIImage imageWithCGImage:imageRef];
        
        FREReleaseBitmapData(argv[1]);
    }
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:message];
    [tweetViewController addImage:rewardImage];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        NSString *output;
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.
                output = @"Tweet cancelled.";
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                output = @"Tweet done.";
                break;
            default:
                break;
        }
        
        id delegate = [[UIApplication sharedApplication] delegate];
        // Dismiss the tweet composition view controller.
        [[[delegate window] rootViewController] dismissViewControllerAnimated:YES completion:^{}];
    }];
    
    // Present the tweet composition view controller modally.
    id delegate = [[UIApplication sharedApplication] delegate];
    [[[delegate window] rootViewController] presentViewController:tweetViewController animated:YES completion:^{}];

    return nil;
}

DEFINE_ANE_FUNCTION(openExternalApplication) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    uint32_t arr_len; // array length

    const uint8_t *utf8_appStoreURL;
    
    FREObject arr = argv[0];
    FREGetArrayLength(arr, &arr_len);
    NSMutableArray* schemes = [[NSMutableArray alloc] init];
    for (int32_t i = 0; i < arr_len; i++) {
        
        // Get element at current index
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // check if element is valid
        const uint8_t *elementStr;
        if (FREGetObjectAsUTF8(element, &string_length, &elementStr) != FRE_OK)
            continue;
        
        // Convert to NSString and add it to schemes
        NSString* elem = [NSString stringWithUTF8String:(char*)elementStr];
        [schemes addObject:elem];
    }
    
    NSURL* appStoreURL = nil;
    if (FREGetObjectAsUTF8(argv[1], &string_length, &utf8_appStoreURL) == FRE_OK)
        appStoreURL = [NSURL URLWithString:[NSString stringWithUTF8String:(char*) utf8_appStoreURL]];
    
    bool canOpenApplication = false;
    
    for (NSString* scheme in schemes)
        canOpenApplication = canOpenApplication || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
    
    [controller sendEvent:@"OPEN_URL" level:canOpenApplication ? @"APP": @"STORE"];
    [controller openApplication:schemes appStoreURL:appStoreURL];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesCanOpenURL) {
    
    uint32_t stringLength;
    
    const uint8_t *urlString;
    NSURL *url;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) == FRE_OK)
        url = [NSURL URLWithString:[NSString stringWithUTF8String:(const char*)urlString]];
    
    BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
    FREObject result;
    FRENewObjectFromBool(canOpenURL, &result);
    
    return result;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesOpenURL) {
    
    uint32_t stringLength;
    
    const uint8_t *urlString;
    NSURL *url;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) == FRE_OK)
        url = [NSURL URLWithString:[NSString stringWithUTF8String:(const char*)urlString]];
    
    BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
    
    if (canOpenURL)
        [[UIApplication sharedApplication] openURL:url];

    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesSetLogging) {
    
//    unsigned int loggingValue = 0;
//    if (FREGetObjectAsBool(argv[0], &loggingValue) == FRE_OK)
//        doLogging = (loggingValue != 0);
    
    return nil;
}

DEFINE_ANE_FUNCTION(traceLog) {
    
    int32_t logLevel;
    if (FREGetObjectAsInt32(argv[0], &logLevel) != FRE_OK) {
        
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }
    
    uint32_t strlen;
    const uint8_t *tag;
    const uint8_t *msg;

    if ((FREGetObjectAsUTF8(argv[1], &strlen, &tag) != FRE_OK) || (FREGetObjectAsUTF8(argv[2], &strlen, &msg) != FRE_OK)) {
        
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }
    
    NSString *formatString = nil;

    switch (logLevel) {
        case 2:
            formatString = @"[Verbose][%s]: %s";
            break;
        case 3:
            formatString = @"[Debug][%s]: %s";
            break;
        case 4:
            formatString = @"[Info][%s]: %s";
            break;
        case 5:
            formatString = @"[Warn][%s]: %s";
            break;
        case 6:
            formatString = @"[Error][%s]: %s";
            break;
    }
    
    NSLog(formatString, tag, msg);
    return nil;
}

DEFINE_ANE_FUNCTION(openModalAppStore) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t stringLength;
    
    const uint8_t *appStoreIdString;
    NSString* appStoreID;
    
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &appStoreIdString) == FRE_OK)
        appStoreID = [NSString stringWithUTF8String:(const char*)appStoreIdString];
    
    [controller openModalAppStore:appStoreID];
    
    return nil;
}

DEFINE_ANE_FUNCTION(hasInstagramEnabled) {
    
    BOOL value = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]];
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

DEFINE_ANE_FUNCTION(postPictureOnInstagram) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    
    NSString* message = nil;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
        message = [NSString stringWithUTF8String:(char*) utf8_message];
    
    FREBitmapData bitmapData;
    UIImage *rewardImage = nil;
    if (FREAcquireBitmapData(argv[1], &bitmapData) == FRE_OK) {
        
        // make data provider from buffer
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (bitmapData.width * bitmapData.height * 4), NULL);
        
        // set up for CGImage creation
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * bitmapData.width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo            bitmapInfo;
        
        if (bitmapData.hasAlpha) {
            
            if (bitmapData.isPremultiplied)
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            else
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
        else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(bitmapData.width, bitmapData.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
        // make UIImage from CGImage
        rewardImage = [UIImage imageWithCGImage:imageRef];
        
        FREReleaseBitmapData(argv[1]);
    }
    
    
    int32_t xPosition;
    if (FREGetObjectAsInt32(argv[2], &xPosition) != FRE_OK) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }

    int32_t yPosition;
    if (FREGetObjectAsInt32(argv[3], &yPosition) != FRE_OK) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }

    int32_t width;
    if (FREGetObjectAsInt32(argv[4], &width) != FRE_OK) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }

    int32_t height;
    if (FREGetObjectAsInt32(argv[5], &height) != FRE_OK) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }

    

    // saving it to disk
    NSData *imageData= UIImageJPEGRepresentation(rewardImage,0.0);
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/insta.igo"];
    [imageData writeToFile:imagePath atomically:YES];

    
    // creating the popover
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath:imagePath]];
    
    // setting specific param
    interactionController.UTI = @"com.instagram.exclusivegram";
    if (message != nil)
    {
        interactionController.annotation = [NSDictionary dictionaryWithObject:message forKey:@"InstagramCaption"]; // todo pass message
    }
    
    // Present the tweet composition view controller modally.
    id delegate = [[UIApplication sharedApplication] delegate];
    
    interactionController.delegate = delegate;
    
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];

    [interactionController presentOpenInMenuFromRect:CGRectMake(xPosition, yPosition, width, height) inView:rootView animated:YES];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getLocale) {
    
    //    NSLog(@"getLocal 1");
    //    NSLocale* locale = [NSLocale currentLocale];
    //    NSLog(@"getLocal 2 %@", locale);
    //    NSString* localeIdentifier = [locale localeIdentifier];
    //    NSLog(@"getLocal 3 %@", localeIdentifier);
    //
    //    const char* utf8String = NSLocaleIdentifier.UTF8String;
    //    unsigned long length = strlen(utf8String);
    //    NSLog(@"getLocal 4");
    //
    //    FREObject* retStr;
    //    FREResult result = FRENewObjectFromUTF8(length + 1, (uint8_t*) utf8String, retStr);
    //    NSLog(@"getLocal 5");
    //    
    //    return retStr;
    return nil;
}

DEFINE_ANE_FUNCTION(getCurrentMem) {
    
    double bytes = [AirCapabilities currentMemUse];
    return FPANE_DoubleToFREObject(bytes);
}

DEFINE_ANE_FUNCTION(getCurrentVirtualMem) {
    
    double bytes = [AirCapabilities currentVirtualMemUse];
    return FPANE_DoubleToFREObject(bytes);
}

DEFINE_ANE_FUNCTION(canRequestReview) {

    BOOL value = NO;

    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,3,0}] && [SKStoreReviewController class])
        value = YES;

    return FPANE_BOOLToFREObject(value);
}

DEFINE_ANE_FUNCTION(requestReview) {

    [SKStoreReviewController requestReview];
    return nil;
}

void AirCapabilitiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    AirCapabilities* controller = [[AirCapabilities alloc] initWithContext:ctx];
    FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(hasSMS, NULL),
        MAP_FUNCTION(hasTwitter, NULL),
        MAP_FUNCTION(sendWithSms, NULL),
        MAP_FUNCTION(sendWithTwitter, NULL),
        MAP_FUNCTION(redirectToRating, NULL),
        MAP_FUNCTION(getDeviceModel, NULL),
        MAP_FUNCTION(getMachineName, NULL),
        MAP_FUNCTION(processReferralLink, NULL),
        MAP_FUNCTION(redirectToPageId, NULL),
        MAP_FUNCTION(redirectToTwitterAccount, NULL),
        MAP_FUNCTION(canPostPictureOnTwitter, NULL),
        MAP_FUNCTION(postPictureOnTwitter, NULL),
        MAP_FUNCTION(openExternalApplication, NULL),
        MAP_FUNCTION(getOSVersion, NULL),
        { (const uint8_t*)"canOpenURL", NULL, &AirCapabilitiesCanOpenURL },
        { (const uint8_t*)"openURL", NULL, &AirCapabilitiesOpenURL },
        { (const uint8_t*)"setLogging", NULL, &AirCapabilitiesSetLogging },
        MAP_FUNCTION(traceLog, NULL),
        MAP_FUNCTION(openModalAppStore, NULL),
        MAP_FUNCTION(hasInstagramEnabled, NULL),
        MAP_FUNCTION(postPictureOnInstagram, NULL),
        MAP_FUNCTION(getLocale, NULL),
        MAP_FUNCTION(getCurrentMem, NULL),
        MAP_FUNCTION(getCurrentVirtualMem, NULL),
        MAP_FUNCTION(canRequestReview, NULL),
        MAP_FUNCTION(requestReview, NULL)
    };
    
    *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;
}

void AirCapabilitiesContextFinalizer(FREContext ctx) {
    
    CFTypeRef controller;
    FREGetContextNativeData(ctx, (void**)&controller);
    CFBridgingRelease(controller);
}

void AirCapabilitiesInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirCapabilitiesContextInitializer; 
    *ctxFinalizerToSet = &AirCapabilitiesContextFinalizer;
}

void AirCapabilitiesFinalizer(void *extData) {

}
