#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <hx/Thread.h>
#include <Recorder.h>
#include <string.h>

namespace nme {

int state;
char *outgoing;
int outgoing_pos;
int outgoing_len;
int outgoing_cap;
MyMutex *mutex;
	
void nme_microphone_activate () {
	mutex->Lock();
	state += 1;
	mutex->Unlock();
}

void nme_microphone_data (char *buf, int len) {
	mutex->Lock();
	if (len > 0) {
		if (outgoing == NULL) outgoing = (char *)malloc(sizeof(char)*len);
		if (outgoing_pos + len > outgoing_cap) {
			char *newbuf = (char *)malloc(sizeof(char)*(outgoing_len + len));
			memcpy(newbuf, outgoing, outgoing_len);
			free(outgoing);
			outgoing = newbuf;
			outgoing_cap += len;
		}
		memcpy(outgoing + outgoing_pos, buf, len);
		outgoing_pos += len;
		outgoing_len += len;
	}
	mutex->Unlock();
}

void nme_microphone_deactivate () {
	nme_microphone_reset();
	
	mutex->Lock();
	state += 1;
	mutex->Unlock();
}

static void nme_microphone_create () {
	mutex = new MyMutex();
	outgoing_pos = 0;
	outgoing_len = 0;
	outgoing_cap = 0;
	outgoing = NULL;
	state = 0;
	nme_microphone_record(nme_microphone_activate, nme_microphone_data, nme_microphone_deactivate);
}
DEFINE_PRIM(nme_microphone_create, 0);

static value nme_microphone_poll (value outHaxeObj) {
	mutex->Lock();
	if (outgoing_pos > 0) {
		buffer buf = alloc_buffer_len(0);
		buffer_append_sub(buf, outgoing, outgoing_len);
		
		outgoing_pos = 0;
		outgoing_len = 0;
		alloc_field(outHaxeObj, val_id("state"), alloc_int(state));
		state = 0;
		
		mutex->Unlock();
		return buffer_val(buf);
	} else {
		mutex->Unlock();
		return alloc_null();
	}
}
DEFINE_PRIM(nme_microphone_poll, 1);

static void nme_microphone_reset () {
	nme_microphone_deactivate();
}
DEFINE_PRIM(nme_microphone_reset, 0);

extern "C" void nme_microphone_main () {
}
DEFINE_ENTRY_POINT(nme_microphone_main);

extern "C" int microphone_register_prims () { return 0; }

}