// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "UnittestEmbedOptimizeFor.pb.h"

@implementation UnittestEmbedOptimizeForProtoRoot
static PBFileDescriptor* descriptor = nil;
static PBDescriptor* internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor = nil;
static PBFieldAccessorTable* internal_static_protobuf_unittest_TestEmbedOptimizedForSize_fieldAccessorTable = nil;
+ (PBDescriptor*) internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor {
  return internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor;
}
+ (PBFieldAccessorTable*) internal_static_protobuf_unittest_TestEmbedOptimizedForSize_fieldAccessorTable {
  return internal_static_protobuf_unittest_TestEmbedOptimizedForSize_fieldAccessorTable;
}
+ (void) initialize {
  if (self == [UnittestEmbedOptimizeForProtoRoot class]) {
    descriptor = [[UnittestEmbedOptimizeForProtoRoot buildDescriptor] retain];
    internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor = [[[self descriptor].messageTypes objectAtIndex:0] retain];
    {
      NSArray* fieldNames = [NSArray arrayWithObjects:@"OptionalMessage", @"RepeatedMessage", nil];
      internal_static_protobuf_unittest_TestEmbedOptimizedForSize_fieldAccessorTable = 
        [[PBFieldAccessorTable tableWithDescriptor:internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor
                                        fieldNames:fieldNames
                                      messageClass:[TestEmbedOptimizedForSize class]
                                      builderClass:[TestEmbedOptimizedForSize_Builder class]] retain];
    }
  }
}
+ (PBFileDescriptor*) descriptor {
  return descriptor;
}
+ (PBFileDescriptor*) buildDescriptor {
  static uint8_t descriptorData[] = {
    10,49,103,111,111,103,108,101,47,112,114,111,116,111,98,117,102,47,117,
    110,105,116,116,101,115,116,95,101,109,98,101,100,95,111,112,116,105,109,
    105,122,101,95,102,111,114,46,112,114,111,116,111,18,17,112,114,111,116,
    111,98,117,102,95,117,110,105,116,116,101,115,116,26,43,103,111,111,103,
    108,101,47,112,114,111,116,111,98,117,102,47,117,110,105,116,116,101,115,
    116,95,111,112,116,105,109,105,122,101,95,102,111,114,46,112,114,111,116,
    111,34,161,1,10,25,84,101,115,116,69,109,98,101,100,79,112,116,105,109,
    105,122,101,100,70,111,114,83,105,122,101,18,65,10,16,111,112,116,105,111,
    110,97,108,95,109,101,115,115,97,103,101,24,1,32,1,40,11,50,39,46,112,114,
    111,116,111,98,117,102,95,117,110,105,116,116,101,115,116,46,84,101,115,
    116,79,112,116,105,109,105,122,101,100,70,111,114,83,105,122,101,18,65,
    10,16,114,101,112,101,97,116,101,100,95,109,101,115,115,97,103,101,24,2,
    32,3,40,11,50,39,46,112,114,111,116,111,98,117,102,95,117,110,105,116,116,
    101,115,116,46,84,101,115,116,79,112,116,105,109,105,122,101,100,70,111,
    114,83,105,122,101,66,2,72,1,
  };
  NSArray* dependencies = [NSArray arrayWithObjects:[UnittestOptimizeForProtoRoot descriptor], nil];
  
  NSData* data = [NSData dataWithBytes:descriptorData length:283];
  PBFileDescriptorProto* proto = [PBFileDescriptorProto parseFromData:data];
  return [PBFileDescriptor buildFrom:proto dependencies:dependencies];
}
@end

@interface TestEmbedOptimizedForSize ()
@property BOOL hasOptionalMessage;
@property (retain) TestOptimizedForSize* optionalMessage;
@property (retain) NSMutableArray* mutableRepeatedMessageList;
@end

@implementation TestEmbedOptimizedForSize

@synthesize hasOptionalMessage;
@synthesize optionalMessage;
@synthesize mutableRepeatedMessageList;
- (void) dealloc {
  self.hasOptionalMessage = NO;
  self.optionalMessage = nil;
  self.mutableRepeatedMessageList = nil;
  [super dealloc];
}
- (id) init {
  if (self = [super init]) {
    self.optionalMessage = [TestOptimizedForSize defaultInstance];
  }
  return self;
}
static TestEmbedOptimizedForSize* defaultTestEmbedOptimizedForSizeInstance = nil;
+ (void) initialize {
  if (self == [TestEmbedOptimizedForSize class]) {
    defaultTestEmbedOptimizedForSizeInstance = [[TestEmbedOptimizedForSize alloc] init];
  }
}
+ (TestEmbedOptimizedForSize*) defaultInstance {
  return defaultTestEmbedOptimizedForSizeInstance;
}
- (TestEmbedOptimizedForSize*) defaultInstance {
  return defaultTestEmbedOptimizedForSizeInstance;
}
- (PBDescriptor*) descriptor {
  return [TestEmbedOptimizedForSize descriptor];
}
+ (PBDescriptor*) descriptor {
  return [UnittestEmbedOptimizeForProtoRoot internal_static_protobuf_unittest_TestEmbedOptimizedForSize_descriptor];
}
- (PBFieldAccessorTable*) internalGetFieldAccessorTable {
  return [UnittestEmbedOptimizeForProtoRoot internal_static_protobuf_unittest_TestEmbedOptimizedForSize_fieldAccessorTable];
}
- (NSArray*) repeatedMessageList {
  return mutableRepeatedMessageList;
}
- (TestOptimizedForSize*) repeatedMessageAtIndex:(int32_t) index {
  id value = [mutableRepeatedMessageList objectAtIndex:index];
  return value;
}
- (BOOL) isInitialized {
  if (self.hasOptionalMessage) {
    if (!self.optionalMessage.isInitialized) return false;
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    if (!element.isInitialized) return false;
  }
  return true;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasOptionalMessage) {
    [output writeMessage:1 value:self.optionalMessage];
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    [output writeMessage:2 value:element];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size = memoizedSerializedSize;
  if (size != -1) return size;

  size = 0;
  if (self.hasOptionalMessage) {
    size += computeMessageSize(1, self.optionalMessage);
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    size += computeMessageSize(2, element);
  }
  size += self.unknownFields.serializedSize;
  memoizedSerializedSize = size;
  return size;
}
+ (TestEmbedOptimizedForSize*) parseFromData:(NSData*) data {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromData:data] build];
}
+ (TestEmbedOptimizedForSize*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize*) parseFromInputStream:(NSInputStream*) input {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromInputStream:input] build];
}
+ (TestEmbedOptimizedForSize*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromCodedInputStream:input] build];
}
+ (TestEmbedOptimizedForSize*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize_Builder*) builder {
  return [[[TestEmbedOptimizedForSize_Builder alloc] init] autorelease];
}
+ (TestEmbedOptimizedForSize_Builder*) builderWithPrototype:(TestEmbedOptimizedForSize*) prototype {
  return [[TestEmbedOptimizedForSize builder] mergeFromTestEmbedOptimizedForSize:prototype];
}
- (TestEmbedOptimizedForSize_Builder*) builder {
  return [TestEmbedOptimizedForSize builder];
}
@end

@implementation TestEmbedOptimizedForSize_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if (self = [super init]) {
    self.result = [[[TestEmbedOptimizedForSize alloc] init] autorelease];
  }
  return self;
}
- (TestEmbedOptimizedForSize*) internalGetResult {
  return result;
}
- (TestEmbedOptimizedForSize_Builder*) clear {
  self.result = [[[TestEmbedOptimizedForSize alloc] init] autorelease];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clone {
  return [TestEmbedOptimizedForSize builderWithPrototype:result];
}
- (PBDescriptor*) descriptor {
  return [TestEmbedOptimizedForSize descriptor];
}
- (TestEmbedOptimizedForSize*) defaultInstance {
  return [TestEmbedOptimizedForSize defaultInstance];
}
- (TestEmbedOptimizedForSize*) build {
  if (!self.isInitialized) {
    @throw [NSException exceptionWithName:@"UninitializedMessage" reason:@"" userInfo:nil];
  }
  return [self buildPartial];
}
- (TestEmbedOptimizedForSize*) buildPartial {
  TestEmbedOptimizedForSize* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromMessage:(id<PBMessage>) other {
  id o = other;
  if ([o isKindOfClass:[TestEmbedOptimizedForSize class]]) {
    return [self mergeFromTestEmbedOptimizedForSize:o];
  } else {
    [super mergeFromMessage:other];
    return self;
  }
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromTestEmbedOptimizedForSize:(TestEmbedOptimizedForSize*) other {
  if (other == [TestEmbedOptimizedForSize defaultInstance]) return self;
  if (other.hasOptionalMessage) {
    [self mergeOptionalMessage:other.optionalMessage];
  }
  if (other.mutableRepeatedMessageList.count > 0) {
    if (result.mutableRepeatedMessageList == nil) {
      result.mutableRepeatedMessageList = [NSMutableArray array];
    }
    [result.mutableRepeatedMessageList addObjectsFromArray:other.mutableRepeatedMessageList];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSet_Builder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (true) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        TestOptimizedForSize_Builder* subBuilder = [TestOptimizedForSize builder];
        if (self.hasOptionalMessage) {
          [subBuilder mergeFromTestOptimizedForSize:self.optionalMessage];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setOptionalMessage:[subBuilder buildPartial]];
        break;
      }
      case 18: {
        TestOptimizedForSize_Builder* subBuilder = [TestOptimizedForSize builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addRepeatedMessage:[subBuilder buildPartial]];
        break;
      }
    }
  }
}
- (BOOL) hasOptionalMessage {
  return result.hasOptionalMessage;
}
- (TestOptimizedForSize*) optionalMessage {
  return result.optionalMessage;
}
- (TestEmbedOptimizedForSize_Builder*) setOptionalMessage:(TestOptimizedForSize*) value {
  result.hasOptionalMessage = YES;
  result.optionalMessage = value;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) setOptionalMessageBuilder:(TestOptimizedForSize_Builder*) builderForValue {
  return [self setOptionalMessage:[builderForValue build]];
}
- (TestEmbedOptimizedForSize_Builder*) mergeOptionalMessage:(TestOptimizedForSize*) value {
  if (result.hasOptionalMessage &&
      result.optionalMessage != [TestOptimizedForSize defaultInstance]) {
    result.optionalMessage =
      [[[TestOptimizedForSize builderWithPrototype:result.optionalMessage] mergeFromTestOptimizedForSize:value] buildPartial];
  } else {
    result.optionalMessage = value;
  }
  result.hasOptionalMessage = YES;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clearOptionalMessage {
  result.hasOptionalMessage = NO;
  result.optionalMessage = [TestOptimizedForSize defaultInstance];
  return self;
}
- (NSArray*) repeatedMessageList {
  if (result.mutableRepeatedMessageList == nil) { return [NSArray array]; }
  return result.mutableRepeatedMessageList;
}
- (TestOptimizedForSize*) repeatedMessageAtIndex:(int32_t) index {
  return [result repeatedMessageAtIndex:index];
}
- (TestEmbedOptimizedForSize_Builder*) replaceRepeatedMessageAtIndex:(int32_t) index withRepeatedMessage:(TestOptimizedForSize*) value {
  [result.mutableRepeatedMessageList replaceObjectAtIndex:index withObject:value];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) addAllRepeatedMessage:(NSArray*) values {
  if (result.mutableRepeatedMessageList == nil) {
    result.mutableRepeatedMessageList = [NSMutableArray array];
  }
  [result.mutableRepeatedMessageList addObjectsFromArray:values];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clearRepeatedMessageList {
  result.mutableRepeatedMessageList = nil;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) addRepeatedMessage:(TestOptimizedForSize*) value {
  if (result.mutableRepeatedMessageList == nil) {
    result.mutableRepeatedMessageList = [NSMutableArray array];
  }
  [result.mutableRepeatedMessageList addObject:value];
  return self;
}
@end

