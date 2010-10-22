//
//  KSURLUtilities.h
//
//  Copyright (c) 2007-2010, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
#else
#define ks_lastPathComponent lastPathComponent
#define ks_pathExtension pathExtension
#define ks_URLByAppendingPathExtension URLByAppendingPathExtension
#define ks_URLByDeletingLastPathComponent URLByDeletingLastPathComponent
#define ks_URLByDeletingPathExtension URLByDeletingPathExtension
#endif

- (BOOL)ks_hasDirectoryPath;
- (NSURL *)ks_URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory;

- (BOOL)ks_isSubpathOfURL:(NSURL *)aURL;


#pragma mark Queries

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
