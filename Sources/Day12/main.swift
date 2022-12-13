import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day12/Resources/day12.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

var start, end: Int?
let grid: [[Int]] = lines.enumerated().map { y, line in
    line.enumerated().map { x, char in
        var height = Int(char.asciiValue!) - Int(Character("a").asciiValue!)
        if char == "S" {
            start = y * line.count + x
            height = 0
        } else if char == "E" {
            end = y * line.count + x
            height = 25
        }

        return height
    }
}

let graph = UnweightedGraph<Int>(vertices: (0..<lines.count * lines[0].count).map { $0 })
for (y, line) in grid.enumerated() {
    for (x, height) in line.enumerated() {
        if x > 0 && line[x - 1] <= height + 1 {
            graph.addEdge(fromIndex: y * line.count + x - 1, toIndex: y * line.count + x, directed: true)
        }
        if x < line.count - 1 && line[x + 1] <= height + 1 {
            graph.addEdge(fromIndex: y * line.count + x + 1, toIndex: y * line.count + x, directed: true)
        }
        if y > 0 && grid[y - 1][x] <= height + 1 {
            graph.addEdge(fromIndex: (y - 1) * line.count + x, toIndex: y * line.count + x, directed: true)
        }
        if y < grid.count - 1 && grid[y + 1][x] <= height + 1 {
            graph.addEdge(fromIndex: (y + 1) * line.count + x, toIndex: y * line.count + x, directed: true)
        }
    }
}

let route = graph.bfs(fromIndex: end!, toIndex: start!)

print(route.count)

let minimumRoute = graph.bfs(fromIndex: end!) {
    grid[$0 / lines[0].count][$0 % lines[0].count] == 0
}

print(minimumRoute.count)
