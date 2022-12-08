import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day8/Resources/day8.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

let gridHeight = lines.count
let gridWidth = lines[0].count

let heights = lines.map {
    ($0.map { Int(String($0))! })
}

var chosen: [[Bool]] = (0..<gridHeight).map { i in
    (0..<gridWidth).map { j in
        i == 0 || j == 0 || i == gridHeight - 1 || j == gridWidth - 1
    }
}

var scenicScore: [[Int]] = (0..<gridHeight).map { i in
    (0..<gridWidth).map { j in
        i == 0 || j == 0 || i == gridHeight - 1 || j == gridWidth - 1 ? 0 : 1
    }
}

var maxHeightsFromTop = heights.first!
for i in 1..<(gridHeight - 1) {
    outerLoop: for j in 1..<(gridWidth - 1) {
        if heights[i][j] > maxHeightsFromTop[j] {
            chosen[i][j] = true
            maxHeightsFromTop[j] = heights[i][j]
        }

        for x in ((0)..<i).reversed() {
            if heights[x][j] >= heights[i][j] {
                scenicScore[i][j] *= i - x
                continue outerLoop
            }
        }

        scenicScore[i][j] *= i
    }
}

var maxHeightsFromBottom = heights.last!
for i in (1..<(gridHeight - 1)).reversed() {
    outerLoop: for j in 1..<(gridWidth - 1) {
        if heights[i][j] > maxHeightsFromBottom[j] {
            chosen[i][j] = true
            maxHeightsFromBottom[j] = heights[i][j]
        }

        if scenicScore[i][j] != 0 {
            for x in (i + 1)..<gridHeight {
                if heights[x][j] >= heights[i][j] {
                    scenicScore[i][j] *= x - i
                    continue outerLoop
                }
            }

            scenicScore[i][j] *= gridHeight - i - 1
        }
    }
}

var maxHeightsFromLeft = heights.map(\.first!)
for j in 1..<(gridWidth - 1) {
    outerLoop: for i in 1..<(gridHeight - 1) {
        if heights[i][j] > maxHeightsFromLeft[i] {
            chosen[i][j] = true
            maxHeightsFromLeft[i] = heights[i][j]
        }

        if scenicScore[i][j] != 0 {
            for y in ((0)..<j).reversed() {
                if heights[i][y] >= heights[i][j] {
                    scenicScore[i][j] *= j - y
                    continue outerLoop
                }
            }

            scenicScore[i][j] *= j
        }
    }
}

var maxHeightsFromRight = heights.map(\.last!)
for j in (1..<(gridWidth - 1)).reversed() {
    outerLoop: for i in 1..<(gridHeight - 1) {
        if heights[i][j] > maxHeightsFromRight[i] {
            chosen[i][j] = true
            maxHeightsFromRight[i] = heights[i][j]
        }

        if scenicScore[i][j] != 0 {
            for y in (j + 1)..<gridWidth {
                if heights[i][y] >= heights[i][j] {
                    scenicScore[i][j] *= y - j
                    continue outerLoop
                }
            }

            scenicScore[i][j] *= gridWidth - j - 1
        }
    }
}

print(chosen.flatMap { $0.map { $0 ? 1 : 0 }}.sum())

print(scenicScore.map { $0.max()! }.max()!)
