import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day2/Resources/day2.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")


func score(_ opponent: Substring, _ me: Substring) -> Int {
    switch me {
        case "X": return 0
        case "Y": return 3
        default: return 6
    }
}

func value(_ opponent: Substring, _ me: Substring) -> Int {
    switch (opponent, me) {
        case ("A", "Y"), ("B", "X"), ("C", "Z"): return 1
        case ("A", "Z"), ("B", "Y"), ("C", "X"): return 2
        default: return 3
    }
}


print(lines.map { line in
    let split = line.split(separator: " ")
    let opponent = split[0]
    let me = split[1]

    return score(opponent, me) + value(opponent, me)
}.reduce(0, +))
