#include <Recorder.h>
#include "AQRecorder.h"
#import <Foundation/Foundation.h>

void (*nme_microphone_activate)();
void (*nme_microphone_data)(char *buf, int len);
void (*nme_microphone_deactivate)();

@interface Recorder : NSObject

+ (id) init;
+ (void) start;
+ (void) stop;
+ (void) recordQueueStopped;

@end

AQRecorder *aqRecorder = NULL;

extern "C" void nme_microphone_record (void (*activateCallback)(), void (*dataCallback)(char *buf, int len), void (*deactivateCallback)()) {
	nme_microphone_activate = activateCallback;
	nme_microphone_data = dataCallback;
	nme_microphone_deactivate = deactivateCallback;
	
	[Recorder start];
}

extern "C" void nme_microphone_reset () {
	[Recorder start];
}

@implementation Recorder

+ (void) start {
	if (aqRecorder == NULL) {
		aqRecorder = new AQRecorder();
		aqRecorder->delegate_ = self;
	} else {
		[Recorder stop];
	}
	aqRecorder->StartRecord();
	nme_microphone_activate();
}

+ (void) stop {
	if(aqRecorder->IsRunning()){
        aqRecorder->StopRecord();
    }
}

+ (void) recordQueueStopped {
	NSMutableData *data = [aqRecorder->speexEncoder_ encodedAudio_];
	
	char *buf = (char *)[data bytes];
	int len = [data length];
	nme_microphone_data(buf, len);
	nme_microphone_deactivate();
}

@end