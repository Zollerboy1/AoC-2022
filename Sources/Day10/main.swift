import Darwin

import Helpers

let fileContents = FastString(contentsOfFile: "Sources/Day10/Resources/day10.txt")!

var value = 1
var cycleNumber = 0
var result1 = 0
var result2 = ""

func updateResult() {
    if cycleNumber % 40 == 20 {
        result1 += cycleNumber * value
    }

    if ((cycleNumber - 1) % 40 - value).magnitude <= 1 {
        result2 += "#"
    } else {
        result2 += "."
    }

    if (cycleNumber) % 40 == 0 {
        result2 += "\n"
    }
}

var (currentLine, rest) = fileContents.cut(separator: "\n")
while !currentLine.isEmpty {
    let x = currentLine.drop { $0 != " " }

    cycleNumber += 1

    updateResult()

    if !x.isEmpty {
        cycleNumber += 1

        updateResult()

        value += Int(x.dropFirst())!
    }

    (currentLine, rest) = rest.cut(separator: "\n")
}

let result1String = FastString(result1)

fastPrint(result1String + "\n")
print(result2)
