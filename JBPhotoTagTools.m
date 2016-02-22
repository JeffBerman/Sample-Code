//
//  JBPhotoTagTools.m
//  SafetyPic
//
//  Created by Jeff Berman on 9/18/14.
//  Copyright (c) 2014 Jeff Berman. All rights reserved.
//
//  Methods for manipulating metadata tags in photos.


#import "JBPhotoTagTools.h"
#import <ImageIO/ImageIO.h>

@interface JBPhotoTagTools ()
@end


@implementation JBPhotoTagTools

// Return a copy of a photo minus the GPS metadata tags.
+ (NSData *)createCleanedPhotoFromAsset:(ALAsset *)asset
{
    // Get the image's current metadata
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    NSDictionary *metadata = [assetRepresentation metadata];
    NSMutableDictionary *mutableMetadata = [metadata mutableCopy];
//    NSLog(@"Metadata: %@", metadata);
    
    // Remove the GPS tags
    [mutableMetadata removeObjectForKey:(__bridge NSString *)kCGImagePropertyGPSDictionary];
    
    // Create CGImageRef destination of image + metadata
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CGImageDestinationRef image = CGImageDestinationCreateWithData(data, (__bridge CFStringRef)[assetRepresentation UTI], 1, NULL);
    CGImageDestinationAddImage(image, [assetRepresentation fullResolutionImage], (__bridge CFDictionaryRef)mutableMetadata);
    BOOL success = CGImageDestinationFinalize(image);
    
    // Place image + cleaned metadata into an NSData object
    NSData *imageData = (__bridge NSData *)data;
    
    CFRelease(data);
    CFRelease(image);
    
    return  success ? imageData : nil;
}


// Return GPS coordinates from a photo asset. Returns a coordinate
// of (NAN, NAN) if no GPS tags are found.
+ (CLLocationCoordinate2D)gpsCoordinatesFromAsset:(ALAsset *)asset
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(NAN, NAN);
    
    if (asset) {
        // Get latitude and longitude from photo's metadata
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        NSDictionary *metadata = [assetRepresentation metadata];
        NSDictionary *gps = metadata[(__bridge NSString *)kCGImagePropertyGPSDictionary];
        
        if (metadata && gps) {
            CLLocationDegrees latitude = [gps[(__bridge NSString *)kCGImagePropertyGPSLatitude] doubleValue];
            CLLocationDegrees longitude = [gps[(__bridge NSString *)kCGImagePropertyGPSLongitude] doubleValue];
        
            // Set proper latitude value based on hemisphere
            NSString *latitudeRef = gps[(__bridge NSString *)kCGImagePropertyGPSLatitudeRef];
            if ([latitudeRef isEqualToString:@"S"]) {
                latitude = -latitude;
            }
            
            // Set proper longitude value based on hemisphere
            NSString *longitudeRef = gps[(__bridge NSString *)kCGImagePropertyGPSLongitudeRef];
            if ([longitudeRef isEqualToString:@"W"]) {
                longitude = -longitude;
            }
            
            coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        }
    }
    
    return coordinate;
}

@end
