import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day5/Resources/day5.txt"), encoding: .utf8)


let parts = fileContents.split(separator: "\n", omittingEmptySubsequences: false).cut(where: \.isEmpty)

let stackLines = parts.0.dropLast()
let commandLines = parts.1

let stacks = stackLines.map { line in
    line.chunks(ofCount: 4)
}.reversed().reduce(into: Array(repeating: [Character](), count: 9)) { stacks, chunks in
    for (stackIndex, maybeCrate) in chunks.enumerated() {
        if maybeCrate.starts(with: "[") {
            stacks[stackIndex].append(maybeCrate[maybeCrate.index(after: maybeCrate.startIndex)])
        }
    }
}

let commandRegex = /move (\d+) from (\d+) to (\d+)/

let commands = commandLines.compactMap { line -> (Int, Int, Int)? in
    guard let match = line.matches(of: commandRegex).first,
          let count = Int(match.1),
          let from = Int(match.2),
          let to = Int(match.3) else { return nil }

    return (count, from - 1, to - 1)
}

var part1Stacks = stacks
var part2Stacks = stacks
for (count, from, to) in commands {
    for _ in 0..<count {
        part1Stacks[to].append(part1Stacks[from].popLast()!)
    }

    part2Stacks[to].append(contentsOf: part2Stacks[from].suffix(count))
    part2Stacks[from].removeLast(count)
}

let messagePart1 = String(part1Stacks.compactMap { $0.last })
let messagePart2 = String(part2Stacks.compactMap { $0.last })

print(messagePart1)
print(messagePart2)
