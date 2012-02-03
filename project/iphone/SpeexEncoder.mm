//#import "SpeechAudioQueue.h"
#import "SpeexEncoder.h"
#import "config.h"
#import "speex/speex.h"
//#import "speex/speex_preprocess.h"
#import <math.h>
#import "IAnswerUtilities.h"

//#define FRAME_SIZE 110

const int kAudioSampleRate = 16000;
const int kAudioPacketIntervalMs = 100;
//const ChannelLayout SpeechRecognizer::kChannelLayout = CHANNEL_LAYOUT_MONO;
const int kNumBitsPerAudioSample = 16;
const int kNoSpeechTimeoutSec = 8;
const int kEndpointerEstimationTimeMs = 300;

const char* const kContentTypeSpeex = "audio/x-speex-with-header-byte; rate=";
const int kSpeexEncodingQuality = 8;  /*Set the quality to 8 (15 kbps)*/
const int kMaxSpeexFrameLength = 110;  // (44kbps rate sampled at 32kHz).


@implementation SpeexEncoder

@synthesize encodedAudio_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        encodedAudio_ = [[NSMutableData alloc] init];
    }
    
    return self;
}

-(void) dealloc {
    [encodedAudio_ release];
    [super dealloc];
}

- (void)speexEncRawBuf:(short*)samples withByteSize:(int) bytesize
{
    //not write file anymore, directly to encodedAudio_
    //FILE* fout;
    //NSString *outSpeexPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"outSpeex.spx"];
    //NSLog(@"Output path: %@", outSpeexPath);
    //fout = fopen([outSpeexPath UTF8String], "w");
    
    /*Holds the state of the encoder*/
    void *state;    
    /*Holds bits so they can be read and written to by the Speex routines*/
    SpeexBits bits;
    int samples_per_frame;
    char encoded_frame_data[kMaxSpeexFrameLength + 1];
    
    memset(&bits, 0, sizeof(bits));
    speex_bits_init(&bits);
    state = speex_encoder_init(&speex_wb_mode);
    
    speex_encoder_ctl(state, SPEEX_GET_FRAME_SIZE, &samples_per_frame);
    
    //NSLog(@"samples_per_frame %d", samples_per_frame);
    
    int quality = kSpeexEncodingQuality;
    speex_encoder_ctl(state, SPEEX_SET_QUALITY, &quality);
    int vbr = 1;
    speex_encoder_ctl(state, SPEEX_SET_VBR, &vbr);
    //int vad = 1;
    //speex_encoder_ctl(state, SPEEX_SET_VBR, &vad);
    //int dtx = 1;
    //speex_encoder_ctl(state, SPEEX_SET_DTX, &dtx);
    memset(encoded_frame_data, 0, sizeof(encoded_frame_data));
    
    int num_samples = bytesize / sizeof(short);
    
    // Drop incomplete frames, typically those which come in when recording stops.
    num_samples -= (num_samples % samples_per_frame);
    for (int i = 0; i < num_samples; i += samples_per_frame) {
        speex_bits_reset(&bits);
        
        speex_encode_int(state, (samples + i), &bits);
        
        // Encode the frame and place the size of the frame as the first byte. This
        // is the packet format for MIME type x-speex-with-header-byte.
        int frame_length = speex_bits_write(&bits, encoded_frame_data + 1,
                                            kMaxSpeexFrameLength);
        encoded_frame_data[0] = (char)frame_length;
        //NSLog(@"frame_length : %d",frame_length);   
        
        //fwrite(encoded_frame_data, 1, frame_length+1, fout);
        [encodedAudio_ appendBytes:encoded_frame_data length:frame_length+1];
    }
    
    /*Destroy the encoder state*/
    speex_encoder_destroy(state);
    /*Destroy the bit-packing struct*/
    speex_bits_destroy(&bits);
    //fclose(fout);
}
 
//    speex VAD seems not work
//    SpeexPreprocessState *preprocess_state = speex_preprocess_state_init(samples_per_frame, kAudioSampleRate); 
//    int tmp = 1;
//    speex_preprocess_ctl(preprocess_state, SPEEX_PREPROCESS_SET_VAD, &tmp);
//    int isSpeech;
//    isSpeech = speex_preprocess_run(preprocess_state, samples);
//    NSLog(@"%d",isSpeech);
//    speex_preprocess_state_destroy(preprocess_state);

- (void)speexEncFile: (NSString*) inCafFilePath 
{
    
    AudioFileID fileID = [IAnswerUtilities openAudioFile:inCafFilePath];
    UInt32 waveLen = [IAnswerUtilities audioFileSize:fileID];
    
    NSLog(@"waveLen : %d",(int)waveLen);

    // the audio data buf
    short * samples = (short*) malloc(waveLen);
    memset(samples, 0, waveLen);
    
    // get the bytes from the file and put them into the data buffer
    OSStatus result = noErr;
    result = AudioFileReadBytes(fileID, false, 0, &waveLen, samples);
    
    AudioFileClose(fileID); //close the file
    if (result != noErr) NSLog(@"cannot load caf file: %@",inCafFilePath);
    
    [self speexEncRawBuf:samples withByteSize:waveLen];
    
    free(samples);
}

@end
