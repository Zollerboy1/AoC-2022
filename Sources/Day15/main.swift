import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day15/Resources/day15.txt"), encoding: .utf8)


struct Point: Equatable, Hashable {
    let x: Int
    let y: Int
}


let lines = fileContents.split(separator: "\n")

let regex = /Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)/

let sensors: [(Point, Point)] = lines.map { line in
    let matches = line.firstMatch(of: regex)!
    let x = Int(matches.1)!
    let y = Int(matches.2)!
    let closestX = Int(matches.3)!
    let closestY = Int(matches.4)!

    return (.init(x: x, y: y), .init(x: closestX, y: closestY))
}

// Part 1
var ranges: [ClosedRange<Int>] = []
for (sensor, closest) in sensors {
    let distance = abs(sensor.x - closest.x) + abs(sensor.y - closest.y)
    let distanceToRow = abs(sensor.y - 2000000)

    if distance < distanceToRow {
        continue
    }

    var range = (sensor.x - distance + distanceToRow)...(sensor.x + distance - distanceToRow)

    while let otherRangeIndex = ranges.firstIndex(where: { $0.overlaps(range) }) {
        let otherRange = ranges.remove(at: otherRangeIndex)
        range = min(range.lowerBound, otherRange.lowerBound)...max(range.upperBound, otherRange.upperBound)
    }

    ranges.append(range)
}

let beacons = Set(sensors.map(\.1))

let count = ranges.reduce(0) { $0 + $1.count } - beacons.reduce(0) { a, beacon in a + (beacon.y == 2000000 && ranges.contains { $0.contains(beacon.x) } ? 1 : 0) }

print(count)


// Part 2
for y in 0...4000000 {
    var ranges: [ClosedRange<Int>] = []
    for (sensor, closest) in sensors {
        let distance = abs(sensor.x - closest.x) + abs(sensor.y - closest.y)
        let distanceToRow = abs(sensor.y - y)

        if distance < distanceToRow {
            continue
        }

        var range = (sensor.x - distance + distanceToRow)...(sensor.x + distance - distanceToRow)

        while let otherRangeIndex = ranges.firstIndex(where: { $0.overlaps(range) }) {
            ranges.swapAt(otherRangeIndex, ranges.count - 1)
            let otherRange = ranges.remove(at: ranges.count - 1)
            range = min(range.lowerBound, otherRange.lowerBound)...max(range.upperBound, otherRange.upperBound)
        }

        ranges.append(range)
    }

    if ranges.count > 1 {
        if ranges[0].lowerBound < ranges[1].lowerBound {
            print((ranges[1].lowerBound - 1) * 4000000 + y)
        } else {
            print((ranges[0].lowerBound - 1) * 4000000 + y)
        }
        break
    }
}
