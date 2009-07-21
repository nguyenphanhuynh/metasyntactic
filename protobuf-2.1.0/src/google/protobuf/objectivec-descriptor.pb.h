// Generated by the protocol buffer compiler.  DO NOT EDIT!

#ifndef PROTOBUF_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto__INCLUDED
#define PROTOBUF_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto__INCLUDED

#include <string>

#include <google/protobuf/stubs/common.h>

#if GOOGLE_PROTOBUF_VERSION < 2001000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please update
#error your headers.
#endif
#if 2001000 < GOOGLE_PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/repeated_field.h>
#include <google/protobuf/extension_set.h>
#include "google/protobuf/descriptor.pb.h"

namespace google {
namespace protobuf {

// Internal implementation detail -- do not call these.
void  protobuf_AddDesc_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();
void protobuf_AssignDesc_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();
void protobuf_ShutdownFile_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();

class ObjectiveCFileOptions;

// ===================================================================

class ObjectiveCFileOptions : public ::google::protobuf::Message {
 public:
  ObjectiveCFileOptions();
  virtual ~ObjectiveCFileOptions();
  
  ObjectiveCFileOptions(const ObjectiveCFileOptions& from);
  
  inline ObjectiveCFileOptions& operator=(const ObjectiveCFileOptions& from) {
    CopyFrom(from);
    return *this;
  }
  
  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }
  
  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }
  
  static const ::google::protobuf::Descriptor* descriptor();
  static const ObjectiveCFileOptions& default_instance();
  void Swap(ObjectiveCFileOptions* other);
  
  // implements Message ----------------------------------------------
  
  ObjectiveCFileOptions* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const ObjectiveCFileOptions& from);
  void MergeFrom(const ObjectiveCFileOptions& from);
  void Clear();
  bool IsInitialized() const;
  
  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const { _cached_size_ = size; }
  public:
  
  const ::google::protobuf::Descriptor* GetDescriptor() const;
  const ::google::protobuf::Reflection* GetReflection() const;
  
  // nested types ----------------------------------------------------
  
  // accessors -------------------------------------------------------
  
  // optional string objectivec_package = 1;
  inline bool has_objectivec_package() const;
  inline void clear_objectivec_package();
  static const int kObjectivecPackageFieldNumber = 1;
  inline const ::std::string& objectivec_package() const;
  inline void set_objectivec_package(const ::std::string& value);
  inline void set_objectivec_package(const char* value);
  inline void set_objectivec_package(const char* value, size_t size);
  inline ::std::string* mutable_objectivec_package();
  
  // optional string objectivec_class_prefix = 2;
  inline bool has_objectivec_class_prefix() const;
  inline void clear_objectivec_class_prefix();
  static const int kObjectivecClassPrefixFieldNumber = 2;
  inline const ::std::string& objectivec_class_prefix() const;
  inline void set_objectivec_class_prefix(const ::std::string& value);
  inline void set_objectivec_class_prefix(const char* value);
  inline void set_objectivec_class_prefix(const char* value, size_t size);
  inline ::std::string* mutable_objectivec_class_prefix();
  
 private:
  ::google::protobuf::UnknownFieldSet _unknown_fields_;
  mutable int _cached_size_;
  
  ::std::string* objectivec_package_;
  static const ::std::string _default_objectivec_package_;
  ::std::string* objectivec_class_prefix_;
  static const ::std::string _default_objectivec_class_prefix_;
  friend void  protobuf_AddDesc_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();
  friend void protobuf_AssignDesc_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();
  friend void protobuf_ShutdownFile_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto();
  ::google::protobuf::uint32 _has_bits_[(2 + 31) / 32];
  
  // WHY DOES & HAVE LOWER PRECEDENCE THAN != !?
  inline bool _has_bit(int index) const {
    return (_has_bits_[index / 32] & (1u << (index % 32))) != 0;
  }
  inline void _set_bit(int index) {
    _has_bits_[index / 32] |= (1u << (index % 32));
  }
  inline void _clear_bit(int index) {
    _has_bits_[index / 32] &= ~(1u << (index % 32));
  }
  
  void InitAsDefaultInstance();
  static ObjectiveCFileOptions* default_instance_;
};
// ===================================================================


// ===================================================================

static const int kObjectivecFileOptionsFieldNumber = 1002;
extern ::google::protobuf::internal::ExtensionIdentifier< ::google::protobuf::FileOptions,
    ::google::protobuf::internal::MessageTypeTraits< ::google::protobuf::ObjectiveCFileOptions >, 11, false >
  objectivec_file_options;

// ===================================================================

// ObjectiveCFileOptions

// optional string objectivec_package = 1;
inline bool ObjectiveCFileOptions::has_objectivec_package() const {
  return _has_bit(0);
}
inline void ObjectiveCFileOptions::clear_objectivec_package() {
  if (objectivec_package_ != &_default_objectivec_package_) {
    objectivec_package_->clear();
  }
  _clear_bit(0);
}
inline const ::std::string& ObjectiveCFileOptions::objectivec_package() const {
  return *objectivec_package_;
}
inline void ObjectiveCFileOptions::set_objectivec_package(const ::std::string& value) {
  _set_bit(0);
  if (objectivec_package_ == &_default_objectivec_package_) {
    objectivec_package_ = new ::std::string;
  }
  objectivec_package_->assign(value);
}
inline void ObjectiveCFileOptions::set_objectivec_package(const char* value) {
  _set_bit(0);
  if (objectivec_package_ == &_default_objectivec_package_) {
    objectivec_package_ = new ::std::string;
  }
  objectivec_package_->assign(value);
}
inline void ObjectiveCFileOptions::set_objectivec_package(const char* value, size_t size) {
  _set_bit(0);
  if (objectivec_package_ == &_default_objectivec_package_) {
    objectivec_package_ = new ::std::string;
  }
  objectivec_package_->assign(reinterpret_cast<const char*>(value), size);
}
inline ::std::string* ObjectiveCFileOptions::mutable_objectivec_package() {
  _set_bit(0);
  if (objectivec_package_ == &_default_objectivec_package_) {
    objectivec_package_ = new ::std::string;
  }
  return objectivec_package_;
}

// optional string objectivec_class_prefix = 2;
inline bool ObjectiveCFileOptions::has_objectivec_class_prefix() const {
  return _has_bit(1);
}
inline void ObjectiveCFileOptions::clear_objectivec_class_prefix() {
  if (objectivec_class_prefix_ != &_default_objectivec_class_prefix_) {
    objectivec_class_prefix_->clear();
  }
  _clear_bit(1);
}
inline const ::std::string& ObjectiveCFileOptions::objectivec_class_prefix() const {
  return *objectivec_class_prefix_;
}
inline void ObjectiveCFileOptions::set_objectivec_class_prefix(const ::std::string& value) {
  _set_bit(1);
  if (objectivec_class_prefix_ == &_default_objectivec_class_prefix_) {
    objectivec_class_prefix_ = new ::std::string;
  }
  objectivec_class_prefix_->assign(value);
}
inline void ObjectiveCFileOptions::set_objectivec_class_prefix(const char* value) {
  _set_bit(1);
  if (objectivec_class_prefix_ == &_default_objectivec_class_prefix_) {
    objectivec_class_prefix_ = new ::std::string;
  }
  objectivec_class_prefix_->assign(value);
}
inline void ObjectiveCFileOptions::set_objectivec_class_prefix(const char* value, size_t size) {
  _set_bit(1);
  if (objectivec_class_prefix_ == &_default_objectivec_class_prefix_) {
    objectivec_class_prefix_ = new ::std::string;
  }
  objectivec_class_prefix_->assign(reinterpret_cast<const char*>(value), size);
}
inline ::std::string* ObjectiveCFileOptions::mutable_objectivec_class_prefix() {
  _set_bit(1);
  if (objectivec_class_prefix_ == &_default_objectivec_class_prefix_) {
    objectivec_class_prefix_ = new ::std::string;
  }
  return objectivec_class_prefix_;
}


}  // namespace protobuf
}  // namespace google
#endif  // PROTOBUF_google_2fprotobuf_2fobjectivec_2ddescriptor_2eproto__INCLUDED