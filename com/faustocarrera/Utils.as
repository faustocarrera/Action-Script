// +------------------------------------------------------------------------+
// | Utils.as                                                        |
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
// | Please give credit on sites that use Utils.as and submit        |
// | changes of the script so other people can use them as well.            |
// | This script is free to use, don't abuse.                               |
// +------------------------------------------------------------------------+
//

/**
 * Class Utils
 *
 * @version   1.0
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
	
	public class Utils {

		// remove childs
		public function removeChilds(target:MovieClip):void {
			if (target.numChildren > 0) {
				var i:int = 0;
				for (i; i<target.numChildren; i++) {
					var child:DisplayObject = target.getChildAt(i);
					target.removeChild(child);
				}
				//trace(target.name+" now have "+target.numChildren+" children{s}");
			}
		}
		
		// load movies
		
		public function loadMovieClip(movie:String, target:MovieClip):void {
			this.removeChilds(target);
			//trace("Loading movie: " + movie + " on movieclip " + target);
			var loader_section:Loader = new Loader();
			loader_section.load(new URLRequest(movie));
			loader_section.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader_section.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

			function onProgress(evt:ProgressEvent):void {
				var percent:Number = evt.bytesLoaded / evt.bytesTotal * 100;
			}

			function onComplete(evt:Event):void {
				loader_section.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader_section.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				target.addChild(loader_section);
			}
		}
		
		// debug array
		public function debugArray(arr:Array):void {
			for(var k:int = 0; k < arr.length; k++) {
				trace(arr[k]);
			}
			trace("====================");
		}
		
		// redir to external page
		
		public function getURL(url:String, target:String):void {
			var req:URLRequest = new URLRequest(url);
			navigateToURL(req, target);
		}
	}
}