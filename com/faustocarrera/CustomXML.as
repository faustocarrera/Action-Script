// +------------------------------------------------------------------------+
// | CustomXML.as                                                        |
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
// | Please give credit on sites that use CustomXML.as and submit        |
// | changes of the script so other people can use them as well.            |
// | This script is free to use, don't abuse.                               |
// +------------------------------------------------------------------------+
//

/**
 * Class CustomXML
 *
 * @version   0.3
 * @author    Fausto Carrera <yo@faustocarrera.com.ar>
 * @license   http://opensource.org/licenses/gpl-license.php GNU Public License
 * @copyright Fausto Carrera
 * @package   AS
 * @subpackage external
 */
 
package com.faustocarrera
{

	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;

	public class CustomXML extends EventDispatcher
	{

		// Constants:
		// Public Properties:
		public var return_data:XML;
		public var current_progress:Number;
		public var current_address:String = "";
		// Private Properties:
		private var xml_loader:URLLoader;
		private var xml_request:URLRequest;
		private var xml_variables:URLVariables;
		// Initialization:
		public function CustomXML()
		{
			this.xml_loader = new URLLoader();
		}

		// Public Methods:

		public function loadXML(src:String, method:String, variables:String=null):void
		{
			this.current_address = src;
			xml_request = new URLRequest(this.current_address);
			//
			this.xml_loader.addEventListener(Event.OPEN, onOpen);
			this.xml_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.xml_loader.addEventListener(Event.COMPLETE, this.onComplete);
			this.xml_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			//
			if (method == "POST") {
				this.xml_request.method = URLRequestMethod.POST;
				//verify if we have variables
				if (variables) {
					this.xml_variables = new URLVariables(variables);
					this.xml_request.data = this.xml_variables;
				}
			}
			try {
				this.xml_loader.load(xml_request);
			} catch (error:Error) {
				//trace("Unable to load: "+this.current_address);
				dispatchEvent(new Event("onLoaderError"));
			}
		}

		// Protected Methods:

		private function onOpen(evt:Event):void
		{
			dispatchEvent(new Event("onLoaderStart"));
		}


		private function onComplete(evt:Event):void
		{
			return_data = new XML(evt.target.data);
			dispatchEvent(new Event("onLoaderComplete"));
			//
			this.xml_loader.removeEventListener(Event.OPEN, onOpen);
			this.xml_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			this.xml_loader.removeEventListener(Event.COMPLETE, this.onComplete);
			this.xml_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}

		private function onProgress(evt:ProgressEvent):void
		{
			this.current_progress = evt.bytesLoaded / evt.bytesTotal;
			dispatchEvent(new Event("onLoaderProgress"));
		}

		private function onIOError(evt:IOErrorEvent):void
		{
			//trace("Error! unable to load: " + this.current_address);
			dispatchEvent(new Event("onLoaderError"));
		}

	}

}