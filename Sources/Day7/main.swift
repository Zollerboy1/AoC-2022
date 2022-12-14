import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph
import RegexBuilder


class Directory {
    let name: Substring
    let parent: Directory?
    var size: Int
    var children: [Directory]

    private var _totalSize: Int?

    var totalSize: Int {
        if let totalSize = self._totalSize {
            return totalSize
        } else {
            let size = self.size + self.children.map(\.totalSize).sum()
            self._totalSize = size
            return size
        }
    }

    var allSizes: [Int] {
        [self.totalSize] + self.children.flatMap(\.allSizes)
    }

    init(name: Substring, parent: Directory?) {
        self.name = name
        self.parent = parent
        self.size = 0
        self.children = []
    }
}


let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day7/Resources/day7.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

var topDirectory = Directory(name: "/", parent: nil)
var currentDirectory = topDirectory

let cdRegex = Regex {
    "$ cd "
    Capture {
        ChoiceOf {
            OneOrMore(.word)
            ".."
            "/"
        }
    }
}

let fileRegex = Regex {
    TryCapture {
        OneOrMore(.digit)
    } transform: {
        Int($0)
    }
    " "
    OneOrMore {
        ChoiceOf {
            .word
            "."
        }
    }
}

let dirRegex = Regex {
    "dir "
    Capture {
        OneOrMore(.word)
    }
}

for line in lines {
    if let cdMatch = line.wholeMatch(of: cdRegex) {
        switch (cdMatch.1) {
        case "/":
            currentDirectory = topDirectory
        case "..":
            currentDirectory = currentDirectory.parent!
        default:
            currentDirectory = currentDirectory.children.first(where: { $0.name == cdMatch.1 })!
        }
    } else if line != "$ ls" {
        if let fileMatch = line.wholeMatch(of: fileRegex) {
            currentDirectory.size += fileMatch.1
        } else if let dirMatch = line.wholeMatch(of: dirRegex) {
            currentDirectory.children.append(Directory(name: dirMatch.1, parent: currentDirectory))
        }
    }
}

// Part 1
print(topDirectory.allSizes.filter { $0 <= 100_000 }.sum())

// Part 2
print(topDirectory.allSizes.filter { $0 >= topDirectory.totalSize - 40000000 }.min()!)
