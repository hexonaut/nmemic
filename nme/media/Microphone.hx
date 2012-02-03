package nme.media;

#if (cpp || neko)

import haxe.io.Bytes;
import haxe.io.BytesData;
import nme.events.ActivityEvent;
import nme.events.EventDispatcher;
import nme.events.SampleDataEvent;
import nme.utils.ByteArray;

class Microphone extends EventDispatcher {
	
	private static var instance:Microphone = null;
	
	private var lastState:Int;
	private var state:Int;
	private var pos:Int;
	
	private function new () {
		super();
		
		this.lastState = 0;
		this.state = 0;
		this.pos = 0;
		
		nme_microphone_create();
	}
	
	public function reset ():Void {
		nme_microphone_reset();
	}
	
	public static function getMicrophone (?index:Int = -1):Microphone {
		if (instance == null) instance = new Microphone();
		return instance;
	}
	
	private function onActivate ():Void {
		this.dispatchEvent(new ActivityEvent(ActivityEvent.ACTIVITY, false, false, true));
	}
	
	private function onData (data:Bytes):Void {
		this.dispatchEvent(new SampleDataEvent(SampleDataEvent.SAMPLE_DATA, false, false, pos, ByteArray.fromBytes(data)));
		this.pos += data.length;
	}
	
	private function onDeactivate ():Void {
		this.dispatchEvent(new ActivityEvent(ActivityEvent.ACTIVITY, false, false, false));
	}
	
	public function nmePoll ():Void {
		var bd:BytesData = nme_microphone_poll(this);
		
		if (state >= 1 && lastState % 2 == 0 || state >= 2 && lastState % 2 == 1) {
			//Activate
			pos = 0;
			onActivate();
		}
		
		if (bd != null) {
			var bytes = Bytes.ofData(bd);
			if (bytes.length > 0) {
				onData(bytes);
			}
		}
		
		if (state >= 1 && lastState % 2 == 1 || state >= 2 && lastState % 2 == 0) {
			//Deactivate
			onDeactivate();
		}
		
		lastState = state;
		state = 0;
	}
	
	public static function nmePollData ():Void {
		if (instance != null) instance.nmePoll();
	}
	
	//TODO - change to nme.Loader.load when added to repo
	static var nme_microphone_create = cpp.Lib.load("microphone", "nme_microphone_create", 0);
	static var nme_microphone_poll = cpp.Lib.load("microphone", "nme_microphone_poll", 1);
	static var nme_microphone_reset = cpp.Lib.load("microphone", "nme_microphone_reset", 0);
	
}

#else
typedef Microphone = flash.media.Microphone;
#end