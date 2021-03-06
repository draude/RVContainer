//
//  RVContainer.m
//  RVContainer
//
//  Created by Badchoice on 17/5/17.
//  Copyright © 2017 Revo. All rights reserved.
//

#import "RVContainer.h"

@implementation RVContainer

//=======================================================
#pragma mark - Singleton
//=======================================================
+ (RVContainer*) container {
    static RVContainer *container = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        container = [[self alloc] init];
    });
    return container;
}

-(id)init{
    if( self = [super init]){
        self.bindings   = [NSMutableDictionary new];
    }
    return self;
}

//=======================================================
#pragma mark - Bind
//=======================================================
-(void)bind:(Class)class closure:(id (^)(void))closure{
    NSString * className        = NSStringFromClass(class);
    self.bindings[className]    = closure;
}

-(void)bind:(Class)class resolver:(Class)resolver{
    NSString * className        = NSStringFromClass(class);
    NSString * resolverName     = NSStringFromClass(resolver);
    self.bindings[className]    = resolverName;
}

-(void)instance:(Class)class object:(id)object{
    NSString * className        = NSStringFromClass(class);
    self.bindings[className]    = object;
}

-(void)singleton:(Class)class closure:(id (^)(void))closure{
    [self instance:class object:closure()];
}

-(void)bindProtocol:(Protocol*)protocol closure:(id (^)(void))closure{
    NSString * protocolName     = NSStringFromProtocol(protocol);
    self.bindings[protocolName] = closure;
}

-(void)bindProtocol:(Protocol*)protocol resolver:(Class)resolver{
    NSString * protocolName     = NSStringFromProtocol(protocol);
    NSString * resolverName     = NSStringFromClass(resolver);
    self.bindings[protocolName] = resolverName;
}

//=======================================================
#pragma mark - Resolve
//=======================================================
-(id)make:(Class)class{
    NSString * className = NSStringFromClass(class);
    id resolver          = self.bindings[className];
    if( ! resolver ){
        return [class new];
    }
    return [self makeWithResolver:resolver];
}

-(id)makeProtocol:(Protocol*)protocol{
    NSString * protocolName = NSStringFromProtocol(protocol);
    id resolver             = self.bindings[protocolName];
    if( ! resolver){
        [NSException raise:@"No implementation" format:@"A protocol can't be instantiated without a implementation"];
    }
    return [self makeWithResolver:resolver];
}


//=======================================================
#pragma mark - Private
//=======================================================
-(id)makeWithResolver:(id)resolver{
    if([resolver isKindOfClass:NSString.class]){
        return [NSClassFromString(resolver) new];
    }
    
    if ([resolver isKindOfClass:NSClassFromString(@"NSBlock")]){
        id(^block)(void) = resolver;
        return block();
    }
    
    return resolver;
}


@end
