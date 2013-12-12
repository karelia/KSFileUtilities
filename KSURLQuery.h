//
//  KSURLQuery.h
//  KSFileUtilities
//
//  Created by Mike on 12/12/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, KSURLQueryParameterDecodingOptions) {
    KSURLQueryParameterDecodingPlusAsSpace = 1UL << 0,    // + characters are interpreted as spaces, rather than regular + symbols
};


@interface KSURLQuery : NSObject
{
  @private
    NSString    *_percentEncodedString;
}

#pragma mark Convenience
+ (NSDictionary *)parametersFromURL:(NSURL *)url options:(KSURLQueryParameterDecodingOptions)options;
+ (NSString *)encodeParameters:(NSDictionary *)parameters;


#pragma mark Creating a KSURLQuery
+ (instancetype)queryWithURL:(NSURL *)url;
+ (instancetype)queryWithPercentEncodedString:(NSString *)percentEncodedQuery;


#pragma mark Decoding Parameters

/**
 Converts the query into a dictionary representation.
 
 For example:
 
 http://example.com?key=value&foo=bar
 
 can be interpreted as:
 
 @{ @"key" : @"value", @"foo" : @"bar" }
 
 Keys and values are percent decoded according to `options`.
 
 If you have a query which doesn't match `NSDictionary`'s design, drop down to
 the primitive `-enumerateParametersWithOptions:usingBlock:` method instead.
 
 @param options A mask that specifies options for parameter decoding.
 @return `nil` if query doesn't neatly fit an `NSDictionary` representation
 */
- (NSDictionary *)parametersWithOptions:(KSURLQueryParameterDecodingOptions)options;

/**
 Enumerates the receiver's parameters, handling cases where an NSDictionary representation doesn't suffice.
 
 * Parameters are reported in the order they appear in the URL
 * Keys and values are percent decoded for your convenience
 * Parameters without a value are reported as `nil`
 * Duplicate parameters are correctly reported too
 
 @param options A mask that specifies options for parameter decoding.
 @param block A block called for each parameter of the query.
 */
- (void)enumerateParametersWithOptions:(KSURLQueryParameterDecodingOptions)options usingBlock:(void (^)(NSString *key, NSString *value, BOOL *stop))block __attribute((nonnull(2)));


#pragma mark Encoding Parameters

/**
 Replaces any existing query by encoding the `parameters` dictionary.
 
 For example:
 
 @{ @"key" : @"value", @"foo" : @"bar" }
 
 can be represented as:
 
 http://example.com?key=value&foo=bar
 
 Keys and values are percent encoded.
 
 @param parameters A dictionary to encode, whose keys and values are all strings.
 */
- (void)setParameters:(NSDictionary *)parameters;

/**
 @result The encoded representation of the receiver.
 
 Generally you then pass the result of this method to `NSURLComponents.percentEncodedQuery`
 (or `KSURLComponents`) to build up a full URL.
 */
@property(atomic, readonly, copy) NSString *percentEncodedString;


@end
