import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

func compare(_ lhs: [Any], _ rhs: [Any]) -> ComparisonResult {
    var i = 0
    while i < lhs.count, i < rhs.count {
        if let a = lhs[i] as? Int, let b = rhs[i] as? Int {
            if a != b {
                return a < b ? .orderedAscending : .orderedDescending
            }
        } else if let a = lhs[i] as? [Any], let b = rhs[i] as? [Any] {
            let comparison = compare(a, b)

            if comparison != .orderedSame {
                return comparison
            }
        } else if let a = lhs[i] as? [Any] {
            return compare(a, [rhs[i]])
        } else if let b = rhs[i] as? [Any] {
            return compare([lhs[i]], b)
        }

        i += 1
    }

    if i < lhs.count {
        return .orderedDescending
    } else if i < rhs.count {
        return .orderedAscending
    } else {
        return .orderedSame
    }
}

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day13/Resources/day13.txt"), encoding: .utf8)

let superlines = fileContents.split(separator: "\n\n")

let leftsAndRights = superlines.map {
    $0.cut(separator: "\n")
}.map {
    (try! JSONSerialization.jsonObject(with: Data($0.utf8)) as! [Any], try! JSONSerialization.jsonObject(with: Data($1.utf8)) as! [Any])
}

print(leftsAndRights.map { compare($0, $1) }.enumerated().filter { $1 == .orderedAscending }.map { $0.0 + 1 }.sum())

let divider1 = [[2]] as [Any]
let divider2 = [[6]] as [Any]

var allPackets = [divider1, divider2] + leftsAndRights.flatMap { [$0, $1] } as [[Any]]
allPackets.sort { compare($0, $1) == .orderedAscending }

print((allPackets.firstIndex { compare(divider1, $0) == .orderedSame }! + 1) * (allPackets.firstIndex { compare(divider2, $0) == .orderedSame }! + 1))
