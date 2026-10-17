import DesignSystem
import SwiftUI
import UIKit

enum PhotoProcessing {

    /// Re-encodes any image data as a JPEG no larger than `maxDimension` on its longest side,
    /// with the orientation baked in. Returns `nil` if the data is not an image.
    ///
    /// Keeps memory low on the review screen and the file small for a future upload.
    static func jpeg(from data: Data, maxDimension: CGFloat = 1600, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let size = CGSize(width: (image.size.width * scale).rounded(), height: (image.size.height * scale).rounded())

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    /// Runs `jpeg(from:)` away from the main thread.
    static func jpegInBackground(from data: Data) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            jpeg(from: data)
        }.value
    }

    /// A drawn plate used when the device has no camera, such as the Simulator.
    @MainActor
    static func sampleJPEG() -> Data? {
        let content = PlateIllustration()
            .padding(80)
            .frame(width: 800, height: 800)
            .background(PratoColor.softSurface)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        return renderer.uiImage?.jpegData(compressionQuality: 0.8)
    }
}
