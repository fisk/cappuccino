/*
 * CPObject+Delegation.j
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

@import "CPObject.j"
@import "CPDictionary.j"


@implementation _CPDelegator : CPObject
{
    CPDictionary _blocks;
}

- (id)init
{
    if (self = [super init])
    {
        _blocks = [[CPDictionary alloc] init];
    }
    return self;
}

- (void)addMapping:(SEL)selector to:(var)block
{
    [_blocks setObject:block forKey:selector];
    class_addMethod(_CPDelegator, selector, function(self, _cmd){with(self){
        var block = [_blocks objectForKey:_cmd];
        switch(arguments.length)
        {
            case 2: return block();
            case 3: return block(arguments[2]);
            case 4: return block(arguments[2], arguments[3]);
            case 5: return block(arguments[2], arguments[3], arguments[4]);
        }
    }});
}

@end

@implementation CPObject(CPObject_Delegation)

+ (void)addMappingForDelegateSelector:(SEL)delSel toBlockSelector:(SEL)blockSel
{
    class_addMethod([self class], blockSel, function(self, _cmd, block){with(self){
        var ourDelegate = self.delegate;
        if (ourDelegate == nil || ![ourDelegate isKindOfClass:[_CPDelegator class]])
        {
            ourDelegate = [_CPDelegator new];
        }
        [ourDelegate addMapping:delSel to:block];
        [self setDelegate:ourDelegate];
    }});
}

@end