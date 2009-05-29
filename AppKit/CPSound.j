/*
 * CPSound.j
 * AppKit
 *
 * Created by Erik Österlund.
 * Copyright 2009, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <AppKit/CPDOMWindowBridge.j>
@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>

var _CPMixerDiv = nil;
var _CPMixerCounter = 0;

@implementation CPSound : CPObject
{
    DOMElement _DOMAudioElement;
	CPObject _delegate;
}

+ (void)initialize
{
	var bridge = [CPDOMWindowBridge sharedDOMWindowBridge];
	var body = bridge._DOMBodyElement;
	_CPMixerDiv = document.createElement("div");
	body.appendChild(_CPMixerDiv);
	_CPMixerDiv.style.width = "0px";
	_CPMixerDiv.style.height = "0px";
}

- (id)initWithResource:(CPString)resource
{
    self = [super init];
    
    if (self)
    {
		var aFileName = [[CPBundle mainBundle] pathForResource:resource];
		
		_DOMAudioElement = document.createElement("audio");
		_DOMAudioElement.setAttribute("src", aFileName);
		_DOMAudioElement.setAttribute("autoplay", "false");
		_DOMAudioElement.setAttribute("controls", "false");
		_DOMAudioElement.setAttribute("playcount", "1");
		
		var _DOMObjectElement = document.createElement("object");
		_DOMObjectElement.setAttribute("classid", "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B");
		_DOMObjectElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
		_DOMObjectElement.setAttribute("type", "audio/x-mpeg");
		_DOMObjectElement.setAttribute("src", aFileName);
		_DOMObjectElement.setAttribute("data", aFileName);
		var _DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("src", aFileName);
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("controller", "false");
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("autoplay", "false");
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("autostart", "0");
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("pluginurl", "http://www.apple.com/quicktime/download/");
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("hidden", "true");
		_DOMObjectElement.appendChild(_DOMParamElement);
		
		var _DOMEmbedElement = document.createElement("embed");
		_DOMEmbedElement.setAttribute("src", aFileName);
		_DOMEmbedElement.setAttribute("type", "audio/x-mpeg");
		_DOMEmbedElement.setAttribute("autostart", "false");
		_DOMEmbedElement.setAttribute("controller", "false");
		_DOMEmbedElement.setAttribute("hidden", "true");
		
		_DOMObjectElement.appendChild(_DOMEmbedElement);
		_DOMAudioElement.appendChild(_DOMObjectElement);
		_CPMixerDiv.appendChild(_DOMObjectElement);
		
		_DOMAudioElement = _DOMAudioElement;
		_CPMixerCounter++;
		
		_DOMAudioElement.addEventListener('ended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
				[_delegate sound:self didFinishPlaying:YES];
		} );
    }
    return self;
}

- (void)setAudio:(CPString)resource
{
	var aFileName = [[CPBundle mainBundle] pathForResource:resource];
	_DOMAudioElement.setAttribute("src", aFileName);
}

- (void)setControls:(BOOL)controls
{
	if (controls)
		_DOMAudioElement.setAttribute("controls", "true");
	else
		_DOMAudioElement.setAttribute("controls", "false");
}

- (void)setPlaycount:(unsigned)playcount
{
	_DOMAudioElement.setAttribute("playcount", [CPString stringWithFormat:@"%d", playcount]);
}

- (void)setDelegate:(CPObject)delegate
{
	_delegate = delegate;
}

- (void)delegate
{
	return _delegate;
}

- (BOOL)isPlaying
{
	return !_DOMAudioElement.paused;
}

- (void)play
{
	_DOMAudioElement.play();
}

- (void)pause
{
	_DOMAudioElement.pause();
}

- (void)stop
{
	_DOMAudioElement.stop();
}

- (void)sound:(CPSound)sound didFinishPlaying:(BOOL)finishedPlaying
{

}

@end
