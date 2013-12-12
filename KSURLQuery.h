//
//  KSURLQuery.h
//  KSFileUtilities
//
//  Created by Mike on 12/12/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSURLQuery : NSObject
{
  @private
    NSString    *_percentEncodedString;
}

#pragma mark Convenience
+ (NSString *)encodeParameters:(NSDictionary *)parameters;


#pragma mark

+ (instancetype)queryWithURL:(NSURL *)url;
+ (instancetype)queryWithPercentEncodedString:(NSString *)percentEncodedQuery;

@property(atomic, readonly, copy) NSString *percentEncodedString;

typedef NS_OPTIONS(NSUInteger, KSURLQueryParameterDecodingOptions) {
    KSURLQueryParameterDecodingPlusAsSpace = 1UL << 0,    // + characters are interpreted as spaces, rather than regular + symbols
};

- (NSDictionary *)parametersWithOptions:(KSURLQueryParameterDecodingOptions)options;
- (void)enumerateParametersWithOptions:(KSURLQueryParameterDecodingOptions)options usingBlock:(void (^)(NSString *key, NSString *value, BOOL *stop))block __attribute((nonnull(2)));

- (void)setParameters:(NSDictionary *)parameters;

@end
