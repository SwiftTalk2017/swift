// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -enable-experimental-keypath-components -emit-silgen -import-objc-header %S/Inputs/keypaths_objc.h %s | %FileCheck %s
// REQUIRES: objc_interop

import Foundation

struct NonObjC {
  var x: Int
  var y: NSObject
}

class Foo: NSObject {
  @objc var int: Int { fatalError() }
  @objc var bar: Bar { fatalError() }
  var nonobjc: NonObjC { fatalError() }
  @objc(thisIsADifferentName) var differentName: Bar { fatalError() }

  @objc subscript(x: Int) -> Foo { return self }
  @objc subscript(x: Bar) -> Foo { return self }

  dynamic var dyn: String { fatalError() }
}

class Bar: NSObject {
  @objc var foo: Foo { fatalError() }
}

// CHECK-LABEL: sil hidden @_T013keypaths_objc0B8KeypathsyyF
func objcKeypaths() {
  // CHECK: keypath $WritableKeyPath<NonObjC, Int>, (root
  _ = \NonObjC.x
  // CHECK: keypath $WritableKeyPath<NonObjC, NSObject>, (root
  _ = \NonObjC.y
  // CHECK: keypath $KeyPath<Foo, Int>, (objc "int"
  _ = \Foo.int
  // CHECK: keypath $KeyPath<Foo, Bar>, (objc "bar"
  _ = \Foo.bar
  // CHECK: keypath $KeyPath<Foo, Foo>, (objc "bar.foo"
  _ = \Foo.bar.foo
  // CHECK: keypath $KeyPath<Foo, Bar>, (objc "bar.foo.bar"
  _ = \Foo.bar.foo.bar
  // CHECK: keypath $KeyPath<Foo, NonObjC>, (root
  _ = \Foo.nonobjc
  // CHECK: keypath $KeyPath<Foo, NSObject>, (root
  _ = \Foo.bar.foo.nonobjc.y
  // CHECK: keypath $KeyPath<Foo, Bar>, (objc "thisIsADifferentName"
  _ = \Foo.differentName
}

// CHECK-LABEL: sil hidden @_T013keypaths_objc0B18KeypathIdentifiersyyF
func objcKeypathIdentifiers() {
  // CHECK: keypath $KeyPath<ObjCFoo, String>, (objc "objcProp"; {{.*}} id #ObjCFoo.objcProp!getter.1.foreign
  _ = \ObjCFoo.objcProp
  // CHECK: keypath $KeyPath<Foo, String>, (objc "dyn"; {{.*}} id #Foo.dyn!getter.1.foreign
  _ = \Foo.dyn
  // CHECK: keypath $KeyPath<Foo, Int>, (objc "int"; {{.*}} id #Foo.int!getter.1 :
  _ = \Foo.int
}
