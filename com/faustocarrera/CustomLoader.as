// +------------------------------------------------------------------------+
// | CustomLoader.as                                                        |
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
// | Please give credit on sites that use CustomLoader.as and submit        |
// | changes of the script so other people can use them as well.            |
// | This script is free to use, don't abuse.                               |
// +------------------------------------------------------------------------+
//

/**
 * Class CustomLoader
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
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;

	public class CustomLoader extends EventDispatcher
	{
		// Public Properties:

		public var verbosity:Boolean = false;
		public var current_container:Sprite;
		public var current_address:String = "";
		public var current_progress:Number = 0;
		public var error:String;

		// Private Properties:

		private var files_arr:Array = [];
		private var total_files:int = 0;
		private var counter:int = 0;
		private var file_loader:Loader;

		// Initialization:

		public function CustomLoader()
		{
			// reset
			this.current_container = null;
			this.current_address = "";
			this.current_progress = 0;
			this.files_arr = [];
			this.counter = 0;
			// listeners
			this.file_loader = new Loader();
			this.file_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
			this.file_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComplete);
			this.file_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
		}

		// Public Methods:

		public function setVerbosity(verbosity:Boolean):void
		{
			this.verbosity = verbosity;
		}

		public function addFile(src:String, target:MovieClip):void
		{
			this.files_arr.push([src, target]);
			this.total_files++;
		}

		public function startLoad():void
		{
			dispatchEvent(new Event("onLoaderStart"));
			this.current_address = this.files_arr[this.counter][0];
			this.current_container = this.files_arr[this.counter][1];
			this.loadFile();
		}
		
		// Private Methods:

		private function loadFile():void
		{
			if (this.verbosity) {
				trace("Loading: "+this.current_address+" into: "+this.current_container.name);
			}
			//remove childs
			this.removeChilds(this.current_container);
			//load file
			try {
				this.file_loader.load(new URLRequest(this.current_address));
			} catch (error:Error) {
				trace("Unable to load: "+this.current_address);
			}
		}

		private function nextFile():void
		{
			if (this.counter < this.files_arr.length - 1) {
				this.counter++;
				this.current_address = this.files_arr[this.counter][0];
				this.current_container = this.files_arr[this.counter][1];
				this.loadFile();
			} else {
				dispatchEvent(new Event("onLoaderComplete"));
				// remove listeners
				this.file_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
				this.file_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComplete);
				this.file_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			}
		}

		private function onProgress(evt:ProgressEvent):void
		{
			//this.current_progress = evt.bytesLoaded / evt.bytesTotal;
			this.current_progress = this.counter / this.total_files;
			if (this.verbosity) {
				trace("percent loaded: " + this.current_progress);
			}
			dispatchEvent(new Event("onLoaderProgress"));
		}

		private function onComplete(evt:Event):void
		{
			this.current_container.addChild(evt.target.content);
			this.nextFile();
		}

		private function onIOError(evt:IOErrorEvent):void
		{
			this.error = "Error! unable to load: " + this.current_address;
			dispatchEvent(new Event("onLoaderError"));
			//try next
			this.nextFile();
		}

		private function removeChilds(target:MovieClip):void
		{
			if (target.numChildren > 0) {
				var i:int = 0;
				for (i; i<target.numChildren; i++) {
					var child:DisplayObject = target.getChildAt(i);
					target.removeChild(child);
				}
				if (this.verbosity) {
					trace(target.name+" now have "+target.numChildren+" children{s}");
				}
			}
		}
	}
}