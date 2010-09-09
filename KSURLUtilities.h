//
//  NSURL+KSFileUtilities.h
//  Sandvox
//
//  Created by Mike on 09/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSURL (KSPathUtilities)

#pragma mark Host
- (NSURL *)ks_hostURL;
- (NSArray *)ks_domains;
- (BOOL)ks_hasNetworkLocation; // checks for a host with 2+ domains


#pragma mark Paths
+ (NSURL *)ks_URLWithPath:(NSString *)path relativeToURL:(NSURL *)baseURL isDirectory:(BOOL)isDirectory;
- (id)ks_initWithPath:(NSString *)path relativeToURL:(NSURL *)baseURL isDirectory:(BOOL)isDirectory;

+ (NSString *)ks_fileURLStringWithPath:(NSString *)path;

#if !(defined MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_6
// These methods are already defined on Snow Leopard
- (NSString *)ks_lastPathComponent;
- (NSString *)ks_pathExtension;
- (NSURL *)ks_URLByAppendingPathExtension:(NSString *)pathExtension;
- (NSURL *)ks_URLByDeletingLastPathComponent;
- (NSURL *)ks_URLByDeletingPathExtension;
#endif

- (BOOL)ks_hasDirectoryPath;
- (NSURL *)ks_URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory;

- (BOOL)ks_isSubpathOfURL:(NSURL *)aURL;

#pragma mark Queries
+ (NSURL *)ks_URLWithBaseURL:(NSURL *)baseURL parameters:(NSDictionary *)parameters;
- (id)ks_initWithBaseURL:(NSURL *)baseURL parameters:(NSDictionary *)parameters;

- (NSDictionary *)ks_queryDictionary;

+ (NSString *)ks_queryWithDictionary:(NSDictionary *)parameters;
+ (NSDictionary *)ks_dictionaryFromQuery:(NSString *)queryString;


#pragma mark RFC 1808
- (BOOL)ks_canBeDecomposed;


#pragma mark Comparison
- (BOOL)ks_isEqualToURL:(NSURL *)URL;   // For file: URLs, checks path equality
- (BOOL)ks_isEqualExceptFragmentToURL:(NSURL *)anotherURL;


#pragma mark Relative URLs
- (NSString *)ks_stringRelativeToURL:(NSURL *)URL;
- (NSURL *)ks_URLRelativeToURL:(NSURL *)URL;


@end


#pragma mark -


@interface NSString (KSURLUtilities)

// Cocoa equivalent of the full CoreFoundation API
- (NSString *)ks_stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding
                             charactersToLeaveUnescaped:(NSString *)unescapedCharacters
                          legalURLCharactersToBeEscaped:(NSString *)legalCharactersToEscape;

// For escaping anything where you want a / character left intact. But do NOT use on a full URL, because it will escape the & characters
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters;
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters escape:(NSString *)toEscape;

// For escaping a string that will go into a URL's query. Escapes : and / characters.
- (NSString *)ks_stringByAddingURLQueryPercentEscapes;
- (NSString *)ks_stringByReplacingURLQueryPercentEscapes;

- (NSString *)ks_URLDirectoryPath;

@end
