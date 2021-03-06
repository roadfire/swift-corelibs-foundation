// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

import CoreFoundation

public let NSDefaultRunLoopMode: String = kCFRunLoopDefaultMode._swiftObject
public let NSRunLoopCommonModes: String = kCFRunLoopCommonModes._swiftObject

public class NSRunLoop : NSObject {
    internal var _cfRunLoop : CFRunLoopRef!
    internal static var _mainRunLoop : NSRunLoop = {
        return NSRunLoop(cfObject: CFRunLoopGetMain())
    }()
    
    internal init(cfObject : CFRunLoopRef) {
        _cfRunLoop = cfObject
    }
    
    public class func currentRunLoop() -> NSRunLoop {
        return NSRunLoop(cfObject: CFRunLoopGetCurrent())
    }
    
    public class func mainRunLoop() -> NSRunLoop {
        return _mainRunLoop
    }
    
    public var currentMode: String? {
        return CFRunLoopCopyCurrentMode(_cfRunLoop)?._swiftObject
    }
    
    public func addTimer(timer: NSTimer, forMode mode: String) {
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer._cfObject, mode._cfObject)
    }
    
    public func addPort(aPort: NSPort, forMode mode: String) {
        NSUnimplemented()
    }

    public func removePort(aPort: NSPort, forMode mode: String) {
        NSUnimplemented()
    }
    
    public func limitDateForMode(mode: String) -> NSDate? {
        let nextTimerFireAbsoluteTime = CFRunLoopGetNextTimerFireDate(CFRunLoopGetCurrent(), mode._cfObject)
        
        if (nextTimerFireAbsoluteTime == 0) {
            return NSDate.distantFuture()
        }
        
        return NSDate(timeIntervalSinceReferenceDate: nextTimerFireAbsoluteTime)
    }

    public func acceptInputForMode(mode: String, beforeDate limitDate: NSDate) {
        NSUnimplemented()
    }

}

extension NSRunLoop {
    
    public func run() {
        runUntilDate(NSDate.distantFuture());
    }

    public func runUntilDate(limitDate: NSDate) {
        runMode(NSDefaultRunLoopMode, beforeDate: limitDate)
    }

    public func runMode(mode: String, beforeDate limitDate: NSDate) -> Bool {
        let runloopResult = CFRunLoopRunInMode(mode._cfObject, limitDate.timeIntervalSinceNow, false)
#if os(Linux)
        return runloopResult == 2 || runloopResult == 3
#else
        return runloopResult == .HandledSource || runloopResult == .TimedOut
#endif
    }

}

