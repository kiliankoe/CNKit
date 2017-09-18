import XCTest
import CNKit

class CNResourceTests: XCTestCase {
    func testValidURLs() {
        let validURLs = [
            "https://navigator.tu-dresden.de/raum/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/etplan/apb/00/raum/542100.2230",
            "https://navigator.tu-dresden.de/gebaeude/apb",
            "https://navigator.tu-dresden.de/karten/dresden/geb/apb",
            "https://navigator.tu-dresden.de/etplan/apb/00",
            "https://navigator.tu-dresden.de/gebaeude/biz",
            "https://navigator.tu-dresden.de/karten/johannstadt/geb/biz",
            "https://navigator.tu-dresden.de/etplan/biz/02/raum/062102.0020",
            "https://navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "http://navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "https://www.navigator.tu-dresden.de/raum/biz/02/062102.0020",
            "https://navigator.tu-dresden.de/barrierefrei/apb",
        ].flatMap(URL.init)

        for url in validURLs {
            let resource = try? CNResource(withURL: url)
            if resource == nil {
                XCTFail("\(url) should be valid")
            }
        }
    }

    func testInvalidURLs() {
        let invalidURLs = [
            "https://navigator.tu-dresden.de/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/etplan/apb/00/542100.2230",
            "https://navigator.tu-dresden.de/gebaede/biz",
            "https://navigator.tu-dresden.de/etplan//00",
            "https://navigator.tu-dresden.de/etplan/apb",
            "https://navigator.tu-dresden.de/gebaeude/biz/00",
            "https://navigator.tu-dresden.de/gebaeude/",
            "https://navigator.tu-dresden.de/gebaeude//",
            "https://navigator.tu-dresden.de/barrierefrei/apb/00",
            "https://navigator.tu-dresden.de/barrierefrei",
        ].flatMap(URL.init)

        for url in invalidURLs {
            let resource = try? CNResource(withURL: url)
            if let resource = resource {
                print(resource)
                XCTFail("\(url) should not be valid.")
            }
        }
    }
    
}
