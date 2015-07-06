
#import <XCTest/XCTest.h>
#import "KSURLNormalization.m"


@interface TestKSURLNormalization : XCTestCase
@end


@implementation TestKSURLNormalization

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)test_ks_URLByNormalizingURL
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox/page.html;parameter1=arg1;parameter2=arg2?queryparm1=%aa%bb%cc%dd&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.KARELIA.com///sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"HTTPS://username:password@www.karelia.com:443/sandvox///default.htm;parameter1=arg1;parameter2=arg2?queryparm1=%11%22%33%44&queryparm2=queryarg2#anchor1"];
    NSURL *in4 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *in5 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=%aa%bb%cc%dd&queryparm2=queryarg2"];
    NSURL *in6 = [NSURL URLWithString:@"http://username:password@WWW.karelia.COM:8888/level1/level2/level3/../..//;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in7 = [NSURL URLWithString:@""];
    NSURL *in8 = [NSURL URLWithString:@"mailto:test@example.com"];
    NSURL *in9 = [NSURL URLWithString:@"http://web.mac.com/sactobob/BobsPlace/Garys_Big_6-Oh%21.ht#0"];
    NSURL *in10 = [NSURL URLWithString:@"http://web.mac.com/sactobob/BobsPlace/Garys_Big_6-Oh%21#0"];
    NSURL *in11 = [NSURL URLWithString:@"http://www.karelia.com"];
    NSURL *in12 = [NSURL URLWithString:@"http://www.karelia.com/#"];
    NSURL *in13 = [NSURL URLWithString:@"http://www.karelia.com/index.html#"];
    NSURL *in14 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in15 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2bone%3dtwo/index.html"];
    NSURL *in16 = [NSURL URLWithString:@"http://www.karelia.com/%5bobjectivec%5d/index.html"];
    NSURL *in17 = [NSURL URLWithString:@"http://www.karelia.com/whee!/index.html"];
    NSURL *in18 = [NSURL URLWithString:@"http://www.karelia.com/whee%21/index.html"];
	NSURL *in19 = [NSURL URLWithString:@"file:///Users/foo/Desktop/index.html"];
	NSURL *in20 = [NSURL URLWithString:@"file://localhost/Users/foo/Desktop/index.html"];
    
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/page.html;parameter1=arg1;parameter2=arg2?queryparm1=%AA%BB%CC%DD&queryparm2=queryarg2"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can3 = [NSURL URLWithString:@"https://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=%11%22%33%44&queryparm2=queryarg2"];
    NSURL *can4 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can5 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=%AA%BB%CC%DD&queryparm2=queryarg2"];
    NSURL *can6 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can7 = [NSURL URLWithString:@""];
    NSURL *can8 = [NSURL URLWithString:@"mailto:test@example.com"];
    NSURL *can9 = [NSURL URLWithString:@"http://web.mac.com/sactobob/BobsPlace/Garys_Big_6-Oh!.ht"];
    NSURL *can10 = [NSURL URLWithString:@"http://web.mac.com/sactobob/BobsPlace/Garys_Big_6-Oh!/"];
    NSURL *can11 = [NSURL URLWithString:@"http://www.karelia.com/"];
    NSURL *can12 = [NSURL URLWithString:@"http://www.karelia.com/"];
    NSURL *can13 = [NSURL URLWithString:@"http://www.karelia.com/"];
    NSURL *can14 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can15 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2Bone%3Dtwo/"];
    NSURL *can16 = [NSURL URLWithString:@"http://www.karelia.com/%5Bobjectivec%5D/"];
    NSURL *can17 = [NSURL URLWithString:@"http://www.karelia.com/whee!/"];
    NSURL *can18 = [NSURL URLWithString:@"http://www.karelia.com/whee!/"];
	NSURL *can19 = [NSURL URLWithString:@"file:///Users/foo/Desktop/index.html"];
	NSURL *can20 = [NSURL URLWithString:@"file://localhost/Users/foo/Desktop/index.html"];

    NSURL *out1 = [in1 ks_normalizedURL];
    NSURL *out2 = [in2 ks_normalizedURL];
    NSURL *out3 = [in3 ks_normalizedURL];
    NSURL *out4 = [in4 ks_normalizedURL];
    NSURL *out5 = [in5 ks_normalizedURL];
    NSURL *out6 = [in6 ks_normalizedURL];
    NSURL *out7 = [in7 ks_normalizedURL];
    NSURL *out8 = [in8 ks_normalizedURL];
    NSURL *out9 = [in9 ks_normalizedURL];
    NSURL *out10 = [in10 ks_normalizedURL];
    NSURL *out11 = [in11 ks_normalizedURL];
    NSURL *out12 = [in12 ks_normalizedURL];
    NSURL *out13 = [in13 ks_normalizedURL];
    NSURL *out14 = [in14 ks_normalizedURL];
    NSURL *out15 = [in15 ks_normalizedURL];
    NSURL *out16 = [in16 ks_normalizedURL];
    NSURL *out17 = [in17 ks_normalizedURL];
    NSURL *out18 = [in18 ks_normalizedURL];
    NSURL *out19 = [in19 ks_normalizedURL];
    NSURL *out20 = [in20 ks_normalizedURL];
    
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
    XCTAssertTrue([[out6 absoluteString] isEqualToString:[can6 absoluteString]], @"out6 failed");
    XCTAssertTrue([[out7 absoluteString] isEqualToString:[can7 absoluteString]], @"out7 failed");
    XCTAssertTrue([[out8 absoluteString] isEqualToString:[can8 absoluteString]], @"out8 failed");
    XCTAssertTrue([[out9 absoluteString] isEqualToString:[can9 absoluteString]], @"out9 failed");
    XCTAssertTrue([[out10 absoluteString] isEqualToString:[can10 absoluteString]], @"out10 failed");
    XCTAssertTrue([[out11 absoluteString] isEqualToString:[can11 absoluteString]], @"out11 failed");
    XCTAssertTrue([[out12 absoluteString] isEqualToString:[can12 absoluteString]], @"out12 failed");
    XCTAssertTrue([[out13 absoluteString] isEqualToString:[can13 absoluteString]], @"out13 failed");
    XCTAssertTrue([[out14 absoluteString] isEqualToString:[can14 absoluteString]], @"out14 failed");
    XCTAssertTrue([[out15 absoluteString] isEqualToString:[can15 absoluteString]], @"out15 failed");
    XCTAssertTrue([[out16 absoluteString] isEqualToString:[can16 absoluteString]], @"out16 failed");
    XCTAssertTrue([[out17 absoluteString] isEqualToString:[can17 absoluteString]], @"out17 failed");
    XCTAssertTrue([[out18 absoluteString] isEqualToString:[can18 absoluteString]], @"out18 failed");
    XCTAssertTrue([[out19 absoluteString] isEqualToString:[can19 absoluteString]], @"out19 failed");
    XCTAssertTrue([[out20 absoluteString] isEqualToString:[can20 absoluteString]], @"out20 failed");
}


- (void)test_ks_ReplacementRangeOfURLPart
{
    NSURL *theWorks = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];

    NSRange rScheme          = [theWorks ks_replacementRangeOfURLPart:ks_URLPartScheme];
    NSRange rUserAndPassword = [theWorks ks_replacementRangeOfURLPart:ks_URLPartUserAndPassword];
    NSRange rHost            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartHost];
    NSRange rPort            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartPort];
    NSRange rPath            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartPath];
    NSRange rParameterString = [theWorks ks_replacementRangeOfURLPart:ks_URLPartParameterString];
    NSRange rQuery           = [theWorks ks_replacementRangeOfURLPart:ks_URLPartQuery];
    NSRange rFragment        = [theWorks ks_replacementRangeOfURLPart:ks_URLPartFragment];
//                                                                                                    1         1         1         1         1         1
//0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5    
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSRange ckrScheme          = (NSRange){0,4};
    NSRange ckrUserAndPassword = (NSRange){7,18};
    NSRange ckrHost            = (NSRange){25,15};
    NSRange ckrPort            = (NSRange){40,5};
    NSRange ckrPath            = (NSRange){45,19};
    NSRange ckrParameterString = (NSRange){64,32};
    NSRange ckrQuery           = (NSRange){96,42};
    NSRange ckrFragment        = (NSRange){138,8};

    XCTAssertTrue(rScheme.location == ckrScheme.location && rScheme.length == ckrScheme.length, @"rScheme failed.");
    XCTAssertTrue(rUserAndPassword.location == ckrUserAndPassword.location && rUserAndPassword.length == ckrUserAndPassword.length, @"rUserAndPassword failed.");
    XCTAssertTrue(rHost.location == ckrHost.location && rHost.length == ckrHost.length, @"rHost failed.");
    XCTAssertTrue(rPort.location == ckrPort.location && rPort.length == ckrPort.length, @"rPort failed.");
    XCTAssertTrue(rPath.location == ckrPath.location && rPath.length == ckrPath.length, @"rPath failed.");
    XCTAssertTrue(rParameterString.location == ckrParameterString.location && rParameterString.length == ckrParameterString.length, @"rParameterString failed.");
    XCTAssertTrue(rQuery.location == ckrQuery.location && rQuery.length == ckrQuery.length, @"rQuery failed.");
    XCTAssertTrue(rFragment.location == ckrFragment.location && rFragment.length == ckrFragment.length, @"rFragment failed.");
    
    
    NSURL *empty = [NSURL URLWithString:@""];
    NSRange e_rScheme          = [empty ks_replacementRangeOfURLPart:ks_URLPartScheme];
    NSRange e_rUserAndPassword = [empty ks_replacementRangeOfURLPart:ks_URLPartUserAndPassword];
    NSRange e_rHost            = [empty ks_replacementRangeOfURLPart:ks_URLPartHost];
    NSRange e_rPort            = [empty ks_replacementRangeOfURLPart:ks_URLPartPort];
    NSRange e_rPath            = [empty ks_replacementRangeOfURLPart:ks_URLPartPath];
    NSRange e_rParameterString = [empty ks_replacementRangeOfURLPart:ks_URLPartParameterString];
    NSRange e_rQuery           = [empty ks_replacementRangeOfURLPart:ks_URLPartQuery];
    NSRange e_rFragment        = [empty ks_replacementRangeOfURLPart:ks_URLPartFragment];

    NSRange e_ckrScheme          = (NSRange){0,0};
    NSRange e_ckrUserAndPassword = (NSRange){0,0};
    NSRange e_ckrHost            = (NSRange){0,0};
    NSRange e_ckrPort            = (NSRange){0,0};
    NSRange e_ckrPath            = (NSRange){0,0};
    NSRange e_ckrParameterString = (NSRange){0,0};
    NSRange e_ckrQuery           = (NSRange){0,0};
    NSRange e_ckrFragment        = (NSRange){0,0};
    
    XCTAssertTrue(e_rScheme.location == e_ckrScheme.location && e_rScheme.length == e_ckrScheme.length, @"e_rScheme failed.");
    XCTAssertTrue(e_rUserAndPassword.location == e_ckrUserAndPassword.location && e_rUserAndPassword.length == e_ckrUserAndPassword.length, @"e_rUserAndPassword failed.");
    XCTAssertTrue(e_rHost.location == e_ckrHost.location && e_rHost.length == e_ckrHost.length, @"e_rHost failed.");
    XCTAssertTrue(e_rPort.location == e_ckrPort.location && e_rPort.length == e_ckrPort.length, @"e_rPort failed.");
    XCTAssertTrue(e_rPath.location == e_ckrPath.location && e_rPath.length == e_ckrPath.length, @"e_rPath failed.");
    XCTAssertTrue(e_rParameterString.location == e_ckrParameterString.location && e_rParameterString.length == e_ckrParameterString.length, @"e_rParameterString failed.");
    XCTAssertTrue(e_rQuery.location == e_ckrQuery.location && e_rQuery.length == e_ckrQuery.length, @"e_rQuery failed.");
    XCTAssertTrue(e_rFragment.location == e_ckrFragment.location && e_rFragment.length == e_ckrFragment.length, @"e_rFragment failed.");
}


- (void)test_ks_URLByLowercasingSchemeAndHost
{
    NSURL *in1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in2 = [NSURL URLWithString:@"HTTP://www.karelia.com/index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://WWW.KARELIA.COM/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"HTTP://WWW.KARELIA.COM/index.html"];
    NSURL *in5 = [NSURL URLWithString:@"HttP://wWW.KAReliA.cOM/index.html"];
    NSURL *in6 = [NSURL URLWithString:@""];
    
    NSURL *canonical = [NSURL URLWithString:@"http://www.karelia.com/index.html"];

    XCTAssertTrue([[[in1 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in1 failed");
    XCTAssertTrue([[[in2 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in2 failed");
    XCTAssertTrue([[[in3 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in3 failed");
    XCTAssertTrue([[[in4 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in4 failed");
    XCTAssertTrue([[[in5 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in5 failed");

    XCTAssertTrue([[[in6 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:@""], @"in6 failed");
}


- (void)test_ks_URLByUppercasingEscapes
{
    NSURL *in1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2bone%3dtwo/index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/%5bobjectivec%5d/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/index%aa%bb%cc/index.html"];
    NSURL *in5 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];
    NSURL *in6 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2Bone%3Dtwo/index.html"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/%5Bobjectivec%5D/index.html"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];
    NSURL *can5 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];
    NSURL *can6 = [NSURL URLWithString:@""];

    NSURL *out1 = [in1 ks_URLByUppercasingEscapes];
    NSURL *out2 = [in2 ks_URLByUppercasingEscapes];
    NSURL *out3 = [in3 ks_URLByUppercasingEscapes];
    NSURL *out4 = [in4 ks_URLByUppercasingEscapes];
    NSURL *out5 = [in5 ks_URLByUppercasingEscapes];
    NSURL *out6 = [in6 ks_URLByUppercasingEscapes];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
    XCTAssertTrue([[out6 absoluteString] isEqualToString:[can6 absoluteString]], @"out6 failed");
}


- (void)test_ks_URLByUnescapingUnreservedCharactersInPath
{
    NSURL *in1 =  [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 =  [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2bone%3dtwo/index.html"];
    NSURL *in3 =  [NSURL URLWithString:@"http://www.karelia.com/%5bobjectivec%5d/index.html"];
    NSURL *in4 =  [NSURL URLWithString:@"http://www.karelia.com/whee!/index.html"];
    NSURL *in5 =  [NSURL URLWithString:@"http://www.karelia.com/whee%21/index.html"];
    NSURL *in6 =  [NSURL URLWithString:@"http://www.karelia.com/#objectivec%23/index.html"];

    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2bone%3dtwo/index.html"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/%5bobjectivec%5d/index.html"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/whee!/index.html"];
    NSURL *can5 = [NSURL URLWithString:@"http://www.karelia.com/whee!/index.html"];
    NSURL *can6 = [NSURL URLWithString:@"http://www.karelia.com/#objectivec%23/index.html"];

    NSURL *out1 = [in1 ks_URLByUnescapingUnreservedCharactersInPath];
    NSURL *out2 = [in2 ks_URLByUnescapingUnreservedCharactersInPath];
    NSURL *out3 = [in3 ks_URLByUnescapingUnreservedCharactersInPath];
    NSURL *out4 = [in4 ks_URLByUnescapingUnreservedCharactersInPath];
    NSURL *out5 = [in5 ks_URLByUnescapingUnreservedCharactersInPath];
    NSURL *out6 = [in6 ks_URLByUnescapingUnreservedCharactersInPath];

    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
    XCTAssertTrue([[out6 absoluteString] isEqualToString:[can6 absoluteString]], @"out6 failed");
}


- (void)test_ks_URLByAddingTrailingSlashToDirectory
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/sandvox"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/folder1/folder2/folder3/folder4/folder5/folder6"];
    NSURL *in5 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/folder1/folder2/folder3/folder4/folder5/folder6/"];
    NSURL *can5 = [NSURL URLWithString:@""];
    
    NSURL *out1 = [in1 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out2 = [in2 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out3 = [in3 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out4 = [in4 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out5 = [in5 ks_URLByAddingTrailingSlashToDirectory];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
}


- (void)test_ks_URLByRemovingDefaultPort
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80"];
    NSURL *in4 = [NSURL URLWithString:@"https://username:password@www.karelia.com:443/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in5 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://username:password@www.karelia.com"];
    NSURL *can4 = [NSURL URLWithString:@"https://username:password@www.karelia.com/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can5 = [NSURL URLWithString:@""];
    
    NSURL *out1 = [in1 ks_URLByRemovingDefaultPort];
    NSURL *out2 = [in2 ks_URLByRemovingDefaultPort];
    NSURL *out3 = [in3 ks_URLByRemovingDefaultPort];
    NSURL *out4 = [in4 ks_URLByRemovingDefaultPort];
    NSURL *out5 = [in5 ks_URLByRemovingDefaultPort];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
}


- (void)test_ks_URLByRemovingDotSegments
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/level3/../../level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/././level2/././level3/../.././././././level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/level1/././level2/././level3/../.././././././level2"];
    NSURL *in4 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/level1/level2"];
    NSURL *can4 = [NSURL URLWithString:@""];

    NSURL *out1 = [in1 ks_URLByRemovingDotSegments];
    NSURL *out2 = [in2 ks_URLByRemovingDotSegments];
    NSURL *out3 = [in3 ks_URLByRemovingDotSegments];
    NSURL *out4 = [in4 ks_URLByRemovingDotSegments];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
}


- (void)test_ks_URLByRemovingDirectoryIndex
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in5 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can5 = [NSURL URLWithString:@""];
    
    NSURL *out1 = [in1 ks_URLByRemovingDirectoryIndex];
    NSURL *out2 = [in2 ks_URLByRemovingDirectoryIndex];
    NSURL *out3 = [in3 ks_URLByRemovingDirectoryIndex];
    NSURL *out4 = [in4 ks_URLByRemovingDirectoryIndex];
    NSURL *out5 = [in5 ks_URLByRemovingDirectoryIndex];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
}


- (void)test_ks_URLByRemovingFragment
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/index.html#anchor1"];
    NSURL *in5 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in6 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can5 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can6 = [NSURL URLWithString:@""];
    
    NSURL *out1 = [in1 ks_URLByRemovingFragment];
    NSURL *out2 = [in2 ks_URLByRemovingFragment];
    NSURL *out3 = [in3 ks_URLByRemovingFragment];
    NSURL *out4 = [in4 ks_URLByRemovingFragment];
    NSURL *out5 = [in5 ks_URLByRemovingFragment];
    NSURL *out6 = [in6 ks_URLByRemovingFragment];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    XCTAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");    
    XCTAssertTrue([[out6 absoluteString] isEqualToString:[can6 absoluteString]], @"out6 failed");    
}


- (void)test_ks_URLByRemovingDuplicateSlashes
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1//level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/////////////index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in4 = [NSURL URLWithString:@""];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can4 = [NSURL URLWithString:@""];
    
    NSURL *out1 = [in1 ks_URLByRemovingDuplicateSlashes];
    NSURL *out2 = [in2 ks_URLByRemovingDuplicateSlashes];
    NSURL *out3 = [in3 ks_URLByRemovingDuplicateSlashes];
    NSURL *out4 = [in4 ks_URLByRemovingDuplicateSlashes];
    XCTAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    XCTAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    XCTAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    XCTAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
}


//- (void)test_ks_URLByRemovingEmptyQuery
//{
//    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
//    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?#anchor1"];
//    NSURL *in3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?"];
//    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
//    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2#anchor1"];
//    NSURL *can3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2"];
//    
//    NSURL *out1 = [in1 ks_URLByRemovingEmptyQuery];
//    NSURL *out2 = [in2 ks_URLByRemovingEmptyQuery];
//    NSURL *out3 = [in3 ks_URLByRemovingEmptyQuery];
//    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
//    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
//    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");    
//}









@end
