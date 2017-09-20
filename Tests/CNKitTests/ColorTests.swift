import XCTest
import CNKit

class ColorTests: XCTestCase {

    let black = 0x000000
    let red = 0xff0000
    let green = 0x00ff00
    let blue = 0x0000ff
    let white = 0xffffff

    #if os(iOS)
    func testInit() {
    }
    #elseif os(macOS)
    func test() {
        let blackColor = NSColor(withRGB: black)
        XCTAssertEqual(blackColor.redComponent, 0.0)
        XCTAssertEqual(blackColor.blueComponent, 0.0)
        XCTAssertEqual(blackColor.greenComponent, 0.0)
        XCTAssertEqual(blackColor.alphaComponent, 0.5)

        let redColor = NSColor(withRGB: red)
        XCTAssertEqual(redColor.redComponent, 1.0)
        XCTAssertEqual(redColor.blueComponent, 0.0)
        XCTAssertEqual(redColor.greenComponent, 0.0)
        XCTAssertEqual(redColor.alphaComponent, 0.5)

        let greenColor = NSColor(withRGB: green)
        XCTAssertEqual(greenColor.redComponent, 0.0)
        XCTAssertEqual(greenColor.blueComponent, 0.0)
        XCTAssertEqual(greenColor.greenComponent, 1.0)
        XCTAssertEqual(greenColor.alphaComponent, 0.5)

        let blueColor = NSColor(withRGB: blue)
        XCTAssertEqual(blueColor.redComponent, 0.0)
        XCTAssertEqual(blueColor.blueComponent, 1.0)
        XCTAssertEqual(blueColor.greenComponent, 0.0)
        XCTAssertEqual(blueColor.alphaComponent, 0.5)

        let whiteColor = NSColor(withRGB: white)
        XCTAssertEqual(whiteColor.redComponent, 1.0)
        XCTAssertEqual(whiteColor.blueComponent, 1.0)
        XCTAssertEqual(whiteColor.greenComponent, 1.0)
        XCTAssertEqual(whiteColor.alphaComponent, 0.5)
    }
    #endif
}
