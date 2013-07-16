//
//  KSMailToURLs.h
//  Sandvox
//
//  Created by Mike Abdullah on 26/07/2012.
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


extern NSString *KSURLMailtoScheme;
extern NSString *KSURLMailtoHeaderSubject;
extern NSString *KSURLMailtoHeaderBody;


@interface NSURL (KSMailToURLs)

// Handles plain addresses, plus: foo@example.com (Foo)
// May return nil if the address isn't valid
// KSURLMailtoHeaderSubject is a common key for the header lines dictionary
+ (NSURL *)ks_mailtoURLWithEmailAddress:(NSString *)address headerLines:(NSDictionary *)headers;

// Nil if its not a mailto URL or has no header lines
- (NSDictionary *)ks_mailHeaderLines;

@end
