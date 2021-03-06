// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//



#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
import Foundation
import XCTest
#else
import SwiftFoundation
import SwiftXCTest
#endif



class TestNSArray : XCTestCase {
    
    var allTests : [(String, () -> Void)] {
        return [
            ("test_BasicConstruction", test_BasicConstruction),
            ("test_enumeration", test_enumeration),
            ("test_sequenceType", test_sequenceType),
            ("test_getObjects", test_getObjects),
            ("test_objectAtIndex", test_objectAtIndex),
            ("test_binarySearch", test_binarySearch),
            ("test_replaceObjectsInRange_withObjectsFromArray", test_replaceObjectsInRange_withObjectsFromArray),
            ("test_replaceObjectsInRange_withObjectsFromArray_range", test_replaceObjectsInRange_withObjectsFromArray_range),
        ]
    }
    
    func test_BasicConstruction() {
        let array = NSArray()
        let array2 : NSArray = ["foo", "bar"].bridge()
        XCTAssertEqual(array.count, 0)
        XCTAssertEqual(array2.count, 2)
    }
    
    func test_enumeration() {
        let array : NSArray = ["foo", "bar", "baz"].bridge()
        let e = array.objectEnumerator()
        XCTAssertEqual((e.nextObject() as! NSString).bridge(), "foo")
        XCTAssertEqual((e.nextObject() as! NSString).bridge(), "bar")
        XCTAssertEqual((e.nextObject() as! NSString).bridge(), "baz")
        XCTAssertNil(e.nextObject())
        XCTAssertNil(e.nextObject())
        
        let r = array.reverseObjectEnumerator()
        XCTAssertEqual((r.nextObject() as! NSString).bridge(), "baz")
        XCTAssertEqual((r.nextObject() as! NSString).bridge(), "bar")
        XCTAssertEqual((r.nextObject() as! NSString).bridge(), "foo")
        XCTAssertNil(r.nextObject())
        XCTAssertNil(r.nextObject())
        
        let empty = NSArray().objectEnumerator()
        XCTAssertNil(empty.nextObject())
        XCTAssertNil(empty.nextObject())
        
        let reverseEmpty = NSArray().reverseObjectEnumerator()
        XCTAssertNil(reverseEmpty.nextObject())
        XCTAssertNil(reverseEmpty.nextObject())
    }
    
    func test_sequenceType() {
        let array : NSArray = ["foo", "bar", "baz"].bridge()
        var res = [String]()
        for obj in array {
            res.append((obj as! NSString).bridge())
        }
        XCTAssertEqual(res, ["foo", "bar", "baz"])
    }

    func test_getObjects() {
        let array : NSArray = ["foo", "bar", "baz", "foo1", "bar2", "baz3",].bridge()
        var objects = [AnyObject]()
        array.getObjects(&objects, range: NSMakeRange(1, 3))
        XCTAssertEqual(objects.count, 3)
        let fetched = [
            (objects[0] as! NSString).bridge(),
            (objects[1] as! NSString).bridge(),
            (objects[2] as! NSString).bridge(),
        ]
        XCTAssertEqual(fetched, ["bar", "baz", "foo1"])
    }
    
    func test_objectAtIndex() {
        let array : NSArray = ["foo", "bar"].bridge()
        let foo = array.objectAtIndex(0) as! NSString
        XCTAssertEqual(foo, "foo".bridge())
        
        let bar = array.objectAtIndex(1) as! NSString
        XCTAssertEqual(bar, "bar".bridge())
    }

    func test_binarySearch() {
        let array = NSArray(array: [
            NSNumber(int: 0), NSNumber(int: 1), NSNumber(int: 2), NSNumber(int: 2), NSNumber(int: 3),
            NSNumber(int: 4), NSNumber(int: 4), NSNumber(int: 6), NSNumber(int: 7), NSNumber(int: 7),
            NSNumber(int: 7), NSNumber(int: 8), NSNumber(int: 9), NSNumber(int: 9)])
        
        // Not sure how to test fatal errors.
        
//        NSArray throws NSInvalidArgument if range exceeds bounds of the array.
//        let rangeOutOfArray = NSRange(location: 5, length: 15)
//        let _ = array.indexOfObject(NSNumber(integer: 9), inSortedRange: rangeOutOfArray, options: [.InsertionIndex, .FirstEqual], usingComparator: compareIntNSNumber)
        
//        NSArray throws NSInvalidArgument if both .FirstEqual and .LastEqaul are specified
//        let searchForBoth: NSBinarySearchingOptions = [.FirstEqual, .LastEqual]
//        let _ = objectIndexInArray(array, value: 9, startingFrom: 0, length: 13, options: searchForBoth)

        let notFound = objectIndexInArray(array, value: 11, startingFrom: 0, length: 13)
        XCTAssertEqual(notFound, NSNotFound, "NSArray return NSNotFound if object is not found.")
        
        let notFoundInRange = objectIndexInArray(array, value: 7, startingFrom: 0, length: 5)
        XCTAssertEqual(notFoundInRange, NSNotFound, "NSArray return NSNotFound if object is not found.")
        
        let indexOfAnySeven = objectIndexInArray(array, value: 7, startingFrom: 0, length: 13)
        XCTAssertTrue(Set([8, 9, 10]).contains(indexOfAnySeven), "If no options provided NSArray returns an arbitrary matching object's index.")
        
        let indexOfFirstNine = objectIndexInArray(array, value: 9, startingFrom: 7, length: 6, options: [.FirstEqual])
        XCTAssertTrue(indexOfFirstNine == 12, "If .FirstEqual is set NSArray returns the lowest index of equal objects.")
        
        let indexOfLastTwo = objectIndexInArray(array, value: 2, startingFrom: 1, length: 7, options: [.LastEqual])
        XCTAssertTrue(indexOfLastTwo == 3, "If .LastEqual is set NSArray returns the highest index of equal objects.")
        
        let anyIndexToInsertNine = objectIndexInArray(array, value: 9, startingFrom: 0, length: 13, options: [.InsertionIndex])
        XCTAssertTrue(Set([12, 13, 14]).contains(anyIndexToInsertNine), "If .InsertionIndex is specified and no other options provided NSArray returns any equal or one larger index than any matching object’s index.")
        
        let lowestIndexToInsertTwo = objectIndexInArray(array, value: 2, startingFrom: 0, length: 5, options: [.InsertionIndex, .FirstEqual])
        XCTAssertTrue(lowestIndexToInsertTwo == 2, "If both .InsertionIndex and .FirstEqual are specified NSArray returns the lowest index of equal objects.")
        
        let highestIndexToInsertNine = objectIndexInArray(array, value: 9, startingFrom: 7, length: 6, options: [.InsertionIndex, .LastEqual])
        XCTAssertTrue(highestIndexToInsertNine == 13, "If both .InsertionIndex and .LastEqual are specified NSArray returns the index of the least greater object...")
        
        let indexOfLeastGreaterObjectThanFive = objectIndexInArray(array, value: 5, startingFrom: 0, length: 10, options: [.InsertionIndex, .LastEqual])
        XCTAssertTrue(indexOfLeastGreaterObjectThanFive == 7, "If both .InsertionIndex and .LastEqual are specified NSArray returns the index of the least greater object...")
        
        let endOfArray = objectIndexInArray(array, value: 10, startingFrom: 0, length: 13, options: [.InsertionIndex, .LastEqual])
        XCTAssertTrue(endOfArray == array.count, "...or the index at the end of the array if the object is larger than all other elements.")
    }
    
    func objectIndexInArray(array: NSArray, value: Int, startingFrom: Int, length: Int, options: NSBinarySearchingOptions = []) -> Int {
        return array.indexOfObject(NSNumber(integer: value), inSortedRange: NSRange(location: startingFrom, length: length), options: options, usingComparator: compareIntNSNumber)
    }
    
    func compareIntNSNumber(lhs: AnyObject, rhs: AnyObject) -> NSComparisonResult {
        let lhsInt = (lhs as! NSNumber).integerValue
        let rhsInt = (rhs as! NSNumber).integerValue
        if lhsInt == rhsInt {
            return .OrderedSame
        }
        if lhsInt < rhsInt {
            return .OrderedAscending
        }
        
        return .OrderedDescending
    }
    
    func test_replaceObjectsInRange_withObjectsFromArray() {
        let array1 = NSMutableArray(array:[
            "foo1".bridge(),
            "bar1".bridge(),
            "baz1".bridge()])
        
        let array2: [AnyObject] = [
            "foo2".bridge(),
            "bar2".bridge(),
            "baz2".bridge()]
        
        array1.replaceObjectsInRange(NSMakeRange(0, 2), withObjectsFromArray: array2)
        
        XCTAssertEqual(array1[0] as? NSString, "foo2".bridge(), "Expected foo2 but was \(array1[0])")
        XCTAssertEqual(array1[1] as? NSString, "bar2".bridge(), "Expected bar2 but was \(array1[1])")
        XCTAssertEqual(array1[2] as? NSString, "baz2".bridge(), "Expected baz2 but was \(array1[2])")
        XCTAssertEqual(array1[3] as? NSString, "baz1".bridge(), "Expected baz1 but was \(array1[3])")
    }
    
    func test_replaceObjectsInRange_withObjectsFromArray_range() {
        let array1 = NSMutableArray(array:[
            "foo1".bridge(),
            "bar1".bridge(),
            "baz1".bridge()])
        
        let array2: [AnyObject] = [
            "foo2".bridge(),
            "bar2".bridge(),
            "baz2".bridge()]
        
        array1.replaceObjectsInRange(NSMakeRange(1, 1), withObjectsFromArray: array2, range: NSMakeRange(1, 2))
        
        XCTAssertEqual(array1[0] as? NSString, "foo1".bridge(), "Expected foo1 but was \(array1[0])")
        XCTAssertEqual(array1[1] as? NSString, "bar2".bridge(), "Expected bar2 but was \(array1[1])")
        XCTAssertEqual(array1[2] as? NSString, "baz2".bridge(), "Expected baz2 but was \(array1[2])")
        XCTAssertEqual(array1[3] as? NSString, "baz1".bridge(), "Expected baz1 but was \(array1[3])")
    }
}
