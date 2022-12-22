import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day22/Resources/day22.txt"), encoding: .utf8)


enum GridTile: Character {
    case wall = "#"
    case open = "."
    case empty = " "
}

enum Facing: Int {
    case right = 0
    case down = 1
    case left = 2
    case up = 3
}

let cubeSize = 50

let superlines = fileContents.split(separator: "\n\n")
let lines = superlines[0].split(separator: "\n")
var maxRowLength = 0
var grid = lines.map { line in
    let row = line.map { GridTile(rawValue: $0)! }
    maxRowLength = max(maxRowLength, row.count)
    return row
}

grid = grid.map { row in
    var newRow = row
    for _ in 0..<(maxRowLength - row.count) {
        newRow.append(.empty)
    }
    return newRow
}

let path = superlines[1].trimmingCharacters(in: .whitespacesAndNewlines)


func wrap1(x: Int, y: Int, facing: Facing, grid: [[GridTile]]) -> (newX: Int, newY: Int, newFacing: Facing) {
    let newX, newY: Int
    switch facing {
    case .right:
        if x + 1 < grid[y].count && grid[y][x + 1] != .empty {
            newX = x + 1
            newY = y
        } else {
            newX = grid[y].firstIndex { $0 != .empty }!
            newY = y
        }
    case .down:
        if y + 1 < grid.count && grid[y + 1][x] != .empty {
            newX = x
            newY = y + 1
        } else {
            newX = x
            newY = grid.map { $0[x] }.firstIndex { $0 != .empty }!
        }
    case .left:
        if x > 0 && grid[y][x - 1] != .empty {
            newX = x - 1
            newY = y
        } else {
            newX = grid[y].lastIndex { $0 != .empty }!
            newY = y
        }
    case .up:
        if y > 0 && grid[y - 1][x] != .empty {
            newX = x
            newY = y - 1
        } else {
            newX = x
            newY = grid.map { $0[x] }.lastIndex { $0 != .empty }!
        }
    }

    return (newX, newY, facing)
}

func wrap2(x: Int, y: Int, facing: Facing, grid: [[GridTile]]) -> (newX: Int, newY: Int, newFacing: Facing) {
    let newX, newY: Int
    let newFacing: Facing
    switch facing {
    case .right:
        if x + 1 < grid[y].count && grid[y][x + 1] != .empty {
            newY = y
            newX = x + 1
            newFacing = .right
        } else {
            switch (y, x) {
            case (0..<cubeSize, cubeSize * 2..<cubeSize * 3):
                newY = -y + cubeSize * 3 - 1
                newX = cubeSize * 2 - 1
                newFacing = .left
            case (cubeSize * 1..<cubeSize * 2, cubeSize * 1..<cubeSize * 2):
                newY = cubeSize - 1
                newX = y + cubeSize
                newFacing = .up
            case (cubeSize * 2..<cubeSize * 3, cubeSize * 1..<cubeSize * 2):
                newY = -y + cubeSize * 3 - 1
                newX = cubeSize * 3 - 1
                newFacing = .left
            case (cubeSize * 3..<cubeSize * 4, 0..<cubeSize):
                newY = cubeSize * 3 - 1
                newX = y - cubeSize * 2
                newFacing = .up
            default:
                fatalError()
            }
        }
    case .down:
        if y + 1 < grid.count && grid[y + 1][x] != .empty {
            newY = y + 1
            newX = x
            newFacing = .down
        } else {
            switch (y, x) {
            case (0..<cubeSize, cubeSize * 2..<cubeSize * 3):
                newY = x - cubeSize
                newX = cubeSize * 2 - 1
                newFacing = .left
            case (cubeSize * 2..<cubeSize * 3, cubeSize * 1..<cubeSize * 2):
                newY = x + cubeSize * 2
                newX = cubeSize - 1
                newFacing = .left
            case (cubeSize * 3..<cubeSize * 4, 0..<cubeSize):
                newY = 0
                newX = x + cubeSize * 2
                newFacing = .down
            default:
                fatalError()
            }
        }
    case .left:
        if x > 0 && grid[y][x - 1] != .empty {
            newY = y
            newX = x - 1
            newFacing = .left
        } else {
            switch (y, x) {
            case (0..<cubeSize, cubeSize..<cubeSize * 2):
                newY = -y + cubeSize * 3 - 1
                newX = 0
                newFacing = .right
            case (cubeSize..<cubeSize * 2, cubeSize..<cubeSize * 2):
                newY = cubeSize * 2
                newX = y - cubeSize
                newFacing = .down
            case (cubeSize * 2..<cubeSize * 3, 0..<cubeSize):
                newY = -y + cubeSize * 3 - 1
                newX = cubeSize
                newFacing = .right
            case (cubeSize * 3..<cubeSize * 4, 0..<cubeSize):
                newY = 0
                newX = y - cubeSize * 2
                newFacing = .down
            default:
                fatalError()
            }
        }
    case .up:
        if y > 0 && grid[y - 1][x] != .empty {
            newY = y - 1
            newX = x
            newFacing = .up
        } else {
            switch (y, x) {
            case (0..<cubeSize, cubeSize..<cubeSize * 2):
                newY = x + cubeSize * 2
                newX = 0
                newFacing = .right
            case (0..<cubeSize, cubeSize * 2..<cubeSize * 3):
                newY = cubeSize * 4 - 1
                newX = x - cubeSize * 2
                newFacing = .up
            case (cubeSize * 2..<cubeSize * 3, 0..<cubeSize):
                newY = x + cubeSize
                newX = cubeSize
                newFacing = .right
            default:
                fatalError()
            }
        }
    }

    return (newX, newY, newFacing)
}


func solve(grid: [[GridTile]], path: String, wrapFunction: (Int, Int, Facing, [[GridTile]]) -> (Int, Int, Facing)) -> Int {
    var positionY = 0
    var positionX = grid[0].firstIndex(of: .open)!
    var facing = Facing.right
    var currentNumber: Int?
    for c in path {
        switch c {
        case "L", "R":
            if let number = currentNumber {
                for _ in 0..<number {
                    let (newX, newY, newFacing) = wrapFunction(positionX, positionY, facing, grid)

                    if grid[newY][newX] == .wall {
                        break
                    } else if grid[newY][newX] == .open {
                        positionY = newY
                        positionX = newX
                        facing = newFacing
                    } else {
                        fatalError()
                    }
                }
                currentNumber = nil
            }

            facing = Facing(rawValue: (facing.rawValue + (c == "R" ? 1 : 3)) % 4)!
        case "0"..."9":
            if let number = currentNumber {
                currentNumber = Int(String(number) + String(c))!
            } else {
                currentNumber = Int(String(c))!
            }
            continue
        default:
            fatalError()
        }
    }

    if let number = currentNumber {
        for _ in 0..<number {
            let (newX, newY, newFacing) = wrapFunction(positionX, positionY, facing, grid)

            if grid[newY][newX] == .wall {
                break
            } else if grid[newY][newX] == .open {
                positionY = newY
                positionX = newX
                facing = newFacing
            } else {
                fatalError()
            }
        }
    }

    return (positionY + 1) * 1000 + (positionX + 1) * 4 + facing.rawValue
}


print(solve(grid: grid, path: path, wrapFunction: wrap1))
print(solve(grid: grid, path: path, wrapFunction: wrap2))
