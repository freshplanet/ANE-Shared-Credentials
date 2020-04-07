package com.freshplanet.ane.AirSharedCredentials {
import flash.events.Event;

public class AirSharedCredentialsAppleAuthEvent extends Event {

	public static const ERROR:String = "AirSharedCredentialsAppleAuthEvent_error";
	public static const SUCCESS:String = "AirSharedCredentialsAppleAuthEvent_success";

	/**
	 * In case of an ERROR event - data is the error string
	 * In case of an SUCCESS event - data is the AirSharedCredentialsAppleCredential
	 */
	private var _data:Object;

	public function AirSharedCredentialsAppleAuthEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
		_data = data;
	}

	public function get data():Object {
		return _data;
	}
}
}
