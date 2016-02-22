//
//  JBPhotoTagTools.h
//  SafetyPic
//
//  Created by Jeff Berman on 9/18/14.
//  Copyright (c) 2014 Jeff Berman. All rights reserved.
//
//  Methods for manipulating metadata tags in photos.

#import <Foundation/Foundation.h>
@import AssetsLibrary;
@import CoreLocation;


@interface JBPhotoTagTools : NSObject

// Return a copy of a photo minus the GPS metadata tags.
+ (NSData *)createCleanedPhotoFromAsset:(ALAsset *)asset;

// Return GPS coordinates from a photo asset. Returns a coordinate
// of (NAN, NAN) if no GPS tags are found.
+ (CLLocationCoordinate2D)gpsCoordinatesFromAsset:(ALAsset *)asset;

@end
