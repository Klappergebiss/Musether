//
//  TDAudioStream.m
//  Musether
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Modified, extented and optimized by Tim Engel 2016.
//

#import "TDAudioStream.h"

@interface TDAudioStream () <NSStreamDelegate>

@property (strong, nonatomic) NSStream *stream;

@end

@implementation TDAudioStream

- (instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    self = [super init];
    if (!self) return nil;

    self.stream = inputStream;

    return self;
}

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream
{
    self = [super init];
    if (!self) return nil;

    self.stream = outputStream;

    return self;
}

- (void)open
{
    self.stream.delegate = self;
    [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    return [self.stream open];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if ([aStream isKindOfClass:[NSInputStream class]]) {
        switch (eventCode) {
            case NSStreamEventHasBytesAvailable:
                [self.delegate audioStream:self didRaiseInputEvent:TDAudioStreamEventHasData];
                break;
                
            case NSStreamEventEndEncountered:
                [self.delegate audioStream:self didRaiseInputEvent:TDAudioStreamEventEnd];
                break;
                
            case NSStreamEventErrorOccurred:
                [self.delegate audioStream:self didRaiseInputEvent:TDAudioStreamEventError];
                break;
                
            default:
                break;
        }
    } else if ([aStream isKindOfClass:[NSOutputStream class]]) {
        switch (eventCode) {
            case NSStreamEventHasSpaceAvailable:
                [self.delegate audioStream:self didRaiseOutputEvent:TDAudioStreamEventWantsData];
                break;
                
            case NSStreamEventEndEncountered:
                [self.delegate audioStream:self didRaiseOutputEvent:TDAudioStreamEventEnd];
                break;
                
            case NSStreamEventErrorOccurred:
                [self.delegate audioStream:self didRaiseOutputEvent:TDAudioStreamEventError];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - No Delegate anymore...

- (UInt32)readData:(uint8_t *)data maxLength:(UInt32)maxLength
{
    return (UInt32)[(NSInputStream *)self.stream read:data maxLength:maxLength];
}

- (UInt32)writeData:(uint8_t *)data maxLength:(UInt32)maxLength
{
    return (UInt32)[(NSOutputStream *)self.stream write:data maxLength:maxLength];
}

- (void)close
{
    [self.stream close];
    self.stream.delegate = nil;
    [self.stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)dealloc
{
    if (self.stream)
        [self close];
}

- (NSStreamStatus) streamStatus {
    return self.stream.streamStatus;
}

@end
