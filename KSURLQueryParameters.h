//
//  KSURLQueryParameters.h
//  KSFileUtilities
//
//  Created by Mike on 14/10/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSURLQueryParameters : NSObject <NSCopying>
{
  @private
    NSMutableString *_string;
}

#pragma mark Creating a KSURLQueryParameters object

/**
 Creates an empty object with no parameters.
 */
- init;

/**
 Creates a KSURLQueryParameters object from a query string
 
 Tolerates all forms of query except `nil`.
 */
- initWithPercentEncodedString:(NSString *)query __attribute((nonnull));

+ (instancetype)queryParametersWithPercentEncodedString:(NSString *)query;

/**
 @result `nil` if the url has no query component.
 */
+ (instancetype)queryParametersOfURL:(NSURL *)url;

- initWithDictionary:(NSDictionary *)dictionary __attribute((nonnull));

+ (instancetype)queryParametersWithDictionary:(NSDictionary *)dictionary __attribute((nonnull));


#pragma mark Retrieving Query and Parameters

/**
 Returns string representation, encoded ready to use as the query component of a URL.
 
 This is generally handy to pass straight into the `-setPercentEncodedQuery:`
 method of `NSURLComponents` or `KSURLComponents`.
 */
- (NSString *)percentEncodedQuery;

/**
 Forms a dictionary of the query parameters if they suit
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 Enumerates the parameters of the receiver.
 
 * Parameters consisting of only a key are report their `value` as `nil`
 * Parameters are reported in order
 * Duplicate parameters are correctly reported too
 
 Keys and values are both percent decoded.
 
 @param A block called for each parameter.
 */
- (void)enumerateParametersUsingBlock:(void (^)(NSString *key, NSString *value, BOOL *stop))block;


#pragma mark Adding and Removing Parameters

/**
 Adds a key and optional corresponding value to the end of the receiver.
 */
- (void)addParameter:(NSString *)key value:(NSString *)value __attribute((nonnull(1)));

/**
 Adds the contents of `dictionary` to the end of the receiver.
 
 NSDictionary promises no ordering, so the resulting parameters will be ordered
 in whatever fashion the dictionary chooses to vend out.
 */
- (void)addParametersFromDictionary:(NSDictionary *)dictionary;

/**
 Resets the receiver to have no parameters.
 */
- (void)removeAllParameters;


@end
