import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day4/Resources/day4.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

let regex = /^(\d+)-(\d+),(\d+)-(\d+)$/

let ranges = lines.compactMap { line -> (ClosedRange<Int>, ClosedRange<Int>)? in
    guard let match = line.firstMatch(of: regex) else { return nil }

    return (Int(match.1)!...Int(match.2)!, Int(match.3)!...Int(match.4)!)
}

print(ranges.reduce(0) { acc, ranges in
    return acc + (ranges.0.lowerBound <= ranges.1.lowerBound && ranges.0.upperBound >= ranges.1.upperBound || ranges.1.lowerBound <= ranges.0.lowerBound && ranges.1.upperBound >= ranges.0.upperBound ? 1 : 0)
})

print(ranges.reduce(0) { acc, ranges in
    return acc + (ranges.0.overlaps(ranges.1) ? 1 : 0)
})
