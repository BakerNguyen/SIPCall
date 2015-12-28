//
//  ContactDomainTests.m
//  ContactDomainTests
//
//  Created by enclave on 1/16/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <ContactDomain/AccountAdapter.h>
#import <ContactDomain/ProfileAdapter.h>
#import <ContactDomain/ContactAdapter.h>
#import <ContactDomain/ContactServerAdapter.h>
@interface ContactDomainTests : XCTestCase

@end

@implementation ContactDomainTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ContactServerAdapter share] configServerCentral];
    [[ContactServerAdapter share] configServerTenant:@{kAPI_ENCRYPTION_TENANT :@"0", kAPI_PROTOCOL_TENANT : @"ssdevapi.mtouche-mobile.com", kAPI_PORT_TENANT: @"80"}];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSDictionary* testDict = @{@"ACTION" : @"UPDATE",
                               @"API_REQUEST_KIND" : @"Normal",
                               @"API_REQUEST_METHOD" : @"POST",
                               @"BLOCKED_JID_LIST" : @"28bb431d1cf5792c18ab2d6ab625550f5797bf55@ssdevim.mtouche-mobile.com,aee13cffaa547706ba8fa696a4fe5dbdff4ca3fb@ssdevim.mtouche-mobile.com",
                               @"IMEI" : @"16A264B4-2310-4AEE-A31C-C156AE3924B9",
                               @"IMSI" : @"F6E48937-A868-45A6-B484-8D6D2FD9CFE2",
                               @"MASKINGID" : @"G004F93D",
                               @"TOKEN" : @"C9FE66380109C2743CD4D5A90CBBF24E",
                               };
    [[ContactAdapter share] synchronizeBlockList:testDict callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        //test
        XCTAssert(YES, @"Pass");
    }];
   
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
   
    
}

@end
