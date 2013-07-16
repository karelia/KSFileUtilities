//
//  Created by Warren Dodge
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

// Normalization of URLs based on 
//  http://en.wikipedia.org/wiki/URL_normalization

// For file:// URLs, we don't strip off the index file name (e.g. index.html)

/*  Example of an URL containing all valid parts.
    http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    The "parameter" is very rarely used and not well supported.
 
    NSURL methods return the following:
    absoluteString: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1

    absoluteURL: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    baseURL: (null)
 
    fragment: anchor1
 
    host: www.karelia.com
 
    lastPathComponent: index.html
 
    parameterString: parameter1=arg1;parameter2=arg2
 
    password: password
 
    path: /sandvox/index.html
 
    pathComponents: ("/", sandvox, "index.html" )
 
    pathExtension: html
 
    port: 8888
 
    query: queryparm1=queryarg1&queryparm2=queryarg2
 
    relativePath: /sandvox/index.html
 
    relativeString: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    resourceSpecifier: //username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    scheme: http
 
    standardizedURL: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    user: username

*/


#import <Foundation/Foundation.h>


@interface NSURL (KSURLNormalization)

- (NSURL *)ks_normalizedURL;

@end


