// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "XmlElement.h"

@implementation XmlElement

@synthesize name;
@synthesize attributes;
@synthesize children;
@synthesize text;

- (void) dealloc {
    self.name = nil;
    self.attributes = nil;
    self.children = nil;
    self.text = nil;
    [super dealloc];
}


+ (id) elementWithName:(NSString*) name_ {
    return [XmlElement elementWithName:name_ attributes:[NSDictionary dictionary] children:[NSArray array] text:[NSString string]];
}


+ (id) elementWithName:(NSString*) name_
            attributes:(NSDictionary*) attributes_ {
    return [XmlElement elementWithName:name_ attributes:attributes_ children:[NSArray array] text:[NSString string]];
}


+ (id) elementWithName:(NSString*) name_
                  text:(NSString*) text_ {
    return [XmlElement elementWithName:name_ attributes:[NSDictionary dictionary] children:[NSArray array] text:text_];
}


+ (id) elementWithName:(NSString*) name_
              children:(NSArray*) children_ {
    return [XmlElement elementWithName:name_ attributes:[NSDictionary dictionary] children:children_ text:[NSString string]];
}


+ (id) elementWithName:(NSString*) name_
            attributes:(NSDictionary*) attributes_
              children:(NSArray*) children_ {
    return [XmlElement elementWithName:name_ attributes:attributes_ children:children_ text:[NSString string]];
}


+ (id) elementWithName:(NSString*) name_
            attributes:(NSDictionary*) attributes_
                  text:(NSString*) text_ {
    return [XmlElement elementWithName:name_ attributes:attributes_ children:[NSArray array] text:text_];
}


+ (id) elementWithName:(NSString*) name_
              children:(NSArray*) children_
                  text:(NSString*) text_ {
    return [XmlElement elementWithName:name_ attributes:[NSDictionary dictionary] children:children_ text:text_];
}


+ (id) elementWithName:(NSString*) name_
            attributes:(NSDictionary*) attributes_
              children:(NSArray*) children_
                  text:(NSString*) text_ {
    return [[[XmlElement alloc] initWithName:name_ attributes:attributes_ children:children_ text:text_] autorelease];
}


- (id) initWithName:(NSString*) name_
         attributes:(NSDictionary*) attributes_
           children:(NSArray*) children_
               text:(NSString*) text_ {
    if (self = [super init]) {
        self.name = name_;
        self.attributes = attributes_;
        self.children = children_;
        self.text = text_;
    }

    return self;
}


- (NSString*) description {
    return [[self dictionary] description];
}


- (NSDictionary*) dictionary {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];

    NSMutableArray* array = [NSMutableArray array];
    for (XmlElement* element in self.children) {
        [array addObject:element.dictionary];
    }

    [dictionary setValue:self.name forKey:@"name"];

    if (![self.text isEqual:@""]) {
        [dictionary setValue:self.text forKey:@"text"];
    }

    if (attributes.count > 0) {
        [dictionary setValue:self.attributes forKey:@"attributes"];
    }

    if (array.count > 0) {
        [dictionary setValue:array forKey:@"children"];
    }

    return dictionary;
}


+ (XmlElement*) elementFromDictionary:(NSDictionary*) dictionary {
    NSString* name = [dictionary valueForKey:@"name"];
    if (name == nil) {
        name = @"";
    }

    NSString* text = [dictionary valueForKey:@"text"];
    if (text == nil) {
        text = @"";
    }

    NSDictionary* attributes = [dictionary valueForKey:@"attributes"];
    if (attributes == nil) {
        attributes = [NSDictionary dictionary];
    }

    NSArray* childDictionaries = [dictionary valueForKey:@"children"];
    if (childDictionaries == nil) {
        childDictionaries = [NSArray array];
    }

    NSMutableArray* children = [NSMutableArray array];
    for (NSDictionary* childDict in childDictionaries) {
        [children addObject:[XmlElement elementFromDictionary:childDict]];
    }

    return [XmlElement elementWithName:name attributes:attributes children:children text:text];
}


- (XmlElement*) element:(NSString*) name_ {
    for (XmlElement* child in self.children) {
        if ([name_ isEqualToString:child.name]) {
            return child;
        }
    }

    return nil;
}


- (NSArray*) elements:(NSString*) name_ {
    NSMutableArray* array = [NSMutableArray array];
    for (XmlElement* child in self.children) {
        if ([name_ isEqualToString:child.name]) {
            [array addObject:child];
        }
    }

    return array;
}


- (XmlElement*) elementAtIndex:(NSInteger) index {
    if (index >= 0 && index < self.children.count) {
        return [[self children] objectAtIndex:index];
    }

    return nil;
}


- (NSString*) attributeValue:(NSString*) key {
    return [self.attributes valueForKey:key];
}


@end