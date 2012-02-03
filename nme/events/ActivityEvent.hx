package nme.events;
#if (cpp || neko)


import nme.events.Event;


class ActivityEvent extends Event {
	
	
	public static var ACTIVITY : String = "activity";
	
	public var activating:Bool;
	
	public function new (type : String, bubbles : Bool = false, cancelable : Bool = false, activating : Bool = false) : Void {
		
		super (type, bubbles, cancelable);
		
		this.activating = activating;
		
	}
	
	
}


#else
typedef ActivityEvent = flash.events.ActivityEvent;
#end