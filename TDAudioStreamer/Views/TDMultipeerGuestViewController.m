//
//  TDMultipeerGuestViewController.m
//  Musether
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Modified, extented and optimized by Tim Engel 2016.
//

@import MediaPlayer;

#import "TDMultipeerGuestViewController.h"
#import "TDSession.h"
#import "TDAudioStreamer.h"

@interface TDMultipeerGuestViewController () <TDSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;

@end

@implementation TDMultipeerGuestViewController

#pragma mark - lazy instatiation of properties

- (NSString *)username{
    if (!_username) _username = @"Guest";
    return _username;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.session = [[TDSession alloc] initWithPeerDisplayName:self.username];
    [self.session startAdvertisingForServiceType:@"dance-party" discoveryInfo:nil];
    self.session.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopAdvertising];
}

- (void)changeSongInfo:(NSDictionary *)info
{
    if ([info[@"pauseFlag"] isEqual:@1]) {
        [self.inputStream pause];
        return;
    } else if ([info[@"pauseFlag"] isEqual:@0]) {
        [self.inputStream resume];
        return;
    }
    
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = [UIImage imageNamed:@"noArtworkImage.png"];
    
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
}

#pragma mark - TDSessionDelegate

- (void)session:(TDSession *)session didReceiveData:(NSData *)data
{
    NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self performSelectorOnMainThread:@selector(changeSongInfo:) withObject:info waitUntilDone:NO];
}

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
    [self.inputStream start];
}

@end
