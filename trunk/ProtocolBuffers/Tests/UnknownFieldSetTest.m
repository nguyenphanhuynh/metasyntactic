//
//  UnknownFieldSetTest.m
//  ProtocolBuffers-Test
//
//  Created by Cyrus Najmabadi on 10/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UnknownFieldSetTest.h"

#import "TestUtilities.h"
#import "Unittest.pb.h"
#import "Macros.h"

@implementation UnknownFieldSetTest

@synthesize descriptor;
@synthesize allFields;
@synthesize allFieldsData;
@synthesize emptyMessage;
@synthesize unknownFields;

- (void) dealloc {
  self.descriptor = nil;
  self.allFields = nil;
  self.allFieldsData = nil;
  self.emptyMessage = nil;
  self.unknownFields = nil;
  [super dealloc];
}


- (void) setUp {
  self.descriptor = [TestAllTypes descriptor];
  self.allFields = [TestUtilities allSet];
  self.allFieldsData = [allFields toData];
  self.emptyMessage = [TestEmptyMessage parseFromData:allFieldsData];
  self.unknownFields = emptyMessage.unknownFields;
}


- (id) init {
  if (self = [super init]) {
    [self setUp];
  }
  return self;
}


- (PBField*) getField:(NSString*) name {
  PBFieldDescriptor* field = [descriptor findFieldByName:name];
  NSAssert(field != nil, @"");
  return [unknownFields getField:field.number];
}


// Constructs a protocol buffer which contains fields with all the same
// numbers as allFieldsData except that each field is some other wire
// type.
- (NSData*) getBizarroData {
  PBUnknownFieldSet_Builder* bizarroFields = [PBUnknownFieldSet newBuilder];
  
  PBField* varintField = [[PBMutableField field] addVarint:1];
  PBField* fixed32Field = [[PBMutableField field] addFixed32:1];
  
  for (NSNumber* key in unknownFields.fields) {
    PBField* field = [unknownFields.fields objectForKey:key];
    if (field.varintList.count == 0) {
      // Original field is not a varint, so use a varint.
      [bizarroFields addField:varintField forNumber:key.intValue];
    } else {
      // Original field *is* a varint, so use something else.
      [bizarroFields addField:fixed32Field forNumber:key.intValue];
    }
  }
  
  return [[bizarroFields build] toData];
}

// =================================================================

- (void) testVarint {
  PBField* field = [self getField:@"optional_int32"];
  NSAssert(1 == field.varintList.count, @"");
  NSAssert(allFields.optionalInt32 == [[field.varintList objectAtIndex:0] intValue], @"");
}


- (void) testFixed32 {
  PBField* field = [self getField:@"optional_fixed32"];
  NSAssert(1 == field.fixed32List.count, @"");
  NSAssert(allFields.optionalFixed32 == [[field.fixed32List objectAtIndex:0] intValue], @"");
}


- (void) testFixed64 {
  PBField* field = [self getField:@"optional_fixed64"];
  NSAssert(1 == field.fixed64List.count, @"");
  NSAssert(allFields.optionalFixed64 == [[field.fixed64List objectAtIndex:0] longLongValue], @"");
}


- (void) testLengthDelimited {
  PBField* field = [self getField:@"optional_bytes"];
  NSAssert(1 == field.lengthDelimitedList.count, @"");
  NSAssert([allFields.optionalBytes isEqual:[field.lengthDelimitedList objectAtIndex:0]], @"");
}

- (void) testGroup {
  PBFieldDescriptor* nestedFieldDescriptor =
  [[TestAllTypes_OptionalGroup descriptor] findFieldByName:@"a"];
  NSAssert(nestedFieldDescriptor != nil, @"");
  
  PBField* field = [self getField:@"optionalgroup"];
  NSAssert(1 == field.groupList.count, @"");
  
  PBUnknownFieldSet* group = [field.groupList objectAtIndex:0];
  NSAssert(1 == group.fields.count, @"");
  NSAssert([group hasField:nestedFieldDescriptor.number], @"");
  
  PBField* nestedField =
  [group getField:nestedFieldDescriptor.number];
  NSAssert(1 == nestedField.varintList.count, @"");
  NSAssert(allFields.optionalGroup.a == [[nestedField.varintList objectAtIndex:0] intValue], @"");
}


#if 0


public void testSerialize() throws Exception {
  // Check that serializing the UnknownFieldSet produces the original data
  // again.
  ByteString data = emptyMessage.toByteString();
  NSAssert(allFieldsData, data);
}

public void testCopyFrom() throws Exception {
  TestEmptyMessage message =
  TestEmptyMessage.newBuilder().mergeFrom(emptyMessage).build();
  
  NSAssert(emptyMessage.toString(), message.toString());
}

public void testMergeFrom() throws Exception {
  TestEmptyMessage source =
  TestEmptyMessage.newBuilder()
  .setUnknownFields(
                    UnknownFieldSet.newBuilder()
                    .addField(2,
                              UnknownFieldSet.Field.newBuilder()
                              .addVarint(2).build())
                    .addField(3,
                              UnknownFieldSet.Field.newBuilder()
                              .addVarint(4).build())
                    .build())
  .build();
  TestEmptyMessage destination =
  TestEmptyMessage.newBuilder()
  .setUnknownFields(
                    UnknownFieldSet.newBuilder()
                    .addField(1,
                              UnknownFieldSet.Field.newBuilder()
                              .addVarint(1).build())
                    .addField(3,
                              UnknownFieldSet.Field.newBuilder()
                              .addVarint(3).build())
                    .build())
  .mergeFrom(source)
  .build();
  
  NSAssert(
           "1: 1\n" +
           "2: 2\n" +
           "3: 3\n" +
           "3: 4\n",
           destination.toString());
}

public void testClear() throws Exception {
  UnknownFieldSet fields =
  UnknownFieldSet.newBuilder().mergeFrom(unknownFields).clear().build();
  assertTrue(fields.asMap().isEmpty());
}

public void testClearMessage() throws Exception {
  TestEmptyMessage message =
  TestEmptyMessage.newBuilder().mergeFrom(emptyMessage).clear().build();
  NSAssert(0, message.getSerializedSize());
}

public void testParseKnownAndUnknown() throws Exception {
  // Test mixing known and unknown fields when parsing.
  
  UnknownFieldSet fields =
  UnknownFieldSet.newBuilder(unknownFields)
  .addField(123456,
            UnknownFieldSet.Field.newBuilder().addVarint(654321).build())
  .build();
  
  ByteString data = fields.toByteString();
  TestAllTypes destination = TestAllTypes.parseFrom(data);
  
  TestUtil.assertAllFieldsSet(destination);
  NSAssert(1, destination.getUnknownFields().asMap().size());
  
  UnknownFieldSet.Field field =
  destination.getUnknownFields().getField(123456);
  NSAssert(1, field.getVarintList().size());
  NSAssert(654321, (long) field.getVarintList().get(0));
}

public void testWrongTypeTreatedAsUnknown() throws Exception {
  // Test that fields of the wrong wire type are treated like unknown fields
  // when parsing.
  
  ByteString bizarroData = getBizarroData();
  TestAllTypes allTypesMessage = TestAllTypes.parseFrom(bizarroData);
  TestEmptyMessage emptyMessage = TestEmptyMessage.parseFrom(bizarroData);
  
  // All fields should have been interpreted as unknown, so the debug strings
  // should be the same.
  NSAssert(emptyMessage.toString(), allTypesMessage.toString());
}

public void testUnknownExtensions() throws Exception {
  // Make sure fields are properly parsed to the UnknownFieldSet even when
  // they are declared as extension numbers.
  
  TestEmptyMessageWithExtensions message =
  TestEmptyMessageWithExtensions.parseFrom(allFieldsData);
  
  NSAssert(unknownFields.asMap().size(),
           message.getUnknownFields().asMap().size());
  NSAssert(allFieldsData, message.toByteString());
}

public void testWrongExtensionTypeTreatedAsUnknown() throws Exception {
  // Test that fields of the wrong wire type are treated like unknown fields
  // when parsing extensions.
  
  ByteString bizarroData = getBizarroData();
  TestAllExtensions allExtensionsMessage =
  TestAllExtensions.parseFrom(bizarroData);
  TestEmptyMessage emptyMessage = TestEmptyMessage.parseFrom(bizarroData);
  
  // All fields should have been interpreted as unknown, so the debug strings
  // should be the same.
  NSAssert(emptyMessage.toString(),
           allExtensionsMessage.toString());
}

public void testParseUnknownEnumValue() throws Exception {
  Descriptors.FieldDescriptor singularField =
  TestAllTypes.getDescriptor().findFieldByName("optional_nested_enum");
  Descriptors.FieldDescriptor repeatedField =
  TestAllTypes.getDescriptor().findFieldByName("repeated_nested_enum");
  assertNotNull(singularField);
  assertNotNull(repeatedField);
  
  ByteString data =
  UnknownFieldSet.newBuilder()
  .addField(singularField.getNumber(),
            UnknownFieldSet.Field.newBuilder()
            .addVarint(TestAllTypes.NestedEnum.BAR.getNumber())
            .addVarint(5)   // not valid
            .build())
  .addField(repeatedField.getNumber(),
            UnknownFieldSet.Field.newBuilder()
            .addVarint(TestAllTypes.NestedEnum.FOO.getNumber())
            .addVarint(4)   // not valid
            .addVarint(TestAllTypes.NestedEnum.BAZ.getNumber())
            .addVarint(6)   // not valid
            .build())
  .build()
  .toByteString();
  
  {
    TestAllTypes message = TestAllTypes.parseFrom(data);
    NSAssert(TestAllTypes.NestedEnum.BAR,
             message.getOptionalNestedEnum());
    NSAssert(
             Arrays.asList(TestAllTypes.NestedEnum.FOO, TestAllTypes.NestedEnum.BAZ),
             message.getRepeatedNestedEnumList());
    NSAssert(Arrays.asList(5L),
             message.getUnknownFields()
             .getField(singularField.getNumber())
             .getVarintList());
    NSAssert(Arrays.asList(4L, 6L),
             message.getUnknownFields()
             .getField(repeatedField.getNumber())
             .getVarintList());
  }
  
  {
    TestAllExtensions message =
    TestAllExtensions.parseFrom(data, TestUtil.getExtensionRegistry());
    NSAssert(TestAllTypes.NestedEnum.BAR,
             message.getExtension(UnittestProto.optionalNestedEnumExtension));
    NSAssert(
             Arrays.asList(TestAllTypes.NestedEnum.FOO, TestAllTypes.NestedEnum.BAZ),
             message.getExtension(UnittestProto.repeatedNestedEnumExtension));
    NSAssert(Arrays.asList(5L),
             message.getUnknownFields()
             .getField(singularField.getNumber())
             .getVarintList());
    NSAssert(Arrays.asList(4L, 6L),
             message.getUnknownFields()
             .getField(repeatedField.getNumber())
             .getVarintList());
  }
}

public void testLargeVarint() throws Exception {
  ByteString data =
  UnknownFieldSet.newBuilder()
  .addField(1,
            UnknownFieldSet.Field.newBuilder()
            .addVarint(0x7FFFFFFFFFFFFFFFL)
            .build())
  .build()
  .toByteString();
  UnknownFieldSet parsed = UnknownFieldSet.parseFrom(data);
  UnknownFieldSet.Field field = parsed.getField(1);
  NSAssert(1, field.getVarintList().size());
  NSAssert(0x7FFFFFFFFFFFFFFFL, (long)field.getVarintList().get(0));
}
#endif

+ (void) runAllTests {
  [[[[UnknownFieldSetTest alloc] init] autorelease] testVarint];
  [[[[UnknownFieldSetTest alloc] init] autorelease] testFixed32];
  [[[[UnknownFieldSetTest alloc] init] autorelease] testFixed64];
  [[[[UnknownFieldSetTest alloc] init] autorelease] testLengthDelimited];
  [[[[UnknownFieldSetTest alloc] init] autorelease] testGroup];
  
}


@end
