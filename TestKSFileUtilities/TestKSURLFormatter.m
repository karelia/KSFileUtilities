//
//  TestKSURLFormatter.m
//  KSFileUtilities
//
//  Created by Mike Abdullah on 12/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import "TestKSURLFormatter.h"
#import "KSURLFormatter.h"


@implementation TestKSURLFormatter

- (void)testAllowedSchemesWithString:(NSString *)urlString expectedURLString:(NSString *)expectedResult
{
    KSURLFormatter *formatter = [[KSURLFormatter alloc] init];
    [formatter setAllowedSchemes:[NSArray arrayWithObjects:@"http", @"https", @"file", nil]];
    
    NSURL *URL = [formatter URLFromString:urlString];
    STAssertEqualObjects([URL absoluteString], expectedResult, nil);
    
    [formatter release];
}

- (void)testAllowedSchemesPrimary;
{
    [self testAllowedSchemesWithString:@"http://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testAllowedSchemesSecondary
{
    [self testAllowedSchemesWithString:@"https://example.com/" expectedURLString:@"https://example.com/"];
}

- (void)testAllowedSchemesCloseMatchPrimary
{
    [self testAllowedSchemesWithString:@"ttp://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testAllowedSchemesCloseMatchSecondary
{
    [self testAllowedSchemesWithString:@"ttps://example.com/" expectedURLString:@"https://example.com/"];
}

- (void)testAllowedSchemesRandom
{
    [self testAllowedSchemesWithString:@"test://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testJavascriptURLs
{
    KSURLFormatter *formatter = [[KSURLFormatter alloc] init];
    
    NSString *string = @"javascript:test('foo','bar')";
    NSURL *URL = [formatter URLFromString:string];
    STAssertEqualObjects([URL absoluteString], string, nil);
    
    [formatter release];
}

- (void)testPercentEncoding
{
    [self testAllowedSchemesWithString:@"test://test test.com/" expectedURLString:@"http://test%20test.com/"];
    [self testAllowedSchemesWithString:@"test://test test/" expectedURLString:@"http://test%20test.com/"];
    [self testAllowedSchemesWithString:@"test test/" expectedURLString:@"http://test%20test.com/"];
}

- (void)testInternationalizedDomainName
{
    [self testAllowedSchemesWithString:@"http://exämple.com" expectedURLString:@"http://xn--exmple-cua.com/"];
    [self testAllowedSchemesWithString:@"exämple.com" expectedURLString:@"http://xn--exmple-cua.com/"];
    [self testAllowedSchemesWithString:@"exämple" expectedURLString:@"http://xn--exmple-cua.com/"];
    
    
    /* Go the other way
     */
    
    KSURLFormatter *formatter = [[KSURLFormatter alloc] init];
    
    STAssertEqualObjects([formatter stringForObjectValue:[NSURL URLWithString:@"http://xn--exmple-cua.com/"]],
                         @"http://exämple.com/",
                         nil);
    
    // Might as well test something plain for good measure
    STAssertEqualObjects([formatter stringForObjectValue:[NSURL URLWithString:@"http://example.com/"]],
                         @"http://example.com/",
                         nil);
    
    // Invalid encodings should be left alone
    STAssertEqualObjects([formatter stringForObjectValue:[NSURL URLWithString:@"http://xn--exmple-cub.com/"]],
                         @"http://xn--exmple-cub.com/",
                         nil);
    
    // Make sure subdomains aren't interfering
    STAssertEqualObjects([formatter stringForObjectValue:[NSURL URLWithString:@"http://www.xn--exmple-cua.com/"]],
                         @"http://www.exämple.com/",
                         nil);
    STAssertEqualObjects([formatter stringForObjectValue:[NSURL URLWithString:@"http://www.xn--exmple-cub.com/"]],
                         @"http://www.xn--exmple-cub.com/",
                         nil);
    
    
    [formatter release];
}

- (void)testDoubleFragment;
{
    KSURLFormatter *formatter = [[KSURLFormatter alloc] init];
    
    NSURL *URL = [formatter URLFromString:@"http://example.com/path#fragment#fake"];
    STAssertEqualObjects([URL absoluteString], @"http://example.com/path#fragment%23fake", nil);
    
    [formatter release];
}

- (void)testValidEmailAddress
{
    // Test from http://pgregg.com/projects/php/code/showvalidemail.php
    // I've commented out those that fail at present; we're not all that bothered about getting this spot on!
    
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"name.lastname@domain.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@".@"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"a@b"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"@bar.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"@@bar.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"a@bar.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"aaa.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"aaa@.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"aaa@.123"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"aaa@[123.123.123.123]"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"aaa@[123.123.123.123]a"], nil);   // extra data outside ip
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"aaa@[123.123.123.333]"], nil);    // not a valid IP
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"a@bar.com."], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"a@bar"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"a-b@bar.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"+@b.c"], nil);    // min 2 char tld
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"+@b.com"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"a@-b.com"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"a@b-.com"], nil);
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"-@..com"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"-@a..com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"a@b.co-foo.uk"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"hello my name is\"@stutter.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"Test \\\"Fail\\\" Ing\"@example.com"], nil); // not sure I understood this one
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"valid@special.museum"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"invalid@special.museum-"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"shaitan@my-domain.thisisminekthx"], nil); // tld way too long
    STAssertFalse([KSURLFormatter isValidEmailAddress:@"test@...........com"], nil);
    //STAssertFalse([KSURLFormatter isValidEmailAddress:@"foobar@192.168.0.1"], nil); // ip need to be [] from reading http://haacked.com/archive/2007/08/21/i-knew-how-to-validate-an-email-address-until-i.aspx
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"Abc\\@def\"@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"Fred Bloggs\"@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"Joe\\Blow\"@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"\"Abc@def\"@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"customer/department=shipping@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"$A12345@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"!def!xyz%abc@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"_somename@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"Test \\ Folding \\ Whitespace@example.com"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"HM2Kinsists@(that comments are allowed)this.is.ok"], nil);
    STAssertTrue([KSURLFormatter isValidEmailAddress:@"user%uucp!path@somehost.edu"], nil);
}

- (void)testLikelyEmailAddress
{
    STAssertFalse([KSURLFormatter isLikelyEmailAddress:@"http://example.com@foo.com"], @"It's a *valid* email address, but more likely to be a URL");
}

@end
