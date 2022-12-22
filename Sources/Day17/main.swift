import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day17/Resources/day17.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

enum Matter {
    case air
    case rock
    case movingRock
}

struct State: Hashable {
    var nextRock: Int
    var nextMovement: String.Index
    var relativeHeights: [Int]
}


let rocks: [[[Matter]]] = [
    [
        [.air, .air, .movingRock, .movingRock, .movingRock, .movingRock, .air]
    ],
    [
        [.air, .air, .air, .movingRock, .air, .air, .air],
        [.air, .air, .movingRock, .movingRock, .movingRock, .air, .air],
        [.air, .air, .air, .movingRock, .air, .air, .air]
    ],
    [
        [.air, .air, .movingRock, .movingRock, .movingRock, .air, .air],
        [.air, .air, .air, .air, .movingRock, .air, .air],
        [.air, .air, .air, .air, .movingRock, .air, .air]
    ],
    [
        [.air, .air, .movingRock, .air, .air, .air, .air],
        [.air, .air, .movingRock, .air, .air, .air, .air],
        [.air, .air, .movingRock, .air, .air, .air, .air],
        [.air, .air, .movingRock, .air, .air, .air, .air]
    ],
    [
        [.air, .air, .movingRock, .movingRock, .air, .air, .air],
        [.air, .air, .movingRock, .movingRock, .air, .air, .air]
    ],
]


func runSimulation(_ iterations: Int) -> Int {
    var chamber = Array(repeating: Array(repeating: Matter.air, count: 7), count: 3)

    var nextRock = 0
    var nextMovement = fileContents.startIndex
    var height = 0
    var heights = Array(repeating: 0, count: 7)
    var movingRange = 0..<0

    func move(left: Bool) {
        for y in movingRange {
            for x in 0..<7 {
                if chamber[y][x] == .movingRock {
                    if x == (left ? 0 : (chamber[y].count - 1)) || chamber[y][x + (left ? -1 : 1)] == .rock {
                        return
                    }
                }
            }
        }

        for y in movingRange {
            for x in 0..<7 {
                let x = left ? x : 6 - x
                if chamber[y][x] == .movingRock {
                    chamber[y][x] = .air
                    chamber[y][x + (left ? -1 : 1)] = .movingRock
                }
            }
        }
    }

    var states = [State: (i: Int, height: Int)]()
    var skipAmount: Int?
    var i = 0
    while i < iterations {
        if height + 3 < chamber.count {
            chamber.removeLast(chamber.count - (height + 3))
        }

        let rock = rocks[nextRock]
        chamber.append(contentsOf: rock)

        let state = State(nextRock: nextRock, nextMovement: nextMovement, relativeHeights: heights.map { height - $0 })
        if skipAmount == nil {
            if let (firstI, firstHeight) = states[state] {
                let heightGain = height - firstHeight
                let numberOfIterations = i - firstI
                let count = (iterations - i) / numberOfIterations
                i += count * numberOfIterations
                skipAmount = count * heightGain
            } else {
                states[state] = (i, height)
            }
        }

        movingRange = height + 3..<height + 3 + rock.count

        var stopped = false
        while !stopped {
            switch fileContents[nextMovement] {
            case "<": move(left: true)
            case ">": move(left: false)
            default: fatalError()
            }

            var canMoveDown = true
            for y in movingRange {
                for x in 0..<chamber[y].count {
                    if chamber[y][x] == .movingRock {
                        if y == 0 || chamber[y - 1][x] == .rock {
                            canMoveDown = false
                            break
                        }
                    }
                }
            }

            if canMoveDown {
                for y in movingRange {
                    for x in 0..<chamber[y].count {
                        if chamber[y][x] == .movingRock {
                            chamber[y][x] = .air
                            chamber[y - 1][x] = .movingRock
                        }
                    }
                }

                movingRange = movingRange.lowerBound - 1..<movingRange.upperBound - 1
            } else {
                stopped = true

                for y in movingRange {
                    for x in 0..<chamber[y].count {
                        if chamber[y][x] == .movingRock {
                            chamber[y][x] = .rock

                            if heights[x] <= y {
                                heights[x] = y + 1
                            }

                            if y >= height {
                                height = y + 1
                            }
                        }
                    }
                }
            }

            nextMovement = fileContents.index(after: nextMovement)
            if nextMovement == fileContents.endIndex {
                nextMovement = fileContents.startIndex
            }
        }

        nextRock = (nextRock + 1) % rocks.count

        i += 1
    }

    return height + (skipAmount ?? 0)
}

print(runSimulation(2022))
print(runSimulation(1000000000000))
