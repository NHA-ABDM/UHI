//
//  GeocodingHandler.h
//  Pods
//
//  Created by Maurits van Beusekom on 07/06/2020.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GeocodingSuccess)(NSArray<CLPlacemark *> *);
typedef void (^GeocodingFailure)(NSString* errorCode, NSString* errorDescription);

@interface GeocodingHandler : NSObject

- (void) geocodeFromAddress: (NSString *)address
                     locale: (NSLocale *)locale
                    success: (_Nonnull GeocodingSuccess)successHandler
                    failure: (_Nonnull GeocodingFailure)failureHandler;

- (void) geocodeToAddress: (CLLocation *)location
                   locale: (NSLocale *)locale
                  success: (_Nonnull GeocodingSuccess)successHandler
                  failure: (_Nonnull GeocodingFailure)failureHandler;

@end

NS_ASSUME_NONNULL_END
