//
//  TDAudioOutputStreamer.h
//  Musether
//
//  Created by Tony DiPasquale on 11/14/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Changed, extented and optimized by Tim Engel 2016.
//

#import <Foundation/Foundation.h>

@class AVURLAsset;

@interface TDAudioOutputStreamer : NSObject

@property (assign, atomic) BOOL isStreaming;

- (instancetype)initWithOutputStream:(NSOutputStream *)stream;

- (void)streamAudioFromURL:(NSURL *)url;
- (void)start;
- (void)stop;
- (NSStreamStatus) streamStatus;

@end
