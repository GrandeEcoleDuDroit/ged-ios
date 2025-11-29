import Foundation

let pngImageFixture = Data([0x89, 0x50, 0x4E, 0x47] + Array(repeating: 0x00, count: 100))

let jpegImageFixture = Data([0xFF, 0xD8] + Array(repeating: 0xAA, count: 100))
