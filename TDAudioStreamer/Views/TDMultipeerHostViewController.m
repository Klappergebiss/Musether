//
//  TDMultipeerHostViewController.m
//  Musether
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Changed, extented and optimized by Tim Engel 2016.
//

@import MediaPlayer;
@import MultipeerConnectivity;
@import AVFoundation;

#import "TDMultipeerHostViewController.h"
#import "TDAudioStreamer.h"
#import "TDSession.h"

@interface TDMultipeerHostViewController () <MPMediaPickerControllerDelegate, TDSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) TDSession *listenSession;
@property (strong, nonatomic) TDAudioInputStreamer *listenStream;
@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) NSMutableArray *outputStreams;
@property (nonatomic) BOOL isPaused;

@property (strong, nonatomic) IBOutlet UIButton *pauseButton;

@end

@implementation TDMultipeerHostViewController

#pragma mark - Lazy instantiations of properties

-(NSString *)username{
    if (!_username) _username = @"Host";
    return _username;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.session = [[TDSession alloc] initWithPeerDisplayName:self.username];
    
    self.listenSession = [[TDSession alloc] initWithPeerDisplayName:[NSString stringWithFormat:@"myself(%@)", self.username]];
    [self.listenSession startAdvertisingForServiceType:@"dance-party" discoveryInfo:nil];
    self.listenSession.delegate = self;
    
    self.isPaused = NO;
    [self.pauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *peers = [self.session connectedPeers];
    
    if (self.outputStreams.count) {
        for (int i = 0; i < peers.count; i++) {
            [(TDAudioOutputStreamer *)self.outputStreams[i] stop];
        }
        [self.outputStreams removeAllObjects];
    }
    
    self.song = mediaItemCollection.items[0];
    
    NSUInteger isMP3 = [[[self.song valueForProperty:MPMediaItemPropertyAssetURL] absoluteString] rangeOfString:@"mp3"].location;
    if (isMP3 == NSNotFound) {
        NSLog(@"Momentan wird leider nur MP3 unterstützt.");
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
    
    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
    if (image)
        info[@"artwork"] = image;
    
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = [UIImage imageNamed:@"noArtworkImage.png"];
    
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];
    
    
    if (!self.outputStreams) self.outputStreams = [[NSMutableArray alloc] initWithCapacity:peers.count];
    
    if (peers.count) {
        for (int i = 0; i < peers.count; i++) {
            self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peers[i]]];
            [self.outputStreams insertObject:self.outputStreamer atIndex:i];
            
            [(TDAudioOutputStreamer *)self.outputStreams[i] streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
        }
        
        for (int i = 0; i < peers.count; i++) {
            [(TDAudioOutputStreamer *)self.outputStreams[i] start];
        }
    }
}


- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TDSessionDelegate

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    self.listenStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
    [self.listenStream start];
}

-(void)session:(TDSession *)session didReceiveData:(NSData *)data {
    
}

#pragma mark - View Actions

- (IBAction)invite:(id)sender
{
    [self presentViewController:[self.session browserViewControllerForServiceType:@"dance-party"] animated:YES completion:nil];
}

- (IBAction)addSongs:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)playButtonPressed:(UIButton *)sender {
    self.isPaused = !self.isPaused;
    NSMutableDictionary *pauseInfo = [NSMutableDictionary dictionary];
    pauseInfo[@"pauseFlag"] = self.isPaused ? @1 : @0;
    
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[pauseInfo copy]]];
    self.isPaused ? [self.listenStream pause] : [self.listenStream resume];
    
    NSString *buttonImage = self.isPaused ? @"playButton.png" : @"pauseButton.png";
    [self.pauseButton setImage:[UIImage imageNamed:buttonImage] forState:UIControlStateNormal];
}

@end
