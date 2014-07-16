//
// Created by Sergey Kovalenko on 6/27/14.
// Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTObservable.h"
#import "TSTObservable+Protected.h"

@implementation TSTObservable

@synthesize listeners = _listeners;

- (id)init
{
    self = [super init];
    if (self)
    {
        _listeners = [NSHashTable weakObjectsHashTable];
    }

    return self;
}

- (void)notifyWillChangeContent:(NSMutableDictionary *)userInfo
{
    self.notifying = YES;
    for (id <TSTListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObjectWillChangeContent:userInfo:)])
        {
            [listener observableObjectWillChangeContent:self userInfo:userInfo];
        }
    }
}

- (void)notifyDidChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(TSTListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo
{
    for (id <TSTListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObject:didChangeObject:atIndex:forChangeType:userInfo:)])
        {
            [listener observableObject:self didChangeObject:anObject atIndex:index forChangeType:type userInfo:userInfo];
        }
    }
}

- (void)notifyDidChangeContent:(NSMutableDictionary *)userInfo
{
    for (id <TSTListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObjectDidChangeContent:userInfo:)])
        {
            [listener observableObjectDidChangeContent:self userInfo:userInfo];
        }
    }
    self.notifying = NO;
}

- (void)addListener:(id <TSTListener>)listener
{
    NSParameterAssert([listener conformsToProtocol:@protocol(TSTListener)]);
//    NSAssert(!self.isNotifying, @"Cannot support mutation during notification");
    [self.listeners addObject:listener];
}

- (void)removeListener:(id <TSTListener>)listener
{
//    NSAssert(!self.isNotifying, @"Cannot support mutation during notification");
    [self.listeners removeObject:listener];
}

@end