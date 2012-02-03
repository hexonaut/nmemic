package nme.events;
#if (cpp || neko)


import nme.events.Event;
import nme.utils.ByteArray;


class SampleDataEvent extends Event {
	
	
	public static var SAMPLE_DATA : String = "sampleData";
	
	public var data:ByteArray;
	public var position:Float;
	
	public function new (type : String, bubbles : Bool = false, cancelable : Bool = false, theposition : Float = 0, thedata : ByteArray = null) : Void {
		
		super (type, bubbles, cancelable);
		
		this.data = thedata;
		this.position = theposition;
		
	}
	
	
}


#else
typedef SampleDataEvent = flash.events.SampleDataEvent;
#end