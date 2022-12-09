import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph


struct Point: Hashable {
    var x, y: Int
}


let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day9/Resources/day9.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

let commands: [(Substring, Int)] = lines.map { $0.cut(separator: " ") }.map { d, steps in (d, Int(steps)!) }


func simulateCommands(_ commands: [(Substring, Int)], lengthOfRope: Int) -> Int {
    var currentPositions = Array(repeating: Point(x: 0, y: 0), count: lengthOfRope)
    var visitedPositions: Set<Point> = [Point(x: 0, y: 0)]
    
    func followTail(head: Point, tail: inout Point) {
        if head.x > tail.x + 1 {
            tail.x += 1
            if head.y > tail.y {
                tail.y += 1
            } else if head.y < tail.y {
                tail.y -= 1
            }
        } else if head.x < tail.x - 1 {
            tail.x -= 1
            if head.y > tail.y {
                tail.y += 1
            } else if head.y < tail.y {
                tail.y -= 1
            }
        } else if head.y > tail.y + 1 {
            tail.y += 1
            if head.x > tail.x {
                tail.x += 1
            } else if head.x < tail.x {
                tail.x -= 1
            }
        } else if head.y < tail.y - 1 {
            tail.y -= 1
            if head.x > tail.x {
                tail.x += 1
            } else if head.x < tail.x {
                tail.x -= 1
            }
        }
    }
    
    for (direction, steps) in commands {
        for _ in 0..<steps {
            switch direction {
            case "L":
                currentPositions[0].x -= 1
            case "R":
                currentPositions[0].x += 1
            case "U":
                currentPositions[0].y += 1
            case "D":
                currentPositions[0].y -= 1
            default:
                fatalError()
            }
            
            for i in 0..<(lengthOfRope - 1) {
                followTail(head: currentPositions[i], tail: &currentPositions[i + 1])
            }
            
            visitedPositions.insert(currentPositions[lengthOfRope - 1])
        }
    }
    
    return visitedPositions.count
}

print(simulateCommands(commands, lengthOfRope: 2))
print(simulateCommands(commands, lengthOfRope: 10))

