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
var _CPSoundHaveQTChecked = NO;
var _CPSoundHaveQT = NO;

@implementation _CPQuickTimeSound : CPSound
{
    DOMElement _Player;      // The DOM element that will be used and controlled
    CPArray _UnhandledRequests;
    CPString _file;
}

- (BOOL)_haveQuickTime
{
    if (_CPSoundHaveQTChecked)
        return _CPSoundHaveQT;
    _CPSoundHaveQT = NO;
    if (navigator.plugins) {
        for (var i=0; i < navigator.plugins.length; i++ ) {
            if (navigator.plugins[i].name.indexOf("QuickTime") >= 0)
            {
                _CPSoundHaveQT = YES;
            }
        }
    }
    
    if ((navigator.appVersion.indexOf("Mac") > 0)
        && (navigator.appName.substring(0,9) == "Microsoft")
        && (parseInt(navigator.appVersion) < 5) )
    {
        _CPSoundHaveQT = YES;
    }
    
    if (!_CPSoundHaveQT && [self _isInternetExplorer])
    {
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("language", "VBscript");
        document.getElementsByTagName("head")[0].appendChild(scriptElement);
        scriptElement.text = 'Function detectQuickTimeVB()\n'
            + '  on error resume next\n'
            + '  detectQuickTimeVB = False\n'
            + '  hasQuickTimeChecker = False\n'
            + '  Set hasQuickTimeChecker = CreateObject("QuickTimeCheckObject.QuickTimeCheck.1")\n'
            + '  If IsObject(hasQuickTimeChecker) Then\n'
            + '    If hasQuickTimeChecker.IsQuickTimeAvailable(0) Then\n'
            + '      detectQuickTimeVB = True\n'
            + '    End If\n'
            + '  End If\n'
            + 'End Function\n';
        _CPSoundHaveQT = detectQuickTimeVB();
    }
    _CPSoundHaveQTChecked = YES;
    return _CPSoundHaveQT;
}

- (BOOL)_isInternetExplorer
{
    var ua = navigator.userAgent.toLowerCase();
    var msie = /msie/.test(ua) && !/opera/.test(ua);

    return msie;
}

- (id)_CreateDOMObjectElement:(NSString)aFileName
{
    var qtEventID = "qt_event_source";
    var _DOMObjectElement = document.createElement("object");
    var _DOMParamElement = document.createElement("param");
    
    [self _registerEvent:'qt_begin' 
                listener:_DOMObjectElement
                    func:function () {[self _handleUnhandledRequests];}];
                    
    
    _DOMObjectElement.setAttribute("classid", "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B");
    _DOMObjectElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
    if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent) || [self _isInternetExplorer])
    {
        _DOMObjectElement.setAttribute("width", "1");
        _DOMObjectElement.setAttribute("height", "1");
    } else {    // In firefox, non-zero sized elements are ignored, and JS won't work.
        _DOMObjectElement.setAttribute("width", "0");
        _DOMObjectElement.setAttribute("height", "0");
    }
    _DOMObjectElement.setAttribute("data", aFileName);
    _DOMObjectElement.setAttribute("id", "CPMixerObject" + _CPMixerCounter);
    if ([self _isInternetExplorer])
    {
        _DOMObjectElement.style.behavior = "url(#" + qtEventID + ")";
        _DOMObjectElement.setAttribute("style", "behavior:" + "url(#" + qtEventID + ")");
    }
    _DOMParamElement.setAttribute("name", "src");
    _DOMParamElement.setAttribute("value", aFileName);
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("name", "controller");
    _DOMParamElement.setAttribute("value", "false");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("name", "autoplay");
    _DOMParamElement.setAttribute("value", "false");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("name", "enablejavascript");
    _DOMParamElement.setAttribute("value", "true");
    _DOMObjectElement.appendChild(_DOMParamElement);
    _DOMParamElement = document.createElement("param");
    _DOMParamElement.setAttribute("name", "postdomevents");
    _DOMParamElement.setAttribute("value", "true");
    _DOMObjectElement.appendChild(_DOMParamElement);
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent))) // If we hide this, firefox will ignore it and JS won't work.
    {
        _DOMParamElement = document.createElement("param");
        _DOMParamElement.setAttribute("name", "hidden");
        _DOMParamElement.setAttribute("value", "true");
        _DOMObjectElement.appendChild(_DOMParamElement);
    }
    
    return _DOMObjectElement;
}

- (id)_CreateDOMEmbedElement:(NSString)aFileName
{
    var _DOMEmbedElement = document.createElement("embed");  // Embed-tag
    
    [self _registerEvent:'qt_begin' 
                listener:_DOMEmbedElement 
                    func:function () {[self _handleUnhandledRequests];}];
    
    _DOMEmbedElement.setAttribute("src", aFileName);
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)))
    {
        _DOMEmbedElement.setAttribute("width", "0");
        _DOMEmbedElement.setAttribute("height", "0");
    } else {    // In firefox, non-zero sized elements are ignored, and JS won't work.
        _DOMEmbedElement.setAttribute("width", "1");
        _DOMEmbedElement.setAttribute("height", "1");
    }
    _DOMEmbedElement.setAttribute("pluginspage", "http://www.apple.com/quicktime/download/");
    _DOMEmbedElement.setAttribute("id", "CPMixerObject" + _CPMixerCounter);
    _DOMEmbedElement.setAttribute("name", "CPMixerEmbed" + _CPMixerCounter);
    _DOMEmbedElement.setAttribute("enablejavascript", "true");
    _DOMEmbedElement.setAttribute("postdomevents", "true");
    _DOMEmbedElement.setAttribute("controller", "false");
    _DOMEmbedElement.setAttribute("autoplay", "false");
    _DOMEmbedElement.setAttribute("type", "video/quicktime");
    if (!(/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)))
    {
        _DOMEmbedElement.setAttribute("hidden", "true");
    }
    return _DOMEmbedElement;
}

- (void)_CreateEventController
{
    var qtEventID = "qt_event_source";
    if (!document.getElementById(qtEventID))
    {
        var _DOMEventElement = document.createElement("object");
        _DOMEventElement.setAttribute("id", qtEventID);
        _DOMEventElement.setAttribute("classid", "clsid:CB927D12-4FF7-4a9e-A169-56E4B8A75598");
        _DOMEventElement.setAttribute("codebase", "http://www.apple.com/qtactivex/qtplugin.cab");
        document.getElementsByTagName("head")[0].appendChild(_DOMEventElement);
    }
}

- (id)initWithFile:(CPString)aFileName mixer:(DOMElement)mixerDiv
{
    self = [super init];
   
    if (self)
    {
        if(![self _haveQuickTime])
            return nil;
        _file = aFileName;
        _UnhandledRequests = [[CPArray alloc] init];
        
        if ([self _isInternetExplorer])
        {
            var _DOMEventController = [self _CreateEventController];
        }
        
        var _DOMObjectElement = [self _CreateDOMObjectElement:aFileName];
        var _DOMEmbedElement = nil;
        if (![self _isInternetExplorer])
            _DOMEmbedElement = [self _CreateDOMEmbedElement:aFileName];
        
        if (![self _isInternetExplorer])
        {
            _DOMObjectElement.appendChild(_DOMEmbedElement);
        }
        
        mixerDiv.appendChild(_DOMObjectElement);
        
        _Player = document.getElementsByName("CPMixerEmbed" + _CPMixerCounter);
        if (_Player.length != 0 && !/WebKit/.test(navigator.userAgent))
            _Player = _Player[0];
        else{
            _Player = document.getElementById("CPMixerObject" + _CPMixerCounter);
            if(!_Player)
                return nil;
        }
        
        [self _registerEvent:'qt_ended' 
                    listener:_Player 
                        func:function () {
                            if (_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
                                [_delegate sound:self didFinishPlaying:YES];
                        }];
        
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
        if ([[request objectForKey:@"name"] isEqualToString:@"play"]){
            [self play];
        } else if ([[request objectForKey:@"name"] isEqualToString:@"pause"]){
            [self pause];
        } else if ([[request objectForKey:@"name"] isEqualToString:@"stop"]){
            [self stop];
        } else if ([[request objectForKey:@"name"] isEqualToString:@"setVolume"]){
            [self setVolume:[request objectForKey:@"volume"]];
        } else if ([[request objectForKey:@"name"] isEqualToString:@"setLoops"]){
            [self setLoops:[request objectForKey:@"loops"]];
        } else if ([[request objectForKey:@"name"] isEqualToString:@"setCurrentTime"]){
            [self setCurrentTime:[request objectForKey:@"time"]];
        }
    }
    [_UnhandledRequests removeAllObjects];
}

- (BOOL)isPlaying
{
    try{
        return _Player.GetRate() != 0;
    } catch (error) {
        return NO;
    }
}

/**
 * Enabling DOM events seem to be possible only after the addon has loaded in IE
 * and that is exactly what the events are used for; telling when the addon has
 * loaded. Also the URL has to be set again when the addon has loaded (only in IE)
**/
- (void)_uglyInternetExplorerHack
{
    try {
        if ([self _isInternetExplorer] && (!_Player.GetURL() || [_Player.GetURL() isEqual:""]))
        {
            _Player.SetResetPropertiesOnReload(NO);
            _Player.SetURL(location.protocol + "//" + document.domain + "/" + _file);
            [self _registerEvent:'qt_begin' 
                        listener:_Player 
                            func:function () {[self _handleUnhandledRequests];}];
                    
            [self _registerEvent:'qt_ended' 
                        listener:_Player 
                            func:function () {
                                if (_delegate != nil && [_delegate respondsToSelector:@selector(sound:didFinishPlaying:)])
                                    [_delegate sound:self didFinishPlaying:YES];
                            }];
            [self _handleUnhandledRequests];
        }
    } catch (error) {}
}

- (void)play
{
    [self _uglyInternetExplorerHack];
    try {
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
    [self _uglyInternetExplorerHack];
    try {
        _Player.Stop();
        _wantsPlay = NO;
    } catch (error) {
        [_UnhandledRequests insertObject:[CPDictionary dictionaryWithObject:@"pause" forKey:@"name"] atIndex:[_UnhandledRequests count]];
    }
}

- (void)stop
{
    [self _uglyInternetExplorerHack];
    try {
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
    [self _uglyInternetExplorerHack];
    try {
        return _Player.GetVolume() / 256.0;
    } catch (error) {
        return 1;
    }
}

// Set volume between 0 and 1
- (void)setVolume:(var)volume
{
    [self _uglyInternetExplorerHack];
    try {
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
    [self _uglyInternetExplorerHack];
    try {
        return _Player.GetDuration() / _Player.GetTimeScale();
    } catch (error) {
        return -1;
    }
}

- (BOOL)loops()
{
    [self _uglyInternetExplorerHack];
    try {
        return _Player.GetIsLooping() != 0;
    } catch (error) {
        return NO;
    }
}

- (void)setLoops:(BOOL)loops
{
    [self _uglyInternetExplorerHack];
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
    [self _uglyInternetExplorerHack];
    try {
        return _Player.GetTime() / _Player.GetTimeScale();
    } catch (error) {
        return 0;
    }
}

- (void)setCurrentTime:(var)time
{
    [self _uglyInternetExplorerHack];
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
