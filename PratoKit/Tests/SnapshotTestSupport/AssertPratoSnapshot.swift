import SnapshotTesting
import SwiftUI
import UIKit

/// Compares `view` with its reference images in light and dark, named `<name>-light` and `<name>-dark`.
///
/// The view is shown at the iPhone 13 Pro's width and safe areas, in a hosting controller whose
/// `overrideUserInterfaceStyle` sets the appearance, so UIKit pieces such as navigation bars follow
/// it too. Pass `height` to show a scrolling screen whole instead of only its first screenful.
///
/// The package tests have no host app, so the image is drawn from the layers, not from a window.
/// On iOS 26 that leaves the glass navigation bar's title washed out in light mode (it looks right
/// in the app); the rest of the screen renders as on device.
///
/// The images live in `__Snapshots__/<TestFile>/` next to the test. They were recorded on the
/// iPhone 17 Pro simulator (iOS 26), with the test language set to pt-BR in the Prato scheme;
/// another simulator or iOS version renders slightly differently.
///
/// - A missing reference is recorded and the test fails once; run it again to compare.
/// - To record every reference again after a visual change, run the tests with the environment
///   variable `SNAPSHOT_TESTING_RECORD=all`, then check the new images before committing them.
@MainActor
public func assertPratoSnapshot(
    of view: some View,
    named name: String,
    height: CGFloat? = nil,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let device = ViewImageConfig.iPhone13Pro
    let config = ViewImageConfig(
        safeArea: device.safeArea,
        size: CGSize(width: device.size?.width ?? 390, height: height ?? device.size?.height ?? 844),
        traits: device.traits
    )

    for style in [UIUserInterfaceStyle.light, .dark] {
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = style
        assertSnapshot(
            of: controller,
            as: .image(on: config, precision: 0.99, perceptualPrecision: 0.98),
            named: "\(name)-\(style == .dark ? "dark" : "light")",
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}
