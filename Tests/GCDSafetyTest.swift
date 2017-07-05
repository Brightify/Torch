//
//  GCDSafetyTest.swift
//  Torch
//
//  Created by Tadeas Kriz on 7/5/17.
//  Copyright © 2017 Brightify. All rights reserved.
//


import XCTest
import RealmSwift
import Torch

//class SyncThread: Thread {
//    private let lockQueue = DispatchQueue(label: "lockQueue")
//    private let dispatchGroup = DispatchGroup()
//    private var work: () -> Any = { Void() }
//    private var result: Any = Void()
//
//    private let queue = OperationQueue()
//
//    override func main() {
//        self.result = work()
//        work = { Void() }
//        print(result)
//        dispatchGroup.leave()
//    }
//
//    func sync<RESULT>(work: () -> RESULT) -> RESULT {
//        return lockQueue.sync {
//            return withoutActuallyEscaping(work) { work in
//                self.work = work
//                dispatchGroup.enter()
//                start()
//                dispatchGroup.wait()
//                return result as! RESULT
//            }
//        }
//    }
//}

class GCDSafetyTest: XCTestCase {

    func testSyncDifferentThread() {
        let queue = DispatchQueue(label: "test")
        let otherQueue = DispatchQueue(label: "other")

        let check = queue.sync {
            Thread.current
        }

        let e = expectation(description: "Threads")

        otherQueue.async {
            queue.sync {
                XCTAssertNotEqual(check, Thread.current)
                e.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testSyncSafety() {
        let queue = DispatchQueue(label: "test")
        let otherQueue = DispatchQueue(label: "other")
        let other2Queue = DispatchQueue(label: "other2")

        let (database, check) = queue.sync {
            (TestUtils.initDatabase(), Thread.current)
        }

        let e = expectation(description: "Create")
        var entity = OtherData(id: nil, text: "Test")
        otherQueue.async {
            print("async 1")
            queue.sync {
                print("sync 1a")
                TestUtils.initDatabase(keepData: true).create(&entity)
                print("sync 1b")
                XCTAssertNotEqual(check, Thread.current)
                print("sync 1c")
                e.fulfill()
                print("sync 1d")
            }
        }

        let e2 = expectation(description: "Load")
        other2Queue.async {
            sleep(1)
            print("async 2")
            queue.sync {
                print("sync 2a")
                print(TestUtils.initDatabase(keepData: true).load(OtherData.self))
                print("sync 2b")
                XCTAssertNotEqual(check, Thread.current)
                print("sync 2c")
                e2.fulfill()
                print("sync 2d")
            }
        }

        waitForExpectations(timeout: 60)
    }

//    func testThreadSafety() {
//        let otherQueue = DispatchQueue(label: "other")
//        let thread = SyncThread()
//
//        let check = thread.sync {
//            Thread.current
//        }
//
//
//        let e = expectation(description: "Threads")
//
//        otherQueue.async {
//            thread.sync {
//                XCTAssertEqual(check, Thread.current)
//                e.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 5)
//    }
}
