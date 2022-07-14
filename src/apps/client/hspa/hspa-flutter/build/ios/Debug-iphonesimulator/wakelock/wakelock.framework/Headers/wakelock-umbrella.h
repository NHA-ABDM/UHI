#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "messages.h"
#import "UIApplication+idleTimerLock.h"
#import "WakelockPlugin.h"

FOUNDATION_EXPORT double wakelockVersionNumber;
FOUNDATION_EXPORT const unsigned char wakelockVersionString[];

