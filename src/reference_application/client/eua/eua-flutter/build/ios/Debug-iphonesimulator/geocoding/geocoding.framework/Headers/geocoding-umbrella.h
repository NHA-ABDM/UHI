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

#import "CLPlacemarkExtensions.h"
#import "GeocodingHandler.h"
#import "GeocodingPlugin.h"

FOUNDATION_EXPORT double geocodingVersionNumber;
FOUNDATION_EXPORT const unsigned char geocodingVersionString[];

