/*
 * CPResponder.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
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

@import <Foundation/CPObject.j>

CPDeleteKeyCode         = 8;
CPTabKeyCode            = 9;
CPReturnKeyCode         = 13;
CPEscapeKeyCode         = 27;
CPSpaceKeyCode          = 32;
CPPageUpKeyCode         = 33;
CPPageDownKeyCode       = 34;
CPLeftArrowKeyCode      = 37;
CPUpArrowKeyCode        = 38;
CPRightArrowKeyCode     = 39;
CPDownArrowKeyCode      = 40;
CPDeleteForwardKeyCode  = 46;

/*!
    @ingroup appkit
    @class CPResponder

    Subclasses of CPResonder can be part of the responder chain.
*/
@implementation CPResponder : CPObject
{
    CPMenu      _menu;
    CPResponder _nextResponder;
}

// Changing the first responder
/*!
    Returns \c YES if the receiver is able to become the first responder. \c NO otherwise.
*/
- (BOOL)acceptsFirstResponder
{
    return NO;
}

/*!
    Notifies the receiver that it will become the first responder. The receiver can reject first
    responder if it returns \c NO. The default implementation always returns \c YES.
    @return \c YES if the receiver accepts first responder status.
*/
- (BOOL)becomeFirstResponder
{
    return YES;
}

/*!
    Notifies the receiver that it has been asked to give up first responder status.
    @return \c YES if the receiver is willing to give up first responder status.
*/
- (BOOL)resignFirstResponder
{
    return YES;
}

// Setting the next responder
/*!
    Sets the receiver's next responder.
    @param aResponder the responder after the receiver
*/
- (void)setNextResponder:(CPResponder)aResponder
{
    _nextResponder = aResponder;
}

/*!
    Returns the responder after the receiver.
*/
- (CPResponder)nextResponder
{
    return _nextResponder;
}

/*!
    Called to interpret a series of key events.
    @param events an array of key CPEvents
*/
- (void)interpretKeyEvents:(CPArray)events
{
    var index = 0,
        count = [events count];

    for (; index < count; ++index)
    {
        var event = events[index];

        switch([[event characters] characterAtIndex:0])
        {
            case CPPageUpFunctionKey:       [self doCommandBySelector:@selector(pageUp:)];
                                            break;
            case CPPageDownFunctionKey:     [self doCommandBySelector:@selector(pageDown:)];
                                            break;
            case CPLeftArrowFunctionKey:    [self doCommandBySelector:@selector(moveLeft:)];
                                            break;
            case CPRightArrowFunctionKey:   [self doCommandBySelector:@selector(moveRight:)];
                                            break;
            case CPUpArrowFunctionKey:      [self doCommandBySelector:@selector(moveUp:)];
                                            break;
            case CPDownArrowFunctionKey:    [self doCommandBySelector:@selector(moveDown:)];
                                            break;
            case CPDeleteCharacter:         [self doCommandBySelector:@selector(deleteBackward:)];
                                            break;
            case CPCarriageReturnCharacter:
            case CPNewlineCharacter:        [self doCommandBySelector:@selector(insertLineBreak:)];
                                            break;

            case CPEscapeFunctionKey:       [self doCommandBySelector:@selector(cancel:)];
                                            break;

            case CPTabCharacter:            if (!([event modifierFlags] & CPShiftKeyMask))
                                                [self doCommandBySelector:@selector(insertTab:)];
                                            else
                                                [self doCommandBySelector:@selector(insertBackTab:)];
                                            break;

            default:                        [self insertText:[event characters]];
        }
    }
}

/*!
    Notifies the receiver that the user has clicked the mouse down in its area.
    @param anEvent contains information about the click
*/
- (void)mouseDown:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has clicked the right mouse down in its area.
    @param anEvent contains information about the right click
*/
- (void)rightMouseDown:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has initiated a drag
    over it. A drag is a mouse movement while the left button is down.
    @param anEvent contains information about the drag
*/
- (void)mouseDragged:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has released the left mouse button.
    @param anEvent contains information about the release
*/
- (void)mouseUp:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has released the right mouse button.
    @param anEvent contains information about the release
*/
- (void)rightMouseUp:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has moved the mouse (with no buttons down).
    @param anEvent contains information about the movement
*/
- (void)mouseMoved:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

- (void)mouseEntered:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the mouse exited the receiver's area.
    @param anEvent contains information about the exit
*/
- (void)mouseExited:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the mouse scroll wheel has moved.
    @param anEvent information about the scroll
*/
- (void)scrollWheel:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has pressed a key.
    @param anEvent information about the key press
*/
- (void)keyDown:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has released a key.
    @param anEvent information about the key press
*/
- (void)keyUp:(CPEvent)anEvent
{
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*
    FIXME This description is bad.
    Based on \c anEvent, the receiver should simulate the event.
    @param anEvent the event to simulate
    @return \c YES if the event receiver simulated the  event
*/
- (BOOL)performKeyEquivalent:(CPEvent)anEvent
{
    return NO;
}

// Action Methods
/*!
    Insert a line break at the caret position or selection.
    @param aSender the object requesting this
*/
- (void)insertLineBreak:(id)aSender
{
    [self insertNewline:aSender];
}

/*!
    Insert a line break at the caret position or selection.
    @param aSender the object requesting this
*/
- (void)insertNewline:(id)aSender
{
    [[self nextResponder] insertNewline:aSender];
}

- (void)cancel:(id)sender
{
}

- (void)insertTab:(id)sender
{
}

- (void)insertBackTab:(id)sender
{
}

/*!
    Inserts some text at the caret position or selection.
    @param aString the string to insert
*/
- (void)insertText:(CPString)aString
{
}

// Dispatch methods
/*!
    The receiver will attempt to perform the command,
    if it responds to it. If not, the \c -nextResponder will be called to do it.
    @param aSelector the command to attempt
*/
- (void)doCommandBySelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector])
        [self performSelector:aSelector];
    else
        [_nextResponder doCommandBySelector:aSelector];
}

/*!
    The receiver will attempt to perform the command, or pass it on to the next responder if it doesn't respond to it.
    @param aSelector the command to perform
    @param anObject the argument to the method
    @return \c YES if the receiver was able to perform the command, or a responder down the chain was
    able to perform the command.
*/
- (BOOL)tryToPerform:(SEL)aSelector with:(id)anObject
{
    if([self respondsToSelector:aSelector])
    {
        [self performSelector:aSelector withObject:anObject];

        return YES;
    }

    return [_nextResponder tryToPerform:aSelector with:anObject];
}

// Managing a Responder's menu

- (void)setMenu:(CPMenu)aMenu
{
    _menu = aMenu;
}

- (CPMenu)menu
{
    return _menu;
}

// Getting the Undo Manager
/*!
    Returns the undo manager for the receiver.
*/
- (CPUndoManager)undoManager
{
    return [_nextResponder performSelector:_cmd];
}

// Terminating the responder chain
/*!
    Called when an event finds no suitable responder.
    @param anEventSelector the command that failed
*/
- (void)noResponderFor:(SEL)anEventSelector
{
}

@end

var CPResponderNextResponderKey = @"CPResponderNextResponderKey";

@implementation CPResponder (CPCoding)

/*!
    Initializes the responder with data from a coder.
    @param aCoder the coder from which data will be read
    @return the initialized responder
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];

    if (self)
        _nextResponder = [aCoder decodeObjectForKey:CPResponderNextResponderKey];

    return self;
}

/*!
    Archives the responder to a coder.
    @param aCoder the coder to which the responder will be archived
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    // This will come out nil on the other side with decodeObjectForKey:
    if (_nextResponder !== nil)
        [aCoder encodeConditionalObject:_nextResponder forKey:CPResponderNextResponderKey];
}

@end
