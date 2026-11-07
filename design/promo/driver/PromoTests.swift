import XCTest

let dir = "/private/tmp/claude-501/-Users-kimtaejin-app-show-only/c75f5442-c1f2-4ebf-a98d-67fc6dad1f89/scratchpad/run"

func mark(_ s: String) {
    let line = "\(Date().timeIntervalSince1970) \(s)\n"
    let url = URL(fileURLWithPath: dir + "/markers.txt")
    if let h = try? FileHandle(forWritingTo: url) {
        h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); try? h.close()
    } else {
        try? line.write(to: url, atomically: true, encoding: .utf8)
    }
}

func shot(_ name: String) {
    try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir + "/\(name).png"))
}

func dump(_ name: String, _ app: XCUIApplication) {
    try? app.debugDescription.write(toFile: dir + "/\(name).txt", atomically: true, encoding: .utf8)
}

final class PromoTests: XCTestCase {
    let photos = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let app = XCUIApplication()

    func dismissAlerts(_ labels: [String] = ["허용", "확인", "OK"]) {
        for label in labels {
            let b = springboard.alerts.buttons[label]
            if b.exists { b.tap(); sleep(1) }
        }
    }

    func swipe(_ a: XCUIApplication, fromX: CGFloat, toX: CGFloat) {
        let s = a.coordinate(withNormalizedOffset: CGVector(dx: fromX, dy: 0.5))
        let e = a.coordinate(withNormalizedOffset: CGVector(dx: toX, dy: 0.5))
        s.press(forDuration: 0.05, thenDragTo: e, withVelocity: 900, thenHoldForDuration: 0)
    }

    func flow() {
        mark("start")
        photos.launch()
        sleep(2)
        dismissAlerts(["허용 안 함"])
        if photos.buttons["계속"].exists { photos.buttons["계속"].tap(); sleep(2) }
        mark("photos_grid")
        sleep(2)
        photos.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.62)).tap()
        mark("photos_open")
        sleep(2)
        swipe(photos, fromX: 0.15, toX: 0.85)
        mark("photos_swiped")
        sleep(2)

        app.launch()
        mark("home")
        sleep(2)
        app.buttons["사진 고르기"].tap()
        mark("picker")
        sleep(2)
        let imgs = app.images.matching(identifier: "PXGGridLayout-Info")
        for idx in [5, 4, 3] {
            imgs.element(boundBy: idx).tap()
            mark("pick\(idx)")
            usleep(700_000)
        }
        sleep(1)
        app.buttons["추가"].tap()
        mark("added")
        _ = app.buttons["3장 보여주기"].waitForExistence(timeout: 10)
        mark("home_selected")
        sleep(2)
        app.buttons["3장 보여주기"].tap()
        mark("viewer")
        sleep(2)
        swipe(app, fromX: 0.85, toX: 0.15)
        mark("swipe1")
        sleep(2)
        swipe(app, fromX: 0.85, toX: 0.15)
        mark("swipe2")
        sleep(2)
        swipe(app, fromX: 0.85, toX: 0.3)
        mark("swipe_bounce")
        sleep(2)
        mark("home_press")
        XCUIDevice.shared.press(.home)
        sleep(2)
        app.activate()
        mark("lock")
        sleep(3)
        app.buttons["Face ID로 다시 보기"].tap()
        mark("AUTH1")
        sleep(1)
        dismissAlerts()
        _ = app.buttons["보여주기 끝내기"].waitForExistence(timeout: 15)
        mark("unlocked")
        sleep(2)
        app.buttons["보여주기 끝내기"].tap()
        mark("sheet")
        sleep(2)
        app.buttons["Face ID로 끝내기"].tap()
        mark("AUTH2")
        sleep(1)
        dismissAlerts()
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["Face ID로 끝내기"])
        _ = XCTWaiter.wait(for: [gone], timeout: 15)
        mark("ended")
        sleep(3)
        mark("done")
    }

    func testRecord() throws { flow() }

    func testWarmupFaceID() throws {
        app.launch()
        sleep(2)
        app.buttons["사진 고르기"].tap()
        sleep(2)
        let imgs = app.images.matching(identifier: "PXGGridLayout-Info")
        imgs.element(boundBy: 5).tap()
        sleep(1)
        app.buttons["추가"].tap()
        _ = app.buttons["1장 보여주기"].waitForExistence(timeout: 10)
        app.buttons["1장 보여주기"].tap()
        sleep(2)
        app.buttons["보여주기 끝내기"].tap()
        sleep(2)
        app.buttons["Face ID로 끝내기"].tap()
        sleep(2)
        shot("warm_alert")
        dismissAlerts(["허용"])
        mark("AUTHW")
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["Face ID로 끝내기"])
        _ = XCTWaiter.wait(for: [gone], timeout: 15)
        sleep(2)
        shot("warm_end")
    }
}
