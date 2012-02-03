#ifndef __RECORDER_H__
#define __RECORDER_H__

extern "C" void nme_microphone_record (void (*activateCallback)(), void (*dataCallback)(char *buf, int len), void (*deactivateCallback)());
extern "C" void nme_microphone_reset ();

#endif