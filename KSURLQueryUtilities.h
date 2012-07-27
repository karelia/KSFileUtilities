//
//  KSURLQueryUtilities.h
//  Sandvox
//
//  Created by Mike on 27/07/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (KSURLQueryUtilities)

// It's common to use the query part of a URL for a dictionary-like series of parameters. This method will decode that for you, including handling strings which were escaped to fit the scheme
- (NSDictionary *)ks_queryParameters;

// To do the reverse, construct a dictonary for the query and pass into either of these methods. You can base the result off of an existing URL, or specify all the components.
- (NSURL *)ks_URLWithQueryParameters:(NSDictionary *)parameters;
+ (NSURL *)ks_URLWithScheme:(NSString *)scheme
                       host:(NSString *)host
                       path:(NSString *)path
            queryParameters:(NSDictionary *)parameters;

// Primitive methods for if you need tighter control over handling query dictionaries
+ (NSString *)ks_queryWithParameters:(NSDictionary *)parameters;
+ (NSDictionary *)ks_parametersOfQuery:(NSString *)queryString;

@end


@interface NSString (KSURLQueryUtilities)

// Follows RFC2396, section 3.4
- (NSString *)ks_stringByAddingQueryComponentPercentEscapes;
- (NSString *)ks_stringByReplacingQueryComponentPercentEscapes;

@end
