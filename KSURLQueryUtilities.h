//
//  KSURLQueryUtilities.h
//  Sandvox
//
//  Created by Mike Abdullah on 27/07/2012.
//  Copyright © 2012 Karelia Software
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
