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
		
		_DOMAudioElement.addEventListener('ended', function () {
			if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
				[_delegate sound:self didFinishPlaying:YES];
		} );
		_CPMixerDiv.appendChild(_DOMAudioElement);
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
