//
//  AirCapabilities.m
//  AirCapabilities
//
//  Created by Thibaut Crenn on 05/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AirCapabilities.h"
#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])


FREContext myAirCapaCtx = nil;
bool doLogging = false;

@implementation AirCapabilities

@synthesize iTunesURL;

+(id) sharedInstance {
    static id sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (myAirCapaCtx)
    {
        FREDispatchStatusEventAsync(myAirCapaCtx, (uint8_t*)[@"DISMISS" UTF8String], (uint8_t*)[@"OK" UTF8String]);
    }
    
    id delegate = [[UIApplication sharedApplication] delegate];
    [[[delegate window] rootViewController] dismissModalViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)openReferralURL:(NSURL *)referralURL
{
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    [con release];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    self.iTunesURL = [response URL];
    if( [self.iTunesURL.host hasSuffix:@"itunes.apple.com"])
    {
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        return nil;
    }
    else
    {
        return request;
    }
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] openURL:self.iTunesURL];
}

// Open an application (if installed on the device) or send the player to the appstore
//
// @param schemes : NSArray      - List of schemes (String) that the application accepts.  Examples : @"sms://", @"twit://".  You can find schemes in http://handleopenurl.com/
// @param appStoreURL : NSURL    - (optional) Link to the AppStore page for the Application for the player to download. URL can be generated via Apple's linkmaker (itunes.apple.com/linkmaker?)
- (void) openApplication:(NSArray*)schemes appStoreURL:(NSURL*)appStoreURL
{
    BOOL canOpenApplication;
    for (NSString* scheme in schemes)
    {
        canOpenApplication = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
        if (canOpenApplication)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            break;
        }
    }
        
    if (!canOpenApplication)
    {
        if (appStoreURL != nil)
        {
            [[UIApplication sharedApplication] openURL:appStoreURL];
        }
    }
}


@end


DEFINE_ANE_FUNCTION(hasSMS)
{
    BOOL value = [MFMessageComposeViewController canSendText];
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    return retBool;
}


DEFINE_ANE_FUNCTION(hasTwitter)
{
    BOOL value = false;
    value =[TWTweetComposeViewController canSendTweet];
    
    if (!value)
    {
        NSArray* schemeArray = [NSArray arrayWithObjects:@"twitter:///post?message=Hello", @"twitterrific://", @"twit://", @"tweetbot://", @"twinkle://", nil];
        
        for (NSString* scheme in schemeArray) {
            value = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
            if (value)
            {
                break;
            }
        }

    }
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    return retBool;
}

DEFINE_ANE_FUNCTION(sendSms)
{
    uint32_t string_length;
    const uint8_t *utf8_message;
    NSString* message;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*) utf8_message];
    }

    const uint8_t *utf8_recipient;
    NSString* recipientString = nil;
    if (FREGetObjectAsUTF8(argv[1], &string_length, &utf8_recipient) == FRE_OK)
    {
        recipientString = [NSString stringWithUTF8String:(char*) utf8_recipient];
    }

    
    
    if (message != nil)
    {
        MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
        viewController.body = message;
        
        if (recipientString != nil)
        {
            viewController.recipients = [NSArray arrayWithObject:recipientString];
        }
        
        viewController.messageComposeDelegate = [AirCapabilities sharedInstance];
        id delegate = [[UIApplication sharedApplication] delegate];
        [[[delegate window] rootViewController] presentModalViewController:viewController animated:YES];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(sendWithTwitter)
{
    uint32_t string_length;
    const uint8_t *utf8_message;
    NSString* message;
    NSString* urlEncodedMessage;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*) utf8_message];
        urlEncodedMessage = (NSString *)CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)message,	 NULL,	 (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingISOLatin1);
    }
    
    if (message != nil)
    {
        
        if ([TWTweetComposeViewController canSendTweet])
        {
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
                [[[delegate window] rootViewController] dismissModalViewControllerAnimated:YES];
            }];
            
            // Present the tweet composition view controller modally.
            id delegate = [[UIApplication sharedApplication] delegate];
            [[[delegate window] rootViewController] presentModalViewController:tweetViewController animated:YES];

        } else
        {
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
            for (NSString *scheme in schemes) {
                [fullSchemes addObject:[NSString stringWithFormat:@"%@/post?message=%@", scheme, urlEncodedMessage]];
            }
            [[AirCapabilities sharedInstance] openApplication:fullSchemes appStoreURL:nil];
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(redirectToRating)
{
    uint32_t string_length;
    const uint8_t *utf8_appId;
    
    NSString* url;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_appId) == FRE_OK)
    {
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
        {
            url = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", [NSString stringWithUTF8String:(char*) utf8_appId]]; //@"518042655"
        } else
        {
            url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [NSString stringWithUTF8String:(char*) utf8_appId]]; //@"518042655"

        }
    }

    if (url != nil)
    {
//        NSURL *urlScheme = [NSURL URLWithString:url];
//        if ([[UIApplication sharedApplication] canOpenURL:urlScheme])
//        {
//            [[UIApplication sharedApplication] openURL:urlScheme];
//        }
        [[AirCapabilities sharedInstance] openApplication:[NSArray arrayWithObject:url] appStoreURL:nil];
    }
    
    return nil;
}


DEFINE_ANE_FUNCTION(getDeviceModel)
{
    
    NSString *model = [[UIDevice currentDevice] model];
    
    const char *str = [model UTF8String];
    FREObject retStr;
	FRENewObjectFromUTF8(strlen(str)+1, (const uint8_t*)str, &retStr);

    return retStr;
}

DEFINE_ANE_FUNCTION(processReferralLink)
{
    
    uint32_t string_length;
    const uint8_t *utf8_itunesUrl;
    
    NSString* url;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_itunesUrl) == FRE_OK)
    {
        url = [NSString stringWithUTF8String:(char*) utf8_itunesUrl];
    }
    
    NSURL* nsUrl = [NSURL URLWithString:url];
    [[AirCapabilities sharedInstance] openReferralURL:nsUrl];
    
    return NULL;
}


DEFINE_ANE_FUNCTION(redirectToPageId)
{
    
    uint32_t string_length;
    const uint8_t *utf8_pageId;
    
    NSString* pageId;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_pageId) == FRE_OK)
    {
        pageId = [NSString stringWithUTF8String:(char*) utf8_pageId];
    }

    NSString* schemeString = [NSString stringWithFormat:@"fb://profile/%@", pageId];
    NSURL* schemeUrl = [NSURL URLWithString:schemeString];
    
    if(doLogging)
        NSLog(@"scheme: %@", schemeString);
    
    if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
    {
        if(doLogging)
            NSLog(@"%@", @"Cannot log");

        schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", pageId]];
    }
    
    [[UIApplication sharedApplication] openURL:schemeUrl];
    
    return NULL;
}


DEFINE_ANE_FUNCTION(redirectToTwitterAccount)
{
    
    uint32_t string_length;
    const uint8_t *utf8_pageId;
    
    NSString* pageId;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_pageId) == FRE_OK)
    {
        pageId = [NSString stringWithUTF8String:(char*) utf8_pageId];
    }
    
    NSString* schemeString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", pageId];
    NSURL* schemeUrl = [NSURL URLWithString:schemeString];
    if(doLogging)
        NSLog(@"scheme: %@", schemeString);

    if (![[UIApplication sharedApplication] canOpenURL:schemeUrl])
    {
        if(doLogging)
            NSLog(@"%@", @"Cannot log");

        schemeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@", pageId]];
    }
    
    [[UIApplication sharedApplication] openURL:schemeUrl];
    
    return NULL;
}


DEFINE_ANE_FUNCTION(canPostPictureOnTwitter)
{
    BOOL value = false;
    value = [TWTweetComposeViewController canSendTweet];
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    return retBool;
}


DEFINE_ANE_FUNCTION(getOSVersion)
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    const uint8_t *utf8_message = (const uint8_t *)  [systemVersion UTF8String];
    uint32_t string_length = [systemVersion length];
    FREObject retString = nil;
    FRENewObjectFromUTF8(string_length, utf8_message, &retString);
    return retString;
}


DEFINE_ANE_FUNCTION(postPictureOnTwitter)
{
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    
    NSString* message;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*) utf8_message];
    }

    FREBitmapData bitmapData;
    UIImage *rewardImage;
    if (FREAcquireBitmapData(argv[1], &bitmapData) == FRE_OK)
    {
        
        // make data provider from buffer
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (bitmapData.width * bitmapData.height * 4), NULL);
        
        // set up for CGImage creation
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * bitmapData.width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo            bitmapInfo;
        
        if( bitmapData.hasAlpha )
        {
            if( bitmapData.isPremultiplied )
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            else
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
        else
        {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(bitmapData.width, bitmapData.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
        // make UIImage from CGImage
        rewardImage = [UIImage imageWithCGImage:imageRef];
        
        FREReleaseBitmapData( argv[1] );
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
        [[[delegate window] rootViewController] dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    id delegate = [[UIApplication sharedApplication] delegate];
    [[[delegate window] rootViewController] presentModalViewController:tweetViewController animated:YES];

    return nil;
    
}


DEFINE_ANE_FUNCTION(openExternalApplication)
{
    uint32_t string_length;
    uint32_t arr_len; // array length

    const uint8_t *utf8_appStoreURL;
    
    FREObject arr = argv[0];
    FREGetArrayLength(arr, &arr_len);
    NSMutableArray* schemes = [[NSMutableArray alloc] init];
    for (int32_t i = 0; i < arr_len; i++)
    {
        // Get element at current index
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // check if element is valid
        const uint8_t *elementStr;
        if (FREGetObjectAsUTF8(element, &string_length, &elementStr) != FRE_OK)
        {
            continue;
        }
        
        // Convert to NSString and add it to schemes
        NSString* elem = [NSString stringWithUTF8String:(char*)elementStr];
        [schemes addObject:elem];
    }
    
    NSURL* appStoreURL = nil;
    if (FREGetObjectAsUTF8(argv[1], &string_length, &utf8_appStoreURL) == FRE_OK)
    {
        appStoreURL = [NSURL URLWithString:[NSString stringWithUTF8String:(char*) utf8_appStoreURL]];
    }

    
    bool canOpenApplication = false;
    
    for (NSString* scheme in schemes)
    {
        canOpenApplication = canOpenApplication || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
    }

    
    if (myAirCapaCtx)
    {
        FREDispatchStatusEventAsync(context, (uint8_t*)[@"OPEN_URL" UTF8String], canOpenApplication ? (uint8_t*)[@"APP" UTF8String] : (uint8_t*)[@"STORE" UTF8String]);
    }
    
    
    [[AirCapabilities sharedInstance] openApplication:schemes appStoreURL:appStoreURL];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesCanOpenURL)
{
    uint32_t stringLength;
    
    const uint8_t *urlString;
    NSURL *url;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) == FRE_OK)
    {
        url = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)urlString]];
    }
    
    BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
    FREObject result;
    FRENewObjectFromBool(canOpenURL, &result);
    return result;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesOpenURL)
{
    uint32_t stringLength;
    
    const uint8_t *urlString;
    NSURL *url;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) == FRE_OK)
    {
        url = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)urlString]];
    }
    
    BOOL canOpenURL = url ? [[UIApplication sharedApplication] canOpenURL:url] : NO;
    
    if (canOpenURL)
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirCapabilitiesSetLogging)
{
    unsigned int loggingValue = 0;
    if (FREGetObjectAsBool(argv[0], &loggingValue) == FRE_OK)
        doLogging = (loggingValue != 0);
    
    return nil;
}

DEFINE_ANE_FUNCTION(traceLog)
{
    int32_t logLevel;
    if(FREGetObjectAsInt32(argv[0], &logLevel) != FRE_OK) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }
    
    uint32_t strlen;
    const uint8_t *tag;
    const uint8_t *msg;

    if((FREGetObjectAsUTF8(argv[1], &strlen, &tag) != FRE_OK) || (FREGetObjectAsUTF8(argv[2], &strlen, &msg) != FRE_OK)) {
        NSLog(@"[AirCapabilities] Error trying to call traceLog from flash");
        return nil;
    }
    
    NSString *formatString;

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


// AirBgMusicContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirCapabilitiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                  uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 17;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    func[0].name = (const uint8_t*) "hasSMS";
    func[0].functionData = NULL;
    func[0].function = &hasSMS;
    
    func[1].name = (const uint8_t*) "hasTwitter";
    func[1].functionData = NULL;
    func[1].function = &hasTwitter;

    func[2].name = (const uint8_t*) "sendWithSms";
    func[2].functionData = NULL;
    func[2].function = &sendSms;

    func[3].name = (const uint8_t*) "sendWithTwitter";
    func[3].functionData = NULL;
    func[3].function = &sendWithTwitter;

    func[4].name = (const uint8_t*) "redirectToRating";
    func[4].functionData = NULL;
    func[4].function = &redirectToRating;

    func[5].name = (const uint8_t*) "getDeviceModel";
    func[5].functionData = NULL;
    func[5].function = &getDeviceModel;

    func[6].name = (const uint8_t*) "processReferralLink";
    func[6].functionData = NULL;
    func[6].function = &processReferralLink;

    func[7].name = (const uint8_t*) "redirectToPageId";
    func[7].functionData = NULL;
    func[7].function = &redirectToPageId;
    
    
    func[8].name = (const uint8_t*) "redirectToTwitterAccount";
    func[8].functionData = NULL;
    func[8].function = &redirectToTwitterAccount;

    
    func[9].name = (const uint8_t*) "canPostPictureOnTwitter";
    func[9].functionData = NULL;
    func[9].function = &canPostPictureOnTwitter;

    func[10].name = (const uint8_t*) "postPictureOnTwitter";
    func[10].functionData = NULL;
    func[10].function = &postPictureOnTwitter;
    
    func[11].name = (const uint8_t*) "openExternalApplication";
    func[11].functionData = NULL;
    func[11].function = &openExternalApplication;

    func[12].name = (const uint8_t*) "getOSVersion";
    func[12].functionData = NULL;
    func[12].function = &getOSVersion;
    
    func[13].name = (const uint8_t*) "canOpenURL";
    func[13].functionData = NULL;
    func[13].function = &AirCapabilitiesCanOpenURL;
    
    func[14].name = (const uint8_t*) "openURL";
    func[14].functionData = NULL;
    func[14].function = &AirCapabilitiesOpenURL;
    
    func[15].name = (const uint8_t*) "setLogging";
    func[15].functionData = NULL;
    func[15].function = &AirCapabilitiesSetLogging;
    
    func[16].name = (const uint8_t*) "traceLog";
    func[16].functionData = NULL;
    func[16].function = &traceLog;
    
    *functionsToSet = func;
    
    myAirCapaCtx = ctx;
}

// AirBgMusicContextFinalizer()
//
// Set when the context extension is created.
void AirCapabilitiesContextFinalizer(FREContext ctx) {}



// AirBgMusicInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void AirCapabilitiesInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirCapabilitiesContextInitializer; 
    *ctxFinalizerToSet = &AirCapabilitiesContextFinalizer;
}

void AirCapabilitiesFinalizer(void *extData) { }