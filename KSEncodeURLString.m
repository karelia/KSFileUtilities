//
//  KSEncodeURLString
//
//  Created by Mike Abdullah
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

#import "KSEncodeURLString.h"

#import "NSURL+IFUnicodeURL.h"


@implementation KSEncodeURLString

+ (Class)transformedValueClass { return [NSURL class]; }

- (id)transformedValue:(id)value;
{
    static NSPasteboard *pboard;
    if (!pboard) pboard = [[NSPasteboard pasteboardWithUniqueName] retain];
    
    [pboard clearContents];
    [pboard writeObjects:@[value]];
    
    NSURL *result = [WebView URLFromPasteboard:pboard];
    
    // We were falling back to IFUnicodeURL if WebKit was unable to help. However, we found in case
    // https://karelia.fogbugz.com/f/cases/252798 this crashes on the string:
    // Complete summer class schedule! Fairytale ballet camps for ages 3-5, Intro to Ballet program for ages 5-9, Pre-Intensive for ages 6-
    // Why? Who knows!
#if FALLBACK_TO_IFUNICODE
    if (!result && [value isKindOfClass:[NSString class]] && [value length])
    {
        result = [NSURL URLWithUnicodeString:value];
    }
#endif
    
    return result;
}

@end
