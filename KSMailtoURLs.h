//
//  KSMailToURLs.h
//  Sandvox
//
//  Created by Mike on 26/07/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
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

@end
