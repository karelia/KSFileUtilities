//
//  KSURLFormatter.h
//
//  Created by Mike Abdullah
//  Copyright © 2008 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
