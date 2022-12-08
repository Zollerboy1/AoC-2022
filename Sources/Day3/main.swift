import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day3/Resources/day3.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

// Part 1
print(lines.map { line -> Int in
    let count = line.count
    let middle = line.index(line.startIndex, offsetBy: count / 2)

    for item in line[line.startIndex..<middle] {
        if line[middle..<line.endIndex].contains(item) {
            return Array(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").firstIndex(of: item)!
        }
    }

    fatalError()
}.sum())

// Part 2
print(lines.chunks(ofCount: 3).map(Array.init).map { group -> Int in
    for character in group[0] {
        if group[1].contains(character) && group[2].contains(character) {
            return Array(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").firstIndex(of: character)!
        }
    }

    fatalError()
}.sum())
