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

#define CP_SOUND_USE_EMBED_QUICKTIME				1
#define CP_SOUND_USE_OBJECT_QUICKTIME				2
#define CP_SOUND_USE_AUDIO							3

var _CPMixerDiv = nil;
var _CPMixerCounter = 0;

@implementation CPSound : CPObject
{
	DOMElement _Player;			// The DOM element that will be used and controlled
	var        _PlayerType		// The kind of DOM element we are using
	CPObject   _delegate;		// The delegate, which will be informed when the song ended
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

- (BOOL)_haveQuickTime
{
	var haveqt = NO;
	if (navigator.plugins) {
		for (i=0; i < navigator.plugins.length; i++ ) {
			if (navigator.plugins[i].name.indexOf("QuickTime") >= 0)
			{
				haveqt = YES;
			}
		}
	}
	
	if ((navigator.appVersion.indexOf("Mac") > 0)
		&& (navigator.appName.substring(0,9) == "Microsoft")
		&& (parseInt(navigator.appVersion) < 5) )
	{
		haveqt = YES;
	}
	
	return haveqt;
}

- (id)_configureQuickTimeWithFile:(NSString)aFileName
{
	if(![self _haveQuickTime])
		return NO;
	
	var _DOMObjectElement = [self _CreateDOMObjectElement:aFileName];
	var _DOMEmbedElement = [self _CreateDOMEmbedElement:aFileName];
	
	_DOMObjectElement.appendChild(_DOMEmbedElement);
	_CPMixerDiv.appendChild(_DOMObjectElement);
	
	_Player = document.getElementsByName("CPMixer" + "Embed"+_CPMixerCounter);
	if (_Player.length == 0)
	{
		_Player = document.getElementById("CPMixer" + "Object"+_CPMixerCounter);
		_PlayerType = CP_SOUND_USE_OBJECT_QUICKTIME;
	} else {
		_Player = _Player[0];
		_PlayerType = CP_SOUND_USE_EMBED_QUICKTIME;
	}
	
	_CPMixerCounter++;
	
	if (document.addEventListener)
	{
		_Player.addEventListener('qt_ended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
			[_delegate sound:self didFinishPlaying:YES];
		} , false);
	} else {
		_Player.attachEvent('onqt_ended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
			[_delegate sound:self didFinishPlaying:YES];
		});	// Internet Explorer
	}
	
	return YES;
}

- (BOOL)_configureAudioWithFile:(NSString)aFileName
{
	var _DOMAudioElement = [self _CreateDOMAudioElement:aFileName];
	_CPMixerDiv.appendChild(_DOMAudioElement);
	if(!document.getElementById("CPMixer" + "Audio"+_CPMixerCounter))
		return NO;
	
	_Player = _DOMAudioElement;
	_PlayerType = CP_SOUND_USE_AUDIO;
	
	_CPMixerCounter++;
	
	if (document.addEventListener)
	{
		_Player.addEventListener('ended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
			[_delegate sound:self didFinishPlaying:YES];
		} , false);
	} else {
		_Player.attachEvent('onended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
			[_delegate sound:self didFinishPlaying:YES];
		});	// Internet Explorer
	}
	
	return YES;
}

- (BOOL)_CreateDOMAudioElement:(NSString)aFileName
{
	var _DOMAudioElement = document.createElement("audio");
	_DOMAudioElement.setAttribute("src", aFileName);
	_DOMAudioElement.setAttribute("autoplay", "false");
	_DOMAudioElement.setAttribute("autostart", "0");
	_DOMAudioElement.setAttribute("controls", "false");
	_DOMAudioElement.setAttribute("id", "CPMixer" + "Audio"+_CPMixerCounter);
	
	return _DOMAudioElement;
}

- (id)_CreateDOMObjectElement:(NSString)aFileName
{
	var base = window.location.protocol + "//" + window.location.host + window.location.pathname + "/";
	
	var _DOMObjectElement = document.createElement("object");	// Object-tag
	var _DOMParamElement = document.createElement("param");
	
	_DOMObjectElement.setAttribute("classid", "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B");
	_DOMObjectElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
	_DOMObjectElement.setAttribute("width", "0");
	_DOMObjectElement.setAttribute("height", "0");
	
	_DOMParamElement.setAttribute("src", base+aFileName);
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("controller", "false");
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("autoplay", "false");
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("hidden", "true");
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("enablejavascript", "true");
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("postdomevents", "true");
	_DOMObjectElement.appendChild(_DOMParamElement);
	_DOMParamElement = document.createElement("param");
	_DOMParamElement.setAttribute("id", "CPMixer" + "Object"+_CPMixerCounter);
	_DOMObjectElement.appendChild(_DOMParamElement);
	
	return _DOMObjectElement;
}
	
- (id)_CreateDOMEmbedElement:(NSString)aFileName
{
	var _DOMEmbedElement = document.createElement("embed");	// Embed-tag
	
	_DOMEmbedElement.setAttribute("src", aFileName);
	_DOMEmbedElement.setAttribute("width", "0");
	_DOMEmbedElement.setAttribute("height", "0");
	_DOMEmbedElement.setAttribute("pluginspage", "http://www.apple.com/quicktime/download/");
	_DOMEmbedElement.setAttribute("name", "CPMixer" + "Embed"+_CPMixerCounter);
	_DOMEmbedElement.setAttribute("enablejavascript", "true");
	_DOMEmbedElement.setAttribute("postdomevents", "true");
	return _DOMEmbedElement;
}
	
	- (id)initWithResource:(CPString)resource
{
    self = [super init];
    
    if (self)	//TODO: We currently rely on quicktime, but other plugins could be used as well.
    {
		var aFileName = [[CPBundle mainBundle] pathForResource:resource];
		
		if (![self _configureQuickTimeWithFile:aFileName])
		{
			[self _configureAudioWithFile:aFileName];	// Quicktime not working. :(
		}
    }
    return self;
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
