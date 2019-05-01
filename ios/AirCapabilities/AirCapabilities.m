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
#import "AirCapabilities.h"
#import <mach/mach.h>
#import <sys/utsname.h>
#import <UIKit/UIApplication.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <StoreKit/SKStoreReviewController.h>
#import "HapticFeedback.h"

@implementation AirCapabilities

BOOL doLogging = NO;

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
    return AirCapabilities_FPANE_BOOLToFREObject(value);
}

DEFINE_ANE_FUNCTION(hasTwitter) {
    
    BOOL value = [TWTweetComposeViewController canSendTweet];
    
    if (!value) {
        
        NSArray* schemeArray = [NSArray arrayWithObjects:@"twitter:///post?message=Hello", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
        
        for (NSString* scheme in schemeArray) {
            
            value = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
            
            if (value)
                break;
        }
    }
    
    return AirCapabilities_FPANE_BOOLToFREObject(value);
}

DEFINE_ANE_FUNCTION(sendWithSms) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* message = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSString* recipientString = AirCapabilities_FPANE_FREObjectToNSString(argv[1]);
        
        if (message != nil) {
            
            MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
            viewController.body = message;
            
            if (recipientString != nil)
                viewController.recipients = [NSArray arrayWithObject:recipientString];
            
            viewController.messageComposeDelegate = controller;
            
            id delegate = [[UIApplication sharedApplication] delegate];
            [[[delegate window] rootViewController] presentViewController:viewController animated:YES completion:^{}];
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to send SMS : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(sendWithTwitter) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* message = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSString* urlEncodedMessage = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)message, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingISOLatin1);;
        
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
                
                // Build our schemes
                NSArray* schemes = [NSArray arrayWithObjects:@"twitter://", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
                NSMutableArray* fullSchemes = [[NSMutableArray alloc] init];
                for (NSString *scheme in schemes)
                    [fullSchemes addObject:[NSString stringWithFormat:@"%@/post?message=%@", scheme, urlEncodedMessage]];

                [controller openApplication:fullSchemes appStoreURL:nil];
            }
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured send Twitter message : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(redirectToRating) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* appId = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSString* url = nil;
        
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
            url = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", appId]; //@"518042655"
        else
            url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId]; //@"518042655"
        
        
        if (url != nil) {
            [controller openApplication:[NSArray arrayWithObject:url] appStoreURL:nil];
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to redirect to rating : " stringByAppendingString:exception.reason]];
    }
    return nil;
}


DEFINE_ANE_FUNCTION(getDeviceModel) {
    
    NSString* model = [[UIDevice currentDevice] model];
    FREObject retStr = AirCapabilities_FPANE_NSStringToFREObject(model);

    return retStr;
}

DEFINE_ANE_FUNCTION(getMachineName) {
    
	struct utsname systemInfo;
	uname(&systemInfo);
	return AirCapabilities_FPANE_NSStringToFREObject([NSString stringWithUTF8String:systemInfo.machine]);
}

DEFINE_ANE_FUNCTION(processReferralLink) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* url = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSURL* nsUrl = [NSURL URLWithString:url];
        [controller openReferralURL:nsUrl];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to process referral link : " stringByAppendingString:exception.reason]];
    }
    return NULL;
}


DEFINE_ANE_FUNCTION(redirectToPageId) {
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* pageId = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSString* schemeString = [NSString stringWithFormat:@"fb://profile/%@", pageId];
        NSURL* schemeUrl = [NSURL URLWithString:schemeString];
        
        if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
            schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", pageId]];
        
        [[UIApplication sharedApplication] openURL:schemeUrl];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to redirect to page id : " stringByAppendingString:exception.reason]];
    }
    return NULL;
}

DEFINE_ANE_FUNCTION(redirectToTwitterAccount) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* pageId = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSString* schemeString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", pageId];
        NSURL* schemeUrl = [NSURL URLWithString:schemeString];

        if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
            schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@", pageId]];
        
        [[UIApplication sharedApplication] openURL:schemeUrl];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to redirect Twitter account : " stringByAppendingString:exception.reason]];
    }
    return NULL;
}

DEFINE_ANE_FUNCTION(canPostPictureOnTwitter) {
    return AirCapabilities_FPANE_BOOLToFREObject([TWTweetComposeViewController canSendTweet]);
}

DEFINE_ANE_FUNCTION(getOSVersion) {
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return AirCapabilities_FPANE_NSStringToFREObject(systemVersion);
}

DEFINE_ANE_FUNCTION(postPictureOnTwitter) {
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* message = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
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
        else {
            return nil;
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
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to post picture on Twitter : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(openExternalApplication) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        uint32_t arr_len; // array length
        
        FREObject arr = argv[0];
        FREGetArrayLength(arr, &arr_len);
        NSMutableArray* schemes = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < arr_len; i++) {
            
            // Get element at current index
            FREObject element;
            FREGetArrayElementAt(arr, i, &element);
            
            // Convert to NSString and add it to schemes
            NSString* elem = AirCapabilities_FPANE_FREObjectToNSString(element);//[NSString stringWithUTF8String:(char*)elementStr];
            [schemes addObject:elem];
        }
        
        NSString *appStoreString = AirCapabilities_FPANE_FREObjectToNSString(argv[1]);
        NSURL* appStoreURL = [NSURL URLWithString:appStoreString];
        
        bool canOpenApplication = false;
        
        for (NSString* scheme in schemes)
            canOpenApplication = canOpenApplication || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
        
        [controller sendEvent:@"OPEN_URL" level:canOpenApplication ? @"APP": @"STORE"];
        [controller openApplication:schemes appStoreURL:appStoreURL];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to open external application : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesCanOpenURL) {
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString *urlString = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSURL *url = [NSURL URLWithString:urlString];
        
        BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
        return AirCapabilities_FPANE_BOOLToFREObject(canOpenURL);
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to check can open URL : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesOpenURL) {
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString *urlString = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        NSURL *url = [NSURL URLWithString:urlString];
        BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
        
        if (canOpenURL)
            [[UIApplication sharedApplication] openURL:url];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to open URL : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesSetLogging) {
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        doLogging = AirCapabilities_FPANE_FREObjectToBool(argv[0]);
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setLogging : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(traceLog) {
    
    if(!doLogging)
        return nil;
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSInteger logLevel = AirCapabilities_FPANE_FREObjectToInt(argv[0]);
        NSString *tag = AirCapabilities_FPANE_FREObjectToNSString(argv[1]);
        NSString *msg = AirCapabilities_FPANE_FREObjectToNSString(argv[2]);
        
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
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to traceLog : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(openModalAppStore) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* appStoreID = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        [controller openModalAppStore:appStoreID];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to open modal AppStore : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(hasInstagramEnabled) {
    
    BOOL value = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]];
    return AirCapabilities_FPANE_BOOLToFREObject(value);
}

DEFINE_ANE_FUNCTION(postPictureOnInstagram) {
    
    AirCapabilities* controller = GetAirCapabilitiesContextNativeData(context);
    
    if (!controller)
        return AirCapabilities_FPANE_CreateError(@"context's AirCapabilities is null", 0);
    
    @try {
        NSString* message = AirCapabilities_FPANE_FREObjectToNSString(argv[0]);
        
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
        
        
        NSInteger xPosition = AirCapabilities_FPANE_FREObjectToInt(argv[2]);
        NSInteger yPosition = AirCapabilities_FPANE_FREObjectToInt(argv[3]);
        NSInteger width = AirCapabilities_FPANE_FREObjectToInt(argv[4]);
        NSInteger height = AirCapabilities_FPANE_FREObjectToInt(argv[5]);
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
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to post picture on Instagram : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(getCurrentMem) {
    
    double bytes = [AirCapabilities currentMemUse];
    return AirCapabilities_FPANE_DoubleToFREObject(bytes);
}

DEFINE_ANE_FUNCTION(getCurrentVirtualMem) {
    
    double bytes = [AirCapabilities currentVirtualMemUse];
    return AirCapabilities_FPANE_DoubleToFREObject(bytes);
}

DEFINE_ANE_FUNCTION(canRequestReview) {

    BOOL value = NO;

    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,3,0}] && [SKStoreReviewController class])
        value = YES;

    return AirCapabilities_FPANE_BOOLToFREObject(value);
}

DEFINE_ANE_FUNCTION(requestReview) {

    [SKStoreReviewController requestReview];
    return nil;
}

DEFINE_ANE_FUNCTION(generateHapticFeedback) {
    NSInteger feedbackType = AirCapabilities_FPANE_FREObjectToInt(argv[0]);
    [HapticFeedback generateFeedback:feedbackType];
    return nil;
}

DEFINE_ANE_FUNCTION (getNativeScale) {
    NSNumber *scale = [NSNumber numberWithFloat:[[UIScreen mainScreen] nativeScale]];
    return AirCapabilities_FPANE_DoubleToFREObject([scale doubleValue]);
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
        { (const uint8_t*)"canOpenURL", NULL, &AirCapabilitiesCanOpenURL }, // these method names have conflicts with other libs
        { (const uint8_t*)"openURL", NULL, &AirCapabilitiesOpenURL },
        { (const uint8_t*)"setLogging", NULL, &AirCapabilitiesSetLogging },
        MAP_FUNCTION(traceLog, NULL),
        MAP_FUNCTION(openModalAppStore, NULL),
        MAP_FUNCTION(hasInstagramEnabled, NULL),
        MAP_FUNCTION(postPictureOnInstagram, NULL),
        MAP_FUNCTION(getCurrentMem, NULL),
        MAP_FUNCTION(getCurrentVirtualMem, NULL),
        MAP_FUNCTION(canRequestReview, NULL),
        MAP_FUNCTION(requestReview, NULL),
        MAP_FUNCTION(generateHapticFeedback, NULL),
        MAP_FUNCTION(getNativeScale, NULL)
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
