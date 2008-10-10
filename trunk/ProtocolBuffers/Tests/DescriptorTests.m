//
//  DescriptorTests.m
//  ProtocolBuffers
//
//  Created by Cyrus Najmabadi on 10/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DescriptorTests.h"

#import "Unittest.pb.h"
#import "UnittestImport.pb.h"

@implementation DescriptorTests

- (void) testFileDescriptor {
    PBFileDescriptor* file = [UnittestProtoRoot descriptor];
    
    STAssertEqualObjects(@"google/protobuf/unittest.proto", file.name, @"");
    STAssertEqualObjects(@"protobuf_unittest", file.package, @"");
    
    STAssertEqualObjects(@"UnittestProto", file.options.javaOuterClassname, @"");
    STAssertEqualObjects(@"google/protobuf/unittest.proto", file.proto.name, @"");
    
    STAssertEqualObjects([NSArray arrayWithObject:[UnittestImportProtoRoot descriptor]],
                         file.dependencies, @"");
    
    PBDescriptor* messageType = [TestAllTypes descriptor];
    STAssertEqualObjects(messageType, [file.messageTypes objectAtIndex:0], @"");
    STAssertEqualObjects(messageType, [file findMessageTypeByName:@"TestAllTypes"], @"");
    STAssertNil([file findMessageTypeByName:@"NoSuchType"], @"");
    STAssertNil([file findMessageTypeByName:@"protobuf_unittest.TestAllTypes"], @"");
    for (int i = 0; i < file.messageTypes.count; i++) {
        STAssertTrue(i == [[file.messageTypes objectAtIndex:i] index], @"");
    }
    
    PBEnumDescriptor* enumType = [ForeignEnum descriptor];
    STAssertEqualObjects(enumType, [file.enumTypes objectAtIndex:0], @"");
    STAssertEqualObjects(enumType, [file findEnumTypeByName:@"ForeignEnum"], @"");
    STAssertNil([file findEnumTypeByName:@"NoSuchType"], @"");
    STAssertNil([file findEnumTypeByName:@"protobuf_unittest.ForeignEnum"], @"");
    STAssertEqualObjects([NSArray arrayWithObject:[ImportEnum descriptor]],
                         [[UnittestImportProtoRoot descriptor] enumTypes], @"");
    for (int i = 0; i < file.enumTypes.count; i++) {
        STAssertTrue(i == [[file.enumTypes objectAtIndex:i] index], @"");
    }
    
    PBServiceDescriptor* service = [TestService descriptor];
    STAssertEqualObjects(service, [file.services objectAtIndex:0], @"");
    STAssertEqualObjects(service, [file findServiceByName:@"TestService"], @"");
    STAssertNil([file findServiceByName:@"NoSuchType"], @"");
    STAssertNil([file findServiceByName:@"protobuf_unittest.TestService"], @"");
    STAssertEqualObjects([NSArray array],
                 [[UnittestImportProtoRoot descriptor] services], @"");
    for (int i = 0; i < file.services.count; i++) {
        STAssertTrue(i == [[file.services objectAtIndex:i] index], @"");
    }
    
    PBFieldDescriptor* extension =
    [[UnittestProtoRoot optionalInt32Extension] descriptor];
    STAssertEqualObjects(extension, [file.extensions objectAtIndex:0], @"");
    STAssertEqualObjects(extension,
                         [file findExtensionByName:@"optional_int32_extension"], @"");
    STAssertNil([file findExtensionByName:@"no_such_ext"], @"");
    STAssertNil([file findExtensionByName:@"protobuf_unittest.optional_int32_extension"], @"");
    STAssertEqualObjects([NSArray array],
                         [[UnittestImportProtoRoot descriptor] extensions], @"");
    for (int i = 0; i < file.extensions.count; i++) {
        STAssertTrue(i == [[file.extensions objectAtIndex:i] index], @"");
    }
}


- (void) testDescriptor {
    PBDescriptor* messageType = [TestAllTypes descriptor];
    PBDescriptor* nestedType = [TestAllTypes_NestedMessage descriptor];
    
    STAssertEqualObjects(@"TestAllTypes", messageType.name, @"");
    STAssertEqualObjects(@"protobuf_unittest.TestAllTypes", messageType.fullName, @"");
    STAssertEqualObjects([UnittestProtoRoot descriptor], messageType.file, @"");
    STAssertNil(messageType.containingType, @"");
    STAssertEqualObjects([PBMessageOptions defaultInstance],
                 messageType.options, @"");
    STAssertEqualObjects(@"TestAllTypes", messageType.proto.name, @"");
    
    STAssertEqualObjects(@"NestedMessage", nestedType.name, @"");
    STAssertEqualObjects(@"protobuf_unittest.TestAllTypes.NestedMessage",
                 nestedType.fullName, @"");
    STAssertEqualObjects([UnittestProtoRoot descriptor], nestedType.file, @"");
    STAssertEqualObjects(messageType, nestedType.containingType, @"");
    
    PBFieldDescriptor* field = [messageType.fields objectAtIndex:0];
    STAssertEqualObjects(@"optional_int32", field.name, @"");
    STAssertEqualObjects(field, [messageType findFieldByName:@"optional_int32"], @"");
    STAssertNil([messageType findFieldByName:@"no_such_field"], @"");
    STAssertEqualObjects(field, [messageType findFieldByNumber:1], @"");
    STAssertNil([messageType findFieldByNumber:571283], @"");
    for (int i = 0; i < messageType.fields.count; i++) {
        STAssertTrue(i == [[messageType.fields objectAtIndex:i] index], @"");
    }
    
    STAssertEqualObjects(nestedType, [messageType.nestedTypes objectAtIndex:0], @"");
    STAssertEqualObjects(nestedType, [messageType findNestedTypeByName:@"NestedMessage"], @"");
    STAssertNil([messageType findNestedTypeByName:@"NoSuchType"], @"");
    for (int i = 0; i < messageType.nestedTypes.count; i++) {
        STAssertTrue(i == [[messageType.nestedTypes objectAtIndex:i] index], @"");
    }
    
    PBEnumDescriptor* enumType = [TestAllTypes_NestedEnum descriptor];
    STAssertEqualObjects(enumType, [messageType.enumTypes objectAtIndex:0], @"");
    STAssertEqualObjects(enumType, [messageType findEnumTypeByName:@"NestedEnum"], @"");
    STAssertNil([messageType findEnumTypeByName:@"NoSuchType"], @"");
    for (int i = 0; i < messageType.enumTypes.count; i++) {
        STAssertTrue(i == [[messageType.enumTypes objectAtIndex:i] index], @"");
    }
}


- (void) testFieldDescriptor {
    PBDescriptor* messageType = [TestAllTypes descriptor];
    PBFieldDescriptor* primitiveField = [messageType findFieldByName:@"optional_int32"];
    PBFieldDescriptor* enumField = [messageType findFieldByName:@"optional_nested_enum"];
    PBFieldDescriptor* messageField = [messageType findFieldByName:@"optional_foreign_message"];
    PBFieldDescriptor* cordField = [messageType findFieldByName:@"optional_cord"];
    PBFieldDescriptor* extension = [[UnittestProtoRoot optionalInt32Extension] descriptor];
    PBFieldDescriptor* nestedExtension = [[TestRequired single] descriptor];
    
    STAssertEqualObjects(@"optional_int32", primitiveField.name, @"");
    STAssertEqualObjects(@"protobuf_unittest.TestAllTypes.optional_int32",
                 primitiveField.fullName, @"");
    STAssertEquals(1, primitiveField.number, @"");
    STAssertEqualObjects(messageType, primitiveField.containingType, @"");
    STAssertEqualObjects([UnittestProtoRoot descriptor], primitiveField.file, @"");
    STAssertEquals(PBFieldDescriptorTypeInt32, primitiveField.type, @"");
    STAssertEquals(PBObjectiveCTypeInt32, primitiveField.objectiveCType, @"");
    STAssertEqualObjects([PBFieldOptions defaultInstance],
                 primitiveField.options, @"");
    STAssertFalse(primitiveField.isExtension, @"");
    STAssertEqualObjects(@"optional_int32", primitiveField.proto.name, @"");
    
    STAssertEqualObjects(@"optional_nested_enum", enumField.name, @"");
    STAssertEquals(PBFieldDescriptorTypeEnum, enumField.type, @"");
    STAssertEquals(PBObjectiveCTypeEnum, enumField.objectiveCType, @"");
    STAssertEqualObjects([TestAllTypes_NestedEnum descriptor],
                 enumField.enumType, @"");
    
    STAssertEqualObjects(@"optional_foreign_message", messageField.name, @"");
    STAssertEquals(PBFieldDescriptorTypeMessage, messageField.type, @"");
    STAssertEquals(PBObjectiveCTypeMessage, messageField.objectiveCType, @"");
    STAssertEqualObjects([ForeignMessage descriptor], messageField.messageType, @"");
    
    STAssertEqualObjects(@"optional_cord", cordField.name, @"");
    STAssertEquals(PBFieldDescriptorTypeString, cordField.type, @"");
    STAssertEquals(PBObjectiveCTypeString, cordField.objectiveCType, @"");
    STAssertEqualObjects([PBFieldOptions_CType CORD],
                 cordField.options.ctype, @"");
    
    STAssertEqualObjects(@"optional_int32_extension", extension.name, @"");
    STAssertEqualObjects(@"protobuf_unittest.optional_int32_extension",
                 extension.fullName, @"");
    STAssertEquals(1, extension.number, @"");
    STAssertEqualObjects([TestAllExtensions descriptor],
                 extension.containingType, @"");
    STAssertEqualObjects([UnittestProtoRoot descriptor], extension.file, @"");
    STAssertEquals(PBFieldDescriptorTypeInt32, extension.type, @"");
    STAssertEquals(PBObjectiveCTypeInt32, extension.objectiveCType, @"");
    STAssertEqualObjects([PBFieldOptions defaultInstance],
                 extension.options, @"");
    STAssertTrue(extension.isExtension, @"");
    STAssertEqualObjects(nil, extension.extensionScope, @"");
    STAssertEqualObjects(@"optional_int32_extension", extension.proto.name, @"");
    
    STAssertEqualObjects(@"single", nestedExtension.name, @"");
    STAssertEqualObjects(@"protobuf_unittest.TestRequired.single",
                 nestedExtension.fullName, @"");
    STAssertEqualObjects([TestRequired descriptor],
                 nestedExtension.extensionScope, @"");
}

#if 0
public void testFieldDescriptorLabel() throws Exception {
    PBFieldDescriptor* requiredField =
    TestRequired.getDescriptor().findFieldByName(@"a");
    PBFieldDescriptor* optionalField =
    [TestAllTypes descriptor].findFieldByName(@"optional_int32");
    PBFieldDescriptor* repeatedField =
    [TestAllTypes descriptor].findFieldByName(@"repeated_int32");
    
    STAssertTrue(requiredField.isRequired());
    STAssertFalse(requiredField.isRepeated());
    STAssertFalse(optionalField.isRequired());
    STAssertFalse(optionalField.isRepeated());
    STAssertFalse(repeatedField.isRequired());
    STAssertTrue(repeatedField.isRepeated());
}

public void testFieldDescriptorDefault() throws Exception {
    PBDescriptor* d = [TestAllTypes descriptor];
    STAssertFalse(d.findFieldByName(@"optional_int32").hasDefaultValue());
    STAssertEqualObjects(0, d.findFieldByName(@"optional_int32").getDefaultValue());
    STAssertTrue(d.findFieldByName(@"default_int32").hasDefaultValue());
    STAssertEqualObjects(41, d.findFieldByName(@"default_int32").getDefaultValue());
    
    d = TestExtremeDefaultValues.getDescriptor();
    STAssertEqualObjects(
                 ByteString.copyFrom(
                                     "\0\001\007\b\f\n\r\t\013\\\'\"\u00fe".getBytes(@"ISO-8859-1")),
                 d.findFieldByName(@"escaped_bytes").getDefaultValue());
    STAssertEqualObjects(-1, d.findFieldByName(@"large_uint32").getDefaultValue());
    STAssertEqualObjects(-1L, d.findFieldByName(@"large_uint64").getDefaultValue());
}

public void testEnumDescriptor() throws Exception {
    PBEnumDescriptor* enumType = ForeignEnum.getDescriptor();
    PBEnumDescriptor* nestedType = TestAllTypes.NestedEnum.getDescriptor();
    
    STAssertEqualObjects(@"ForeignEnum", enumType.getName());
    STAssertEqualObjects(@"protobuf_unittest.ForeignEnum", enumType.getFullName());
    STAssertEqualObjects([UnittestProtoRoot descriptor], enumType.file);
    STAssertNil(enumType.getContainingType());
    STAssertEqualObjects(DescriptorProtos.EnumOptions.getDefaultInstance(),
                 enumType.options);
    
    STAssertEqualObjects(@"NestedEnum", nestedType.getName());
    STAssertEqualObjects(@"protobuf_unittest.TestAllTypes.NestedEnum",
                 nestedType.getFullName());
    STAssertEqualObjects([UnittestProtoRoot descriptor], nestedType.file);
    STAssertEqualObjects([TestAllTypes descriptor], nestedType.getContainingType());
    
    EnumValueDescriptor value = ForeignEnum.FOREIGN_FOO.getValueDescriptor();
    STAssertEqualObjects(value, enumType.getValues().get(0));
    STAssertEqualObjects(@"FOREIGN_FOO", value.getName());
    STAssertEqualObjects(4, value.getNumber());
    STAssertEqualObjects(value, enumType.findValueByName(@"FOREIGN_FOO"));
    STAssertEqualObjects(value, enumType.findValueByNumber(4));
    STAssertNil(enumType.findValueByName(@"NO_SUCH_VALUE"));
    for (int i = 0; i < enumType.getValues().size(); i++) {
        STAssertEqualObjects(i, enumType.getValues().get(i).getIndex());
    }
}

public void testServiceDescriptor() throws Exception {
    PBServiceDescriptor* service = TestService.getDescriptor();
    
    STAssertEqualObjects(@"TestService", service.getName());
    STAssertEqualObjects(@"protobuf_unittest.TestService", service.getFullName());
    STAssertEqualObjects([UnittestProtoRoot descriptor], service.file);
    
    STAssertEqualObjects(2, service.getMethods().size());
    
    MethodDescriptor fooMethod = service.getMethods().get(0);
    STAssertEqualObjects(@"Foo", fooMethod.getName());
    STAssertEqualObjects(UnittestProto.FooRequest.getDescriptor(),
                 fooMethod.getInputType());
    STAssertEqualObjects(UnittestProto.FooResponse.getDescriptor(),
                 fooMethod.getOutputType());
    STAssertEqualObjects(fooMethod, service.findMethodByName(@"Foo"));
    
    MethodDescriptor barMethod = service.getMethods().get(1);
    STAssertEqualObjects(@"Bar", barMethod.getName());
    STAssertEqualObjects(UnittestProto.BarRequest.getDescriptor(),
                 barMethod.getInputType());
    STAssertEqualObjects(UnittestProto.BarResponse.getDescriptor(),
                 barMethod.getOutputType());
    STAssertEqualObjects(barMethod, service.findMethodByName(@"Bar"));
    
    STAssertNil(service.findMethodByName(@"NoSuchMethod"));
    
    for (int i = 0; i < service.getMethods().size(); i++) {
        STAssertEqualObjects(i, service.getMethods().get(i).getIndex());
    }
}


#endif

@end
