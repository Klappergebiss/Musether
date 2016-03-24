//
//  TDAudioStream.h
//  Musether
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Modified, extented and optimized by Tim Engel 2016.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TDAudioStreamEvent) {
    TDAudioStreamEventHasData,
    TDAudioStreamEventWantsData,
    TDAudioStreamEventEnd,
    TDAudioStreamEventError
};

@class TDAudioStream;

@protocol TDAudioStreamDelegate <NSObject>

@required
- (void)audioStream:(TDAudioStream *)audioStream didRaiseOutputEvent:(TDAudioStreamEvent)event;
- (void)audioStream:(TDAudioStream *)audioStream didRaiseInputEvent:(TDAudioStreamEvent)event;

@end

@interface TDAudioStream : NSObject

@property (assign, nonatomic) id<TDAudioStreamDelegate> delegate;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream;
- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream;

- (void)open;
- (void)close;
- (UInt32)readData:(uint8_t *)data maxLength:(UInt32)maxLength;
- (UInt32)writeData:(uint8_t *)data maxLength:(UInt32)maxLength;
- (NSStreamStatus) streamStatus;

@end
