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

#define CP_SOUND_USE_EMBED				1
#define CP_SOUND_USE_OBJECT				2
#define CP_SOUND_USE_OBJECT_NOT_IE		3
#define CP_SOUND_USE_AUDIO				4

var _CPMixerDiv = nil;
var _CPMixerCounter = 0;

@implementation CPSound : CPObject
{
    DOMElement _DOMAudioElement;
	DOMElement _DOMObjectElement = document.createElement("object");
	DOMElement _DOMObjectElementNotIE = document.createElement("object");
	DOMElement _DOMParamElement = document.createElement("param");
	DOMElement _DOMEmbedElement = document.createElement("embed");
	DOMElement _Player;
	var        _PlayerType
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
		_DOMObjectElement = document.createElement("object");
		_DOMObjectElementNotIE = document.createElement("object");
		_DOMParamElement = document.createElement("param");
		_DOMEmbedElement = document.createElement("embed");
		
		_DOMAudioElement.setAttribute("src", aFileName);	// Audio-tag
		_DOMAudioElement.setAttribute("autoplay", "false");
		_DOMAudioElement.setAttribute("controls", "false");
		_DOMAudioElement.setAttribute("id", "CPMixer" + "Audio"+_CPMixerCounter);
		
		_DOMObjectElement.setAttribute("classid", "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B");	// Object-tag
		_DOMObjectElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
		_DOMObjectElement.setAttribute("width", "0");
		_DOMObjectElement.setAttribute("height", "0");
		_DOMObjectElement.setAttribute("id", "CPMixer" + "Object"+_CPMixerCounter);
		
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
		_DOMParamElement.setAttribute("pluginspage", "http://www.apple.com/quicktime/download/");
		_DOMObjectElement.appendChild(_DOMParamElement);
		_DOMParamElement = document.createElement("param");
		_DOMParamElement.setAttribute("hidden", "true");
		_DOMObjectElement.appendChild(_DOMParamElement);
		
		if (!(navigator.appName == "Microsoft Internet Explorer")){
			
			_DOMObjectElementNotIE.setAttribute("type", "audio/x-mpeg");	// Object-tag
			_DOMObjectElementNotIE.setAttribute("data", aFileName);
			_DOMObjectElementNotIE.setAttribute("width", "0");
			_DOMObjectElementNotIE.setAttribute("height", "0");
			_DOMObjectElementNotIE.setAttribute("id", "CPMixer" + "Object"+_CPMixerCounter+"notIE");
			
			_DOMParamElement.setAttribute("src", aFileName);
			_DOMObjectElementNotIE.appendChild(_DOMParamElement);
			_DOMParamElement = document.createElement("param");
			_DOMParamElement.setAttribute("controller", "false");
			_DOMObjectElementNotIE.appendChild(_DOMParamElement);
			_DOMParamElement = document.createElement("param");
			_DOMParamElement.setAttribute("autoplay", "false");
			_DOMObjectElementNotIE.appendChild(_DOMParamElement);
			_DOMParamElement = document.createElement("param");
			_DOMParamElement.setAttribute("autostart", "0");
			_DOMObjectElement.appendChild(_DOMParamElement);
			_DOMParamElement = document.createElement("param");
			_DOMParamElement.setAttribute("pluginurl", "http://www.apple.com/quicktime/download/");
			_DOMObjectElementNotIE.appendChild(_DOMParamElement);
			_DOMParamElement = document.createElement("param");
			_DOMParamElement.setAttribute("hidden", "true");
			_DOMObjectElementNotIE.appendChild(_DOMParamElement);
			
			_DOMObjectElement.appendChild(_DOMObjectElementNotIE);
		}
		
		_DOMEmbedElement.setAttribute("src", aFileName);	// Embed-tag
		_DOMEmbedElement.setAttribute("type", "audio/x-mpeg");
		_DOMEmbedElement.setAttribute("autostart", "0");
		_DOMEmbedElement.setAttribute("autoplay", "false");
		_DOMEmbedElement.setAttribute("controller", "false");
		_DOMEmbedElement.setAttribute("id", "CPMixer" + "Embed"+_CPMixerCounter);
		
		_DOMObjectElementNotIE.appendChild(_DOMEmbedElement);
		_DOMObjectElement.appendChild(_DOMObjectElementNotIE);
		_DOMAudioElement.appendChild(_DOMObjectElement);
		_CPMixerDiv.appendChild(_DOMAudioElement);
		
		_Player = document.getElementsByName("CPMixer" + "Embed"+_CPMixerCounter);
		if (_Player.length == 0)
		{
			_Player = document.getElementById("CPMixer" + "Object"+_CPMixerCounter + "notIE");
			_PlayerType = CP_SOUND_USE_OBJECT_NOT_IE;
		} else {
			_Player = _Player[0];
			_PlayerType = CP_SOUND_USE_EMBED;
		}
		if (!_Player)
		{
			_Player = document.getElementById("CPMixer" + "Object"+_CPMixerCounter);
			_PlayerType = CP_SOUND_USE_OBJECT;
		}
		if (!_Player)
		{
			_Player = document.getElementById("CPMixer" + "Audio"+_CPMixerCounter);
			_PlayerType = CP_SOUND_USE_AUDIO;
		}
		_CPMixerCounter++;
		
		if (navigator.appName == "Microsoft Internet Explorer")
		{
			_Player.attachEvent('onended', function () {
				if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
					[_delegate sound:self didFinishPlaying:YES];
			} );
		} else {
			_Player.addEventListener('ended', function () {
				if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
					[_delegate sound:self didFinishPlaying:YES];
			} , false);
		}
    }
    return self;
}

- (void)setAudio:(CPString)resource
{
	var aFileName = [[CPBundle mainBundle] pathForResource:resource];
	_Player.setAttribute("src", aFileName);
}

- (void)setControls:(BOOL)controls
{
	if (controls)
		_Player.setAttribute("controls", "true");
	else
		_Player.setAttribute("controls", "false");
}

- (void)setPlaycount:(unsigned)playcount
{
	_Player.setAttribute("playcount", [CPString stringWithFormat:@"%d", playcount]);
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
	return !_Player.paused;
}

- (void)play
{
	if(_Player.Play){
		_Player.Play();
	} else {
		_Player.play();
	}
}

- (void)pause
{
	if(_Player.Pause){
		_Player.Pause();
	} else {
		_Player.pause();
	}
}

- (void)stop
{
	if(_Player.Stop){
		_Player.Stop();
	} else {
		_Player.stop();
	}
}

- (void)sound:(CPSound)sound didFinishPlaying:(BOOL)finishedPlaying
{

}

@end
