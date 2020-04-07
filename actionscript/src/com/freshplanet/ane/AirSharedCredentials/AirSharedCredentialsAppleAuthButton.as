/*
 * Copyright 2017 FreshPlanet
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

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Rectangle;


	public class AirSharedCredentialsAppleAuthButton extends EventDispatcher {


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//


		/**
		 * Initialize and display Apple Sign In button
		 * @param frame frame where the textField should be displayed
		 */
		public function create(frame:Rectangle):void {
			this._frame = frame;
			_context.call("appleAuth_create", frame.x, frame.y, frame.width, frame.height);
		}

		/**
		 * Request credential manually
		 */
		public function requestCredential():void {
			_context.call("appleAuth_requestCredential");
		}

		/**
		 * Get current state of the credential (used for remembering login)
		 */
		public function getCredentialState():void {
			_context.call("appleAuth_getCredentialState");
		}

		/**
		 * Set button frame
		 */
		public function set frame(value:Rectangle):void {
			_frame = value;
			_context.call("appleAuth_setFrame", value.x, value.y, value.width, value.height);
		}

		/**
		 * Show button
		 */
		public function show():void {
			_context.call("appleAuth_show");
		}

		/**
		 * Hide button
		 */
		public function hide():void {
			_context.call("appleAuth_hide");
		}

		/**
		 * Destroy button
		 */
		public function destroy():void {
			_context.call("appleAuth_destroy");
		}


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private var _context:ExtensionContext = null;
		private var _frame:Rectangle = null;

		public function AirSharedCredentialsAppleAuthButton(context:ExtensionContext) {
			
			super();
			
			_context = context;
			_context.addEventListener(StatusEvent.STATUS, _handleStatusEvent, false, 0, true);
		}
		
		private function _handleStatusEvent(event:StatusEvent):void {

			if(event.code == "log"){
				trace("[AirSharedCredentials] AppleAuthButton: ", event.level);
				return;
			}

			switch (event.code) {
				case AirSharedCredentialsAppleAuthEvent.ERROR:
					dispatchEvent(new AirSharedCredentialsAppleAuthEvent(AirSharedCredentialsAppleAuthEvent.ERROR, event.level));
					break;
				case AirSharedCredentialsAppleAuthEvent.SUCCESS:
					dispatchEvent(new AirSharedCredentialsAppleAuthEvent(AirSharedCredentialsAppleAuthEvent.SUCCESS, jsonStringToCredential(event.level)));
					break;
				case AirSharedCredentialsAppleAuthCredentialStateEvent.ERROR:
					dispatchEvent(new AirSharedCredentialsAppleAuthCredentialStateEvent(AirSharedCredentialsAppleAuthCredentialStateEvent.ERROR, event.level));
					break;
				case AirSharedCredentialsAppleAuthCredentialStateEvent.SUCCESS:
					dispatchEvent(new AirSharedCredentialsAppleAuthCredentialStateEvent(AirSharedCredentialsAppleAuthCredentialStateEvent.SUCCESS, AirSharedCredentialsAppleCredentialState.fromValue(event.level)));
					break;
			}
		}

		private function jsonStringToCredential(jsonString:String):AirSharedCredentialsAppleCredential {
			var result:AirSharedCredentialsAppleCredential;
			try {
				var json:Object = JSON.parse(jsonString);
				result = new AirSharedCredentialsAppleCredential(
						AirSharedCredentialsAppleCredentialType.fromValue(json.type),
						json.user,
						json.password,
						json.name,
						json.lastName,
						json.token,
						json.email
				);
			}catch(e:Error) {
				trace("[AirSharedCredentials] AppleAuthButton error parsing credential data : ", e.message);
				result = null;
			}
			return result;
		}

		
	}
}