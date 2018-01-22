//
//  UInt8.swift
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension UInt8 {
    /// Returns integer value of hex decoded.
    func hexDecoded() -> UInt8?{
        if 0x30 <= self && self <= 0x39 {
            return self - UInt8(0x30)
        } else if 0x61 <= self && self <= 0x66 {
            return self - UInt8(0x61 + 10)
        } else if 0x41 <= self && self <= 0x46 {
            return self - UInt8(0x041 + 10)
        }
        return nil
    }

    /// Returns high byte of hex encoded.
    func hexEncoded(of bits: HexEncodedBits) -> UInt8 {
        let value: UInt8
        switch bits {
        case .high:
            value = self >> 4
        case .low:
            value = self & 0xF
        }
        return value < 10 ? (value + 0x30) : (value - 10 + 0x41)
    }

    enum HexEncodedBits {
        case high
        case low
    }
}

extension Array where Element == UInt8 {
    /// Adds a unicode scalar to the builder in UTF8 encoding.
    mutating func append(unicode scalar: UInt) {
        if scalar <= 0x7F {
            append(UInt8(scalar))
        } else if scalar <= 0x7FF {
            append(UInt8(0xC0 | (scalar >> 6)))
            append(UInt8(0x80 | (scalar & 0x3F)))
        } else if scalar <= 0xFFFF {
            if scalar < 0xD800 || scalar > 0xDFFF {
                append(UInt8(0xE0 | (scalar >> 12)))
                append(UInt8(0x80 | ((scalar >> 6) & 0x3F)))
                append(UInt8(0x80 | (scalar & 0x3F)))
            }
        } else if scalar <= 0x10FFFF {
            append(UInt8(0xF0 | (scalar >> 18)))
            append(UInt8(0x80 | ((scalar >> 12) & 0x3F)))
            append(UInt8(0x80 | ((scalar >> 6) & 0x3F)))
            append(UInt8(0x80 | (scalar & 0x3F)))
        }
        // don't output invalid UTF-8 byte sequence to a stream
    }
}

extension Sequence where Iterator.Element == UInt8 {
    /// Converts a slice of bytes to string.
    func makeString() -> String {
        let array = Array(self) + [0]
        return array.withUnsafeBufferPointer { bp in
            let pointer = bp.baseAddress!
            var string = ""
            var index = 0
            for i in 0 ..< array.count where array[i] == 0 {
                if i > index {
                    let str = String(cString: pointer.advanced(by: index))
                    if string == "" {
                        string = str
                    } else {
                        string.append(str)
                    }
                }
                if i < array.count - 1 {
                    string.append("\u{0}")
                }
                index = i + 1
            }
            return string
        }
    }
}
