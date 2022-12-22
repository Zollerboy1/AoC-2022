import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day14/Resources/day14.txt"), encoding: .utf8)

let lines = fileContents.split(separator: "\n")

var minX = Int.max
var maxX = Int.min
var minY = Int.max
var maxY = Int.min

let paths: [[(Int, Int)]] = lines.map { line in
    let regex = /([0-9]+),([0-9]+)/

    let matches = line.matches(of: regex)

    return matches.map { match in
        let x = Int(match.1)!
        let y = Int(match.2)!

        if x < minX {
            minX = x
        }
        if x > maxX {
            maxX = x
        }
        if y < minY {
            minY = y
        }
        if y > maxY {
            maxY = y
        }

        return (x, y)
    }
}

if 500 < minX {
    minX = 500
}
if 500 > maxX {
    maxX = 500
}
if 0 < minY {
    minY = 0
}
if 0 > maxY {
    maxY = 0
}

maxY += 2
minX -= maxY - minY + 10
maxX += maxY - minY + 10


enum Tile {
    case sand
    case air
    case rock
    case source
}


var grid = Array(repeating: Array(repeating: Tile.air, count: maxX - minX + 1), count: maxY - minY + 1)

for path in paths {
    for ((x0, y0), (x1, y1)) in path.adjacentPairs() {
        if x0 == x1 {
            if y0 > y1 {
                for y in y1...y0 {
                    grid[y - minY][x0 - minX] = .rock
                }
            } else {
                for y in y0...y1 {
                    grid[y - minY][x0 - minX] = .rock
                }
            }
        } else {
            if x0 > x1 {
                for x in x1...x0 {
                    grid[y0 - minY][x - minX] = .rock
                }
            } else {
                for x in x0...x1 {
                    grid[y0 - minY][x - minX] = .rock
                }
            }
        }
    }
}

grid[-minY][500 - minX] = .source

for x in 0..<grid[0].count {
    grid[maxY - minY][x] = .rock
}

var unitsOfSand = 0
var currentSandPosition = (x: 500 - minX, y: -minY)
while true {
    if grid[currentSandPosition.y][currentSandPosition.x] == .sand {
        grid[currentSandPosition.y][currentSandPosition.x] = .air
    }

    if currentSandPosition.y == grid.count - 1 {
        break
    }

    if grid[currentSandPosition.y + 1][currentSandPosition.x] == .air {
        grid[currentSandPosition.y + 1][currentSandPosition.x] = .sand
        currentSandPosition.y += 1
    } else {
        if currentSandPosition.x == 0 {
            break
        } else if grid[currentSandPosition.y + 1][currentSandPosition.x - 1] == .air {
            grid[currentSandPosition.y + 1][currentSandPosition.x - 1] = .sand
            currentSandPosition.x -= 1
            currentSandPosition.y += 1
        } else if currentSandPosition.x == grid[0].count - 1 {
            break
        } else if grid[currentSandPosition.y + 1][currentSandPosition.x + 1] == .air {
            grid[currentSandPosition.y + 1][currentSandPosition.x + 1] = .sand
            currentSandPosition.x += 1
            currentSandPosition.y += 1
        } else if currentSandPosition == (x: 500 - minX, y: -minY) {
            unitsOfSand += 1
            break
        } else {
            grid[currentSandPosition.y][currentSandPosition.x] = .sand
            currentSandPosition = (x: 500 - minX, y: -minY)
            unitsOfSand += 1
        }
    }
}

print(unitsOfSand)
