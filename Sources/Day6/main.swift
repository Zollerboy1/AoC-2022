import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day6/Resources/day6.txt"), encoding: .utf8)


let result = { n in
    let windowed = fileContents.windows(ofCount: n)
    return windowed.firstIndex { Set($0).count == n }.map { windowed.distance(from: windowed.startIndex, to: $0) }.map { $0 + n }
}

print(result(4)!)
print(result(14)!)
