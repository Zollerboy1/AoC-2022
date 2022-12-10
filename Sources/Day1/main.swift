import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph


let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day1/Resources/day1.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)

let calories = lines.split(separator: "").map {
    $0.compactMap { Int($0) }.sum()
}

// Part 1
print(calories.max()!)

// Part 2
print(calories.max(count: 3).sum())
