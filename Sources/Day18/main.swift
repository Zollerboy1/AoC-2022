import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day18/Resources/day18.txt"), encoding: .utf8)


struct Cube: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

let lines = fileContents.split(separator: "\n")

var minX = Int.max
var maxX = Int.min
var minY = Int.max
var maxY = Int.min
var minZ = Int.max
var maxZ = Int.min
let cubes = lines.map { line in
    let coords = line.split(separator: ",")
    let x = Int(coords[0])!
    let y = Int(coords[1])!
    let z = Int(coords[2])!

    minX = min(minX, x)
    maxX = max(maxX, x)
    minY = min(minY, y)
    maxY = max(maxY, y)
    minZ = min(minZ, z)
    maxZ = max(maxZ, z)
    return Cube(x: x, y: y, z: z)
}

let cubeSet = Set(cubes)

let directions = [
    Cube(x: 1, y: 0, z: 0),
    Cube(x: 0, y: 1, z: 0),
    Cube(x: 0, y: 0, z: 1),
    Cube(x: -1, y: 0, z: 0),
    Cube(x: 0, y: -1, z: 0),
    Cube(x: 0, y: 0, z: -1)
]

var neighborSet = Set<Cube>()
var surface = 0
for cube in cubes {
    for direction in directions {
        let neighbor = Cube(x: cube.x + direction.x, y: cube.y + direction.y, z: cube.z + direction.z)
        if !cubeSet.contains(neighbor) {
            neighborSet.insert(neighbor)
            surface += 1
        }
    }
}

print(surface)

let allCubes = (minX - 1...maxX + 1).flatMap { x in (minY - 1...maxY + 1).flatMap { y in (minZ - 1...maxZ + 1).map { z in Cube(x: x, y: y, z: z) }}}

var visited = Array(repeating: false, count: allCubes.count)
var stack = [Int]()
stack.append(0)
while !stack.isEmpty {
    let index = stack.removeLast()
    let cube = allCubes[index]
    if !visited[index] {
        visited[index] = true
        let nextZIndex = index + 1
        if let neighbor = allCubes.element(at: nextZIndex), neighbor.x == cube.x && neighbor.y == cube.y && !cubeSet.contains(neighbor) {
            stack.append(nextZIndex)
        }
        let previousZIndex = index - 1
        if let neighbor = allCubes.element(at: previousZIndex), neighbor.x == cube.x && neighbor.y == cube.y && !cubeSet.contains(neighbor) {
            stack.append(previousZIndex)
        }
        let nextYIndex = index + (maxZ - minZ + 3)
        if let neighbor = allCubes.element(at: nextYIndex), neighbor.x == cube.x && neighbor.z == cube.z && !cubeSet.contains(neighbor) {
            stack.append(nextYIndex)
        }
        let previousYIndex = index - (maxZ - minZ + 3)
        if let neighbor = allCubes.element(at: previousYIndex), neighbor.x == cube.x && neighbor.z == cube.z && !cubeSet.contains(neighbor) {
            stack.append(previousYIndex)
        }
        let nextXIndex = index + (maxZ - minZ + 3) * (maxY - minY + 3)
        if let neighbor = allCubes.element(at: nextXIndex), neighbor.y == cube.y && neighbor.z == cube.z && !cubeSet.contains(neighbor) {
            stack.append(nextXIndex)
        }
        let previousXIndex = index - (maxZ - minZ + 3) * (maxY - minY + 3)
        if let neighbor = allCubes.element(at: previousXIndex), neighbor.y == cube.y && neighbor.z == cube.z && !cubeSet.contains(neighbor) {
            stack.append(previousXIndex)
        }
    }
}

var exteriorSurface = allCubes.enumerated().filter { i, cube in
    neighborSet.contains(cube) && !visited[i]
}.map(\.element).reduce(surface) { acc, cube in
    acc - directions.filter { cubeSet.contains(Cube(x: cube.x + $0.x, y: cube.y + $0.y, z: cube.z + $0.z)) }.count
}

print(exteriorSurface)
