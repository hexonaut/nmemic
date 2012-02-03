#import <Foundation/Foundation.h>
//#import "SpeechAudioQueue.h"
//#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

@interface IAnswerUtilities : NSObject {
    
}

+(NSString*)getTrimedStringFromQuery:(NSString*)query;

+(UInt32)audioFileSize:(AudioFileID)fileDescriptor;
+(AudioFileID)openAudioFile:(NSString*)filePath;

@end
