// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -enable-experimental-com-interop -module-name COM -emit-module-path %t/COM.swiftmodule %S/../Inputs/COM.swift
// RUN: %target-swift-frontend -enable-experimental-com-interop -enable-builtin-module -I %t -emit-silgen -sil-verify-all -Xllvm -sil-print-types %s | %FileCheck %s
// RUN: %target-swift-frontend -enable-experimental-com-interop -enable-builtin-module -I %t -emit-sil -sil-verify-all %s | %FileCheck %s --check-prefix=CANON

import Builtin

@com(interface: "51000000-0000-0000-0000-000000000001")
protocol IItem {}

@com(interface: "51000000-0000-0000-0000-000000000002")
protocol IClassItem: IItem, AnyObject {}

// CHECK-LABEL: sil hidden [ossa] @$s{{.*}}6borrow
// CHECK: [[ADDRESS:%.*]] = unchecked_addr_cast {{%.*}} : $*{{.*}} to $*Builtin.RawPointer
// CHECK-NEXT: [[POINTER:%.*]] = load [trivial] [[ADDRESS]]
// CHECK: return [[POINTER]]
// CANON-LABEL: sil hidden{{.*}} @$s{{.*}}6borrow
// CANON-NOT: copy_addr
// CANON-NOT: destroy_addr
// CANON: return
func borrow<T: IItem>(_ value: borrowing T) -> Builtin.RawPointer {
  Builtin.bridgeToRawPointer(value)
}

// CHECK-LABEL: sil hidden [ossa] @$s{{.*}}6retain
// CHECK: [[ADDRESS:%.*]] = unchecked_addr_cast {{%.*}} : $*Builtin.RawPointer to $*T
// CHECK-NEXT: copy_addr [[ADDRESS]] to [init] %0 : $*T
// CHECK: return
func retain<T: IItem>(_ pointer: Builtin.RawPointer) -> T {
  Builtin.bridgeFromRawPointer(pointer)
}

// CHECK-LABEL: sil hidden [ossa] @$s{{.*}}11borrowClass
// CHECK: [[ADDRESS:%.*]] = unchecked_addr_cast {{%.*}} : $*{{.*}} to $*Builtin.RawPointer
// CHECK-NEXT: [[POINTER:%.*]] = load [trivial] [[ADDRESS]]
// CHECK: return [[POINTER]]
// CANON-LABEL: sil hidden{{.*}} @$s{{.*}}11borrowClass
// CANON-NOT: copy_addr
// CANON-NOT: destroy_addr
// CANON: return
func borrowClass<T: IClassItem>(_ value: borrowing T) -> Builtin.RawPointer {
  Builtin.bridgeToRawPointer(value)
}

// CHECK-LABEL: sil hidden [ossa] @$s{{.*}}11retainClass
// CHECK: [[ADDRESS:%.*]] = unchecked_addr_cast {{%.*}} : $*Builtin.RawPointer to $*T
// CHECK-NEXT: copy_addr [[ADDRESS]] to [init] %0 : $*T
// CHECK: return
func retainClass<T: IClassItem>(_ pointer: Builtin.RawPointer) -> T {
  Builtin.bridgeFromRawPointer(pointer)
}
