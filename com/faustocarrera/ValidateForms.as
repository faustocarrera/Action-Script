// +------------------------------------------------------------------------+
// | ValidateForms.as                                                        |
// +------------------------------------------------------------------------+
// | Copyright (c) Fausto Carrera 2005-2010. All rights reserved.           |
// | Version       0.3                                                      |
// | Last modified 11/04/2010                                               |
// | Email         yo@faustocarrera.com.ar                                  |
// | Web           http://faustocarrera.com.ar                              |
// +------------------------------------------------------------------------+
// | This program is free software; you can redistribute it and/or modify   |
// | it under the terms of the GNU General Public License version 2 as      |
// | published by the Free Software Foundation.                             |
// |                                                                        |
// | This program is distributed in the hope that it will be useful,        |
// | but WITHOUT ANY WARRANTY; without even the implied warranty of         |
// | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          |
// | GNU General Public License for more details.                           |
// |                                                                        |
// | You should have received a copy of the GNU General Public License      |
// | along with this program; if not, write to the                          |
// |   Free Software Foundation, Inc., 59 Temple Place, Suite 330,          |
// |   Boston, MA 02111-1307 USA                                            |
// |                                                                        |
// | Please give credit on sites that use ValidateForms.as and submit        |
// | changes of the script so other people can use them as well.            |
// | This script is free to use, don't abuse.                               |
// +------------------------------------------------------------------------+
//

/**
 * Class ValidateForms
 *
 * @version   0.5
 * @author    Fausto Carrera <yo@faustocarrera.com.ar>
 * @license   http://opensource.org/licenses/gpl-license.php GNU Public License
 * @copyright Fausto Carrera
 * @package   AS
 * @subpackage external
 */

package com.faustocarrera
{

	import flash.events.*;

	public class ValidateForms extends EventDispatcher
	{

		//variables

		private var validateText:Array = [];
		private var errorTxtFields:Array = [];
		private var errorResponse:Array = [];

		//contructor

		function ValidateForms():void
		{
		}

		/*
		 * Public functions
		 */

		public function validateTextFields():void
		{
			clearErrors();
			var total_items:int = this.validateText.length;
			var total_errors:int = 0;
			var i:int = 0;
			for (i; i<total_items; i++) {
				var _required:Boolean = validateText[i][0];
				var _type:String = validateText[i][1];
				var _txt:Object = validateText[i][2];
				var min:int = validateText[i][3];
				var max:int = validateText[i][4];
				var resp:int;
				//verify if it's required or not
				resp = isEmptyData(_required,_txt,i);
				total_errors += resp;
				//check according type
				switch (_type) {
					case "string" :
						resp=this.isString(_required,_txt,i);
						total_errors+=resp;
						break;
					case "number" :
						resp=this.isNumber(_required,_txt,min,max,i);
						total_errors+=resp;
						break;
					case "email" :
						resp=this.isEmail(_required,_txt,i);
						total_errors+=resp;
						break;
					case "date" :
						resp=this.isDate(_required,_txt,i);
						total_errors+=resp;
						break;
					case "url" :
						resp=this.isUrl(_required,_txt,i);
						total_errors+=resp;
						break;
					case "equal" :
						var equal_txt:Object=validateText[i][3];
						resp=this.isEqual(_required,_txt,equal_txt,i);
						total_errors+=resp;
						break;
					case "minmax" :
						resp=this.countChars(_required,_txt,min,max,i);
						total_errors+=resp;
						break;
				}
			}
			//verify errors
			if (total_errors>0) {
				dispatchEvent(new Event("onError"));
			}
			else {
				dispatchEvent(new Event("onOk"));
			}
		}

		public function addValidation(validate_data:Array):void
		{
			validateText.push(validate_data);
		}

		public function getErrors():Array
		{
			var errors_arr:Array=[];
			var i:int=0;
			var t:int=errorTxtFields.length;
			for (i; i<t; i++) {
				errors_arr.push([errorTxtFields[i],errorResponse[i]]);
			}
			return errors_arr;
		}

		/*
		 * Private functions
		 */

		private function clearErrors():void
		{
			this.errorTxtFields=[];
			this.errorResponse=[];
		}

		private function isEmptyData(required:Boolean, text_field:Object, i:uint):uint
		{
			if (required==true&&text_field.text=="") {
				setError(text_field,"is required",i);
				return 1;
			}
			else {
				return 0;
			}
		}

		private function isNumber(required:Boolean, text_field:Object, min:int, max:int, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			if (isNaN(text_field.text)) {
				setError(text_field,"must be a number",i);
				return 1;
			}
			else {
				if (max!=min) {
					if (text_field.text>max||text_field.text<min) {
						setError(text_field,"must be a numer between " + min + " and " + max,i);
						return 1;
					}
					else {
						return 0;
					}
				}
				else {
					return 0;
				}
			}
		}

		private function isEmail(required:Boolean, text_field:Object, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			var emailExpression:RegExp=/^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			if (emailExpression.test(text_field.text)) {
				return 0;
			}
			else {
				setError(text_field,"must be a valid email",i);
				return 1;
			}
		}

		private function isString(required:Boolean, text_field:Object, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			if (typeof(text_field.text) == "string") {
				return 0;
			}
			else {
				setError(text_field,"must be a string",i);
				return 1;
			}
		}

		private function isDate(required:Boolean, text_field:Object, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			var dateExpression:RegExp=/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/i;
			if (dateExpression.test(text_field.text)) {
				var date_arr:Array=text_field.text.split("-");
				if (date_arr[1]>0&&date_arr[1]<13&&date_arr[2]>0&&date_arr[2]<32) {
					return 0;
				}
				else {
					setError(text_field,"must be a valid date",i);
					return 1;
				}
			}
			else {
				setError(text_field,"must be yyyy-mm-dd",i);
				return 1;
			}
		}

		private function isUrl(required:Boolean, text_field:Object, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			var urlExpression:RegExp=/^http(s)?:\/\/((\d+\.\d+\.\d+\.\d+)|(([\w-]+\.)+([a-z,A-Z][\w-]*)))(:[1-9][0-9]*)?(\/([\w-.\/:%+@&=]+[\w-.\/?:%+@&=]*)?)?(#(.*))?$/i;
			if (urlExpression.test(text_field.text)) {
				return 0;
			}
			else {
				setError(text_field,"must be a valid url",i);
				return 1;
			}
		}

		private function isEqual(required:Boolean, text_field:Object,equal_field:Object, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			if (text_field.text==equal_field.text) {
				return 0;
			}
			else {
				setError(equal_field, "it's not equal to "+text_field.name,i);
				return 1;
			}
		}

		private function countChars(required:Boolean, text_field:Object, min:int, max:int, i:uint):uint
		{
			if (! required&&text_field.text=="") {
				return 0;
			}

			if (text_field.text.length<min||text_field.text.length>max) {
				setError(text_field, "must have between "+min+" and "+max+" chars",i);
				return 1;
			}
			else {
				return 0;
			}
		}

		private function setError(error_field:Object, error_response:String, field_num:uint):void
		{
			this.errorTxtFields.push(field_num);
			this.errorResponse.push(error_response);
			var count:int=0;
			var i:int=0;
			for (i; i<this.errorTxtFields.length; i++) {
				if (this.errorTxtFields[i]==field_num) {
					if (count>0) {
						this.errorTxtFields.splice(i, 1);
						this.errorResponse.splice(i, 1);
					}
					count++;
				}
			}
		}
	}
}