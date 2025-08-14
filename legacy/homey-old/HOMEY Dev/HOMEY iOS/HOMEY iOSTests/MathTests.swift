//
//  MathTests.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/10/25.
//


import Testing

struct MathTests {
    @Test func addingTwoNumbers() {
        let sum = 2 + 2
        #expect(sum == 4)
    }
}