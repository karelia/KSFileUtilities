//
//  KSURLFormatter.h
//
//  Copyright (c) 2008-2011, Mike Abdullah and Karelia Software
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
    NSString    *_fallbackTopLevelDomain;
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


#pragma mark Managing Behavior

// Default is NO. If YES, -stringForObjectValue: will return -[NSFileManager displayName…] for file URLs
@property(nonatomic) BOOL useDisplayNameForFileURLs;

// If the URL's host does not have a top-level domain specified, and this is non-nil, it is substituted in. Defaults is "com"
@property(nonatomic, copy) NSString *fallbackTopLevelDomain;


#pragma mark Conversion
- (NSURL *)URLFromString:(NSString *)string;    // convenience

@end
