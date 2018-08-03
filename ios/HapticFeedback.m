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

#import "HapticFeedback.h"

@implementation HapticFeedback

+(void)generateFeedback:(FeedbackType)feedbackType{
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 10.0){
        return;
    }
    
    switch (feedbackType) {
        case FeedbackType_Selection:
            [self generateSelectionFeedback];
            break;
        case FeedbackType_Impact_Light:
            [self generateImpactFeedback:UIImpactFeedbackStyleLight];
            break;
        case FeedbackType_Impact_Medium:
            [self generateImpactFeedback:UIImpactFeedbackStyleMedium];
            break;
        case FeedbackType_Impact_Heavy:
            [self generateImpactFeedback:UIImpactFeedbackStyleHeavy];
            break;
        case FeedbackType_Notification_Success:
            [self generateNotificationFeedback:UINotificationFeedbackTypeSuccess];
            break;
        case FeedbackType_Notification_Warning:
            [self generateNotificationFeedback:UINotificationFeedbackTypeWarning];
            break;
        case FeedbackType_Notification_Error:
            [self generateNotificationFeedback:UINotificationFeedbackTypeError];
            break;
        default:
            // do nothing
            break;
    }
}

+(void)generateSelectionFeedback{
    UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
    [generator prepare];
    [generator selectionChanged];
    generator = nil;
}

+(void)generateImpactFeedback:(UIImpactFeedbackStyle)style{
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
    [generator prepare];
    [generator impactOccurred]; 
    generator = nil;
}

+(void)generateNotificationFeedback:(UINotificationFeedbackType)notificationType{
    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator prepare];
    [generator notificationOccurred:notificationType];
    generator = nil;
}

@end
