//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

@testable import Testing

@Suite("Type Name Conflict Tests")
struct TypeNameConflictTests {
    @Test("Test function does not conflict with local type names")
    func someTest() {
        #expect(Bool(true))
    }

    @Test("Test function does not conflict with local type names")
    @available(*, noasync)
    func someNoAsyncTest() {
        #expect(Bool(true))
    }
}

// MARK: - Fixtures

private struct SourceLocation {}
private struct __TestContainer {}
private struct __XCTestCompatibleSelector {}

private func __forward<R>(_: R) async throws {
    Issue.record("Called wrong __forward()")
}

private func __forwardNoAsync<R>(_: @autoclosure () throws -> R) throws {
    Issue.record("Called wrong __forwardNoAsync()")
}

private func __invokeXCTestCaseMethod<T>(
    _: __XCTestCompatibleSelector?,
    onInstanceOf _: T.Type,
    sourceLocation _: SourceLocation
) {
    Issue.record("Called wrong __invokeXCTestCaseMethod()")
}

private func __xcTestCompatibleSelector(_: String) -> __XCTestCompatibleSelector? {
    Issue.record("Called wrong __xcTestCompatibleSelector()")
    return nil
}

@Suite(.hidden)
struct tests {
    @Test(.hidden)
    static func f() {}
}
