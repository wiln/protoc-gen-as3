// vim: tabstop=4 shiftwidth=4

// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.protobuf {
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	public final class SimpleWebRPC {
		private var urlPrefix:String
		public function SimpleWebRPC(urlPrefix:String) {
			this.urlPrefix = urlPrefix;
		}
		private static const REF:Dictionary = new Dictionary();
		public function send(serviceName:String,
							 methodName:String,
							 input:IExternalizable,
							 callback:Function,
							 outputType:Class):void {

			const loader:URLLoader = new URLLoader
			REF[loader] = true;
			loader.dataFormat = URLLoaderDataFormat.BINARY
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				delete REF[loader]
				const output:IExternalizable = new outputType
				output.readExternal(loader.data)
				callback(output)
			})
			function errorEventHandler(event:Event):void {
				delete REF[loader]
				callback(event)
			}
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler)
			loader.addEventListener(
					SecurityErrorEvent.SECURITY_ERROR, errorEventHandler)
			const request:URLRequest = new URLRequest(
				urlPrefix + serviceName + ":" + methodName)
			request.method = URLRequestMethod.POST
			const requestContent:ByteArray = new ByteArray
			input.writeExternal(requestContent)
			request.data = requestContent
			request.contentType = "application/x-protobuf"
			loader.load(request)
		}
	}
}