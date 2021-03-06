//
//  RVContainerTests.m
//  RVContainerTests
//
//  Created by Badchoice on 17/5/17.
//  Copyright © 2017 Revo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RVContainer.h"
#import "TestClass.h"
#import "SubTestClass.h"

@interface RVContainerTests : XCTestCase

@end

@implementation RVContainerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_can_resolve_wihout_binding{
    RVContainer * container = [RVContainer new];
    
    TestClass * object      = [container make:TestClass.class];
    
    XCTAssertEqual( object.class, TestClass.class);
}

-(void)test_can_resolve_with_class{
    RVContainer * container = [RVContainer new];
    [container bind:TestClass.class resolver:SubTestClass.class];
    
    TestClass * object      = [container make:TestClass.class];
    
    XCTAssertEqual( object.class, SubTestClass.class);
}

-(void)test_can_resolve_with_binding{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Resolver closure called"];
    
    RVContainer * container = [RVContainer new];    
    [container bind:TestClass.class closure:^id{
        [expectation fulfill];
        return [TestClass new];
    }];
    
    TestClass * object = [container make:TestClass.class];
    
    XCTAssertEqual( object.class, TestClass.class);
    
    [self waitForExpectationsWithTimeout:0.2 handler:nil];
}

-(void)test_resolve_from_closure_is_new_object{
    
    RVContainer * container = [RVContainer new];
    [container bind:TestClass.class closure:^id{
        return [TestClass new];
    }];
    
    TestClass * object  = [container make:TestClass.class];
    TestClass * object2 = [container make:TestClass.class];
    
    XCTAssertNotEqual(object, object2);
    
}

-(void)test_can_resolve_protocol{
    RVContainer * container = [RVContainer new];
    [container bindProtocol:@protocol(TesteProtocol) resolver:SubTestClass.class];
    
    TestClass * object      = [container makeProtocol:@protocol(TesteProtocol)];
    
    XCTAssertEqual( object.class, SubTestClass.class);
}

-(void)test_can_resolve_intance{
    RVContainer * container = [RVContainer new];
    SubTestClass* instance  = [SubTestClass new];
    
    [container instance:TestClass.class object:instance];
    
    TestClass * object = [container make:TestClass.class];
    
    XCTAssertEqual(object, instance);
}

-(void)test_can_resolve_singleton{
    RVContainer * container = [RVContainer new];
    
    [container singleton:TestClass.class closure:^id{
        return [SubTestClass new];
    }];
    
    TestClass * object  = [container make:TestClass.class];
    TestClass * object2 = [container make:TestClass.class];
    TestClass * object3 = [container make:TestClass.class];
    
    XCTAssertEqual(object, object2);
    XCTAssertEqual(object2, object3);
}

-(void)test_singleton_can_be_used{
    
    [IOC bind:TestClass.class resolver:SubTestClass.class];
    
    TestClass * object      = [IOC make:TestClass.class];
    
    XCTAssertEqual( object.class, SubTestClass.class);
    
}
- (void)testPerformanceExample {
    [self measureBlock:^{

    }];
}

@end
