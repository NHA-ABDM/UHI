//
//  CLPlacemarkExtensions.h
//  Pods
//
//  Created by Maurits van Beusekom on 07/06/2020.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (CLPlacemarkExtensions)
- (NSDictionary *)toPlacemarkDictionary;

- (NSDictionary *)toLocationDictionary;
@end
