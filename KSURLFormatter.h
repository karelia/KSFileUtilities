//
//  KSURLFormatter.h
//
//  Copyright (c) 2008-2012 Mike Abdullah and Karelia Software
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


#import <Foundation/Foundation.h>


@interface KSURLFormatter : NSFormatter
{
  @private
    BOOL        _useDisplayNameForFileURLs;
    NSString    *_defaultScheme;
    NSArray     *_allowedSchemes;
    NSString    *_fallbackTopLevelDomain;
    BOOL        _generateStrings;
}

#pragma mark Class Methods

// Uses the really basic settings to build a URL from the string.
/*"	Fix a URL-encoded string that may have some characters that makes NSURL barf.
 It basically re-encodes the string, but ignores escape characters + and %, and also #.
 Example bad characters:  smart quotes.  If you try to create NSURL URLWithString: and your string
 has smart quotes, the NSURL is nil!
 "*/
+ (NSURL *)URLFromString:(NSString *)string;

+ (BOOL)isValidEmailAddress:(NSString *)address;
+ (BOOL)isLikelyEmailAddress:(NSString *)address;   // much the same as above, but ignores some rarities


#pragma mark Managing Behavior

// Default is NO. If YES, -stringForObjectValue: will return -[NSFileManager displayName…] for file URLs
@property(nonatomic) BOOL useDisplayNameForFileURLs;

// If no scheme is recognisable from the string, this will be substituted. Default is http
@property(nonatomic, copy) NSString *defaultScheme;

// Default value is nil, which means any scheme is allowed. If a URL is entered that isn't in this list, the formatter substitutes in whatever it considers to be the best match, generally favouring those nearer the start of the array
// An empty array is not permitted
@property(nonatomic, copy) NSArray *allowedSchemes;

// If the URL's host does not have a top-level domain specified, and this is non-nil, it is substituted in. Default is "com"
@property(nonatomic, copy) NSString *fallbackTopLevelDomain;


#pragma mark Conversion

- (NSURL *)URLFromString:(NSString *)string;    // convenience
@property(nonatomic) BOOL generatesURLStrings;  // defaults to NO, so that NSURL objects are generated

// For optimum behaviour, KSURLFormatter can hand off to a value transformer for the basic string => URL transformation
// By default, KSEncodeURLString is used *if available* (i.e. you need to compile it into your app and link against WebKit, or provide your own of the same name)
// If you supply a custom transformer it must accept strings as input, and output URLs. It should return anything that can't be clearly interpreted as a full URL. e.g. @"example.com" should come back as nil for the formatter to handle
+ (NSValueTransformer *)encodeStringValueTransformer;
+ (void)setEncodeStringValueTransformer:(NSValueTransformer *)transformer;


@end
