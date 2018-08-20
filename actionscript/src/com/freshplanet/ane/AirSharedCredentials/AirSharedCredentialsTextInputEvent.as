package com.freshplanet.ane.AirSharedCredentials {
import flash.events.Event;

public class AirSharedCredentialsTextInputEvent extends Event {

	public static const RETURN:String = "AirSharedCredentialsTextInputEvent_return";

	public function AirSharedCredentialsTextInputEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
	}

}
}
