/*
 * Copyright 2018 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.freshplanet.ane.AirSharedCredentials {
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;

public class AirSharedCredentials extends EventDispatcher {

	// --------------------------------------------------------------------------------------//
	//																						 //
	// 									   PUBLIC API										 //
	// 																						 //
	// --------------------------------------------------------------------------------------//

	/** AirSharedCredentials is supported on iOS devices. */
	public static function get isSupported() : Boolean {
		var isMacOSMojave:Boolean = false;

		if(Capabilities.os.indexOf("Mac OS") > -1) {
			var versionParts:Array = Capabilities.os.match(/(\d+)/g);
			isMacOSMojave =  versionParts && versionParts.length >= 2 && int(versionParts[0]) >= 10 && int(versionParts[1]) >= 15;
		}
		return isiOS || isMacOSMojave;
	}

	private static function get isiOS():Boolean {
		return Capabilities.manufacturer.indexOf("iOS") > -1 && Capabilities.os.indexOf("x86_64") < 0 && Capabilities.os.indexOf("i386") < 0;
	}

	/**
	 * AirSharedCredentials instance
	 * @return AirSharedCredentials instance
	 */
	public static function get instance() : AirSharedCredentials {
		return _instance ? _instance : new AirSharedCredentials();
	}

	/**
	 * Get native iOS UITextField instance
	 * @return
	 */
	public function getTextInput() : AirSharedCredentialsTextInput {
		if (!isiOS) return null;

		var ctx:ExtensionContext = ExtensionContext.createExtensionContext(EXTENSION_ID,
				EXTENSION_CONTEXT_TEXT_INPUT);

		return new AirSharedCredentialsTextInput(ctx);
	}

	/**
	 * Save Shared Web Credential
	 * @param account
	 * @param password
	 * @param fqdn fully qualified domain name
	 */
	public function saveAccount(account:String, password:String, fqdn:String) : void {
		if (!isSupported) return;

		_context.call("saveAccount", account, password, fqdn);
	}

	/**
	 * Delete Shared Web Credential
	 * @param account
	 * @param fqdn fully qualified domain name
	 */
	public function deleteAccount(account:String, fqdn:String) : void {
		if (!isSupported) return;

		_context.call("deleteAccount", account, fqdn);
	}


	/**
	 * "Sign in with Apple" button
	 */

	/**
	 * Get native AuthorizationAppleIDButton instance
	 * @return
	 */
	public function getAppleAuthButton() : AirSharedCredentialsAppleAuthButton {
		if (!isSupported) return null;

		var ctx:ExtensionContext = ExtensionContext.createExtensionContext(EXTENSION_ID,
				EXTENSION_CONTEXT_APPLE_AUTH);

		return new AirSharedCredentialsAppleAuthButton(ctx);
	}

	// --------------------------------------------------------------------------------------//
	//																						 //
	// 									 	PRIVATE API										 //
	// 																						 //
	// --------------------------------------------------------------------------------------//

	private static const EXTENSION_ID : String = "com.freshplanet.ane.AirSharedCredentials";
	private static const EXTENSION_CONTEXT_TEXT_INPUT:String   = "textInput";
	private static const EXTENSION_CONTEXT_APPLE_AUTH:String   = "appleAuth";

	private static var _instance : AirSharedCredentials = null;
	private var _context : ExtensionContext = null;

	/**
	 * "private" singleton constructor
	 */
	public function AirSharedCredentials() {
		if (!_instance) {
			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if (!_context) {
				throw Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
				return;
			}
			_context.addEventListener(StatusEvent.STATUS, onStatus);

			_instance = this;
		}
		else {
			throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
		}
	}

	private function onStatus( event : StatusEvent ) : void {
		if (event.code == "log") {
			trace("[AirSharedCredentials]: ", event.level);
			return;
		}
	}

}
}
