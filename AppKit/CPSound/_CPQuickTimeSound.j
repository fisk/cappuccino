/*
 * _CPQuickTimeSound.j
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


@import "CPSound.j"
@import <Foundation/CPArray.j>
@import <Foundation/CPDictionary.j>

var _CPMixerCounter = 0;

@implementation _CPQuickTimeSound : CPSound
{
    DOMElement _Player;      // The DOM element that will be used and controlled
    CPArray _UnhandledRequests;
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

- (id)_CreateDOMObjectElement:(NSString)aFileName
{
    var _DOMObjectElement = document.createElement("object");
    var _DOMParamElement = document.createElement("param");
    
    _DOMObjectElement.setAttribute("classid", "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B");
    _DOMObjectElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)))
    {
        _DOMObjectElement.setAttribute("width", "1");
        _DOMObjectElement.setAttribute("height", "1");
    } else {    // In firefox, non-zero sized elements are ignored, and JS won't work.
        _DOMObjectElement.setAttribute("width", "0");
        _DOMObjectElement.setAttribute("height", "0");
    }
    _DOMObjectElement.setAttribute("data", aFileName);
    _DOMObjectElement.setAttribute("id", "CPMixer" + "Object" + _CPMixerCounter);
    
    _DOMParamElement.setAttribute("src", aFileName);
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("controller", "false");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("autoplay", "false");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("enablejavascript", "true");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("postdomevents", "true");
    _DOMObjectElement.appendChild(_DOMParamElement);
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent))) // If we hide this, firefox will ignore it and JS won't work.
    {
        _DOMParamElement = document.createElement("param");
        _DOMParamElement.setAttribute("hidden", "true");
        _DOMObjectElement.appendChild(_DOMParamElement);
    }
    
    return _DOMObjectElement;
}

- (id)_CreateDOMEmbedElement:(NSString)aFileName
{
    var _DOMEmbedElement = document.createElement("embed");  // Embed-tag
    
    _DOMEmbedElement.setAttribute("src", aFileName);
    _DOMEmbedElement.setAttribute("width", "1");
    _DOMEmbedElement.setAttribute("height", "1");
    _DOMEmbedElement.setAttribute("pluginspage", "http://www.apple.com/quicktime/download/");
    _DOMEmbedElement.setAttribute("id", "CPMixer" + "Object" + _CPMixerCounter);
    _DOMEmbedElement.setAttribute("name", "CPMixer" + "Embed" + _CPMixerCounter);
    _DOMEmbedElement.setAttribute("enablejavascript", "true");
    _DOMEmbedElement.setAttribute("postdomevents", "true");
    _DOMEmbedElement.setAttribute("controller", "false");
    _DOMEmbedElement.setAttribute("autoplay", "false");
    _DOMEmbedElement.setAttribute("type", "video/quicktime");
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)))
        _DOMEmbedElement.setAttribute("hidden", "true");
    return _DOMEmbedElement;
}

- (id)initWithFile:(CPString)aFileName mixer:(DOMElement)mixerDiv
{
    self = [super init];
   
    if (self)
    {
        if(![self _haveQuickTime])
            return nil;
            
        _UnhandledRequests = [[CPArray alloc] init];
        
        var _DOMObjectElement = [self _CreateDOMObjectElement:aFileName];
        var _DOMEmbedElement = [self _CreateDOMEmbedElement:aFileName];
    
        _DOMObjectElement.appendChild(_DOMEmbedElement);
        mixerDiv.appendChild(_DOMObjectElement);
        
        
        _Player = document.getElementsByName("CPMixer" + "Embed" + _CPMixerCounter);
        if (_Player.length != 0)
            _Player = _Player[0];
        else{
            _Player = document.getElementById("CPMixer" + "Object" + _CPMixerCounter);
            if(!_Player)
                return nil;
        }
        
        if (document.addEventListener)
        {
            _Player.addEventListener('qt_ended', function () {
                if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
                    [_delegate sound:self didFinishPlaying:YES];
            } , false);
        } else {  // Internet Explorer
            _Player.attachEvent('onqt_ended', function () {
                if(_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
                    [_delegate sound:self didFinishPlaying:YES];
            });
        }
        
        if (document.addEventListener)
        {
            _Player.addEventListener('qt_begin', function () {
                [self _handleUnhandledRequests];
            } , false);
        } else {  // Internet Explorer
            _Player.attachEvent('onqt_begin', function () {
                [self _handleUnhandledRequests];
            });
        }
        
        _CPMixerCounter++;
    }
    return self;
}

// Used to handle requests issued before addon was loaded.
- (void)_handleUnhandledRequests
{
    for (var i = 0; i < [_UnhandledRequests count]; i++)
    {
        var request = [_UnhandledRequests objectAtIndex:i];
        if ([[request objectForKey:@"name"] isEqualToString:@"play"])
            [self play];
        else if ([[request objectForKey:@"name"] isEqualToString:@"pause"])
            [self pause];
        else if ([[request objectForKey:@"name"] isEqualToString:@"stop"])
            [self stop];
        else if ([[request objectForKey:@"name"] isEqualToString:@"setVolume"])
            [self setVolume:[request objectForKey:@"volume"]];
        else if ([[request objectForKey:@"name"] isEqualToString:@"setLoops"])
            [self setLoops:[request objectForKey:@"loops"]];
        else if ([[request objectForKey:@"name"] isEqualToString:@"setCurrentTime"])
            [self setCurrentTime:[request objectForKey:@"time"]];
    }
}

- (BOOL)isPlaying
{
    return _Player.GetRate() != 0;
}

- (void)play
{
    try{
        var status = _Player.GetPluginStatus();
        if (status == @"Complete")
            _Player.Play();
        else
            _Player.SetAutoPlay(true);
    } catch (error) {   // Not done loading all the JS functionality or something.
        [_UnhandledRequests insertObject:[CPDictionary dictionaryWithObject:@"play" forKey:@"name"] atIndex:[_UnhandledRequests count]];
    }
}

- (void)pause
{
    try{
        _Player.Stop();
        _wantsPlay = NO;
    } catch (error) {
        [_UnhandledRequests insertObject:[CPDictionary dictionaryWithObject:@"pause" forKey:@"name"] atIndex:[_UnhandledRequests count]];
    }
}

- (void)stop
{
    try{
        _Player.Rewind();
        _Player.Stop();
        _wantsPlay = NO;
    } catch (error) {
        [_UnhandledRequests insertObject:[CPDictionary dictionaryWithObject:@"stop" forKey:@"name"] atIndex:[_UnhandledRequests count]];
    }
}

// Volume between 0 and 1
- (var)volume
{
    return _Player.GetVolume() / 256.0;
}

// Set volume between 0 and 1
- (void)setVolume:(var)volume
{
    try{
        if (volume > 1)
            volume = 1;
        else if (volume < 0)
            volume = 0;
        _Player.SetVolume(volume*256);
    } catch (error) {
        var request = [CPDictionary dictionaryWithObjects:@"setVolume" forKeys:@"name"];
        [request setObject:volume forKey:@"volume"]
        [_UnhandledRequests insertObject:request atIndex:[_UnhandledRequests count]];
    }
}

- (var)duration
{
    return _Player.GetDuration() / _Player.GetTimeScale();
}

- (BOOL)loops()
{
    return _Player.GetIsLooping() != 0;
}

- (void)setLoops:(BOOL)loops
{
    try{
        _Player.SetIsLooping(loops?1:0);
    } catch (error) {
        var request = [CPDictionary dictionaryWithObjects:@"setLoops" forKeys:@"name"];
        [request setObject:loops forKey:@"loops"]
        [_UnhandledRequests insertObject:request atIndex:[_UnhandledRequests count]];
    }
}

- (var)currentTime
{
    return _Player.GetTime() / _Player.GetTimeScale();
}

- (void)setCurrentTime:(var)time
{
    if(time < 0)
        time = 0;
    try {
        _Player.SetTime(time * _Player.GetTimeScale());
    } catch (error) {
        var request = [CPDictionary dictionaryWithObjects:@"setCurrentTime" forKeys:@"name"];
        [request setObject:time forKey:@"time"]
        [_UnhandledRequests insertObject:request atIndex:[_UnhandledRequests count]];
    }
}

@end