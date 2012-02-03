#import <Foundation/Foundation.h>

@interface SpeexEncoder : NSObject{
    NSMutableData* encodedAudio_;
}

@property (nonatomic, retain) NSMutableData* encodedAudio_;

- (void)speexEncFile: (NSString*) inCafFilePath;
- (void)speexEncRawBuf:(short*)data withByteSize:(int) bytesize;

@end
