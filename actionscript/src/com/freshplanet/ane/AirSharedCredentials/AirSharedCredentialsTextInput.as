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


	public class AirSharedCredentialsTextInput extends EventDispatcher {


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//


		/**
		 * Initialize and display UITextField
		 * @param frame frame where the textField should be displayed
		 * @param placeholder ghost/placeholder text
		 * @param fontName name of the font to be used
		 * @param fontColor color of the font to be used
		 * @param placeholderColor color of the placeholder text
		 * @param textSize size of text
		 * @param contentType UITextContentType string
		 * @param keyboardType UIKeyboardType string
		 * @param icon bitmap data of the icon to be displayed as the 'leftView' of UITextField
		 */
		public function create(frame:Rectangle, placeholder:String, fontName:String, fontColor:uint, placeholderColor:uint, textSize:int, contentType:String, keyboardType:String = "UIKeyboardTypeDefault", icon:BitmapData = null):void {
			this._frame = frame;
			if(icon)
				_context.call("textInput_create", frame.x, frame.y, frame.width, frame.height, placeholder, fontName, fontColor, placeholderColor, textSize, contentType, keyboardType, icon);
			else
				_context.call("textInput_create", frame.x, frame.y, frame.width, frame.height, placeholder, fontName, fontColor, placeholderColor, textSize, contentType, keyboardType);
		}

		/**
		 * Focus in the textField and display soft keyboard
		 */
		public function assignFocus():void {
			_context.call("textInput_assignFocus");
		}

		/**
		 * Focus out the textField and hide soft keyboard
		 */
		public function removeFocus():void {
			_context.call("textInput_removeFocus");
		}

		/**
		 * Get current textField text
		 */
		public function get text():String {
			return _context.call("textInput_getText") as String;
		}

		/**
		 * Set current textField text
		 */
		public function set text(value:String):void {
			_context.call("textInput_setText", value);
		}

		/**
		 * Get current textField frame
		 */
		public function get frame():Rectangle {
			return _frame;
		}

		/**
		 * Set current textField frame
		 */
		public function set frame(value:Rectangle):void {
			_frame = value;
			_context.call("textInput_setFrame", value.x, value.y, value.width, value.height);
		}

		/**
		 * Destroy the textField and remove it from view
		 */
		public function destroy():void {
			_context.call("textInput_destroy");
			_context.removeEventListener(StatusEvent.STATUS, _handleStatusEvent);
			_context.dispose();
			_context = null;
			_frame = null;
		}

		/**
		 * Set textField visible
		 */
		public function show():void {
			_context.call("textInput_show");
		}

		/**
		 * Set textField hidden
		 */
		public function hide():void {
			_context.call("textInput_hide");
		}

		/**
		 * Get textField alpha
		 */
		public function get alpha():Number {
			return _context.call("textInput_getAlpha") as Number;
		}

		/**
		 * Set textField alpha
		 */
		public function set alpha(value:Number):void {
			_context.call("textInput_setAlpha", value);
		}

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private var _context:ExtensionContext = null;
		private var _frame:Rectangle = null;

		public function AirSharedCredentialsTextInput(context:ExtensionContext) {
			
			super();
			
			_context = context;
			_context.addEventListener(StatusEvent.STATUS, _handleStatusEvent, false, 0, true);
		}
		
		private function _handleStatusEvent(event:StatusEvent):void {

			if(event.code == "log"){
				trace("[AirSharedCredentials] TextInput: ", event.level);
				return;
			}

			switch (event.code) {
				case AirSharedCredentialsTextInputEvent.RETURN:
					dispatchEvent(new AirSharedCredentialsTextInputEvent(AirSharedCredentialsTextInputEvent.RETURN));
					break;
				case AirSharedCredentialsTextInputEvent.TEXT_CHANGED:
					dispatchEvent(new AirSharedCredentialsTextInputEvent(AirSharedCredentialsTextInputEvent.TEXT_CHANGED));
					break;
			}


		}
		
	}
}