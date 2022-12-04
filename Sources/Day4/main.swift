import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let url = Bundle.module.url(forResource: "day4", withExtension: "txt")!
let fileContents = try! String(contentsOf: url, encoding: .utf8)


let lines = fileContents.split(separator: "\n")

let regex = /^(\d+)-(\d+),(\d+)-(\d+)$/

let ranges = lines.compactMap { line -> (ClosedRange<Int>, ClosedRange<Int>)? in
    guard let match = line.matches(of: regex).first else { return nil }

    return (Int(match.1)!...Int(match.2)!, Int(match.3)!...Int(match.4)!)
}

print(ranges.reduce(0) { acc, ranges in
    return acc + (ranges.0.contains(ranges.1) || ranges.1.contains(ranges.0) ? 1 : 0)
})

print(ranges.reduce(0) { acc, ranges in
    return acc + (ranges.0.overlaps(ranges.1) ? 1 : 0)
})
