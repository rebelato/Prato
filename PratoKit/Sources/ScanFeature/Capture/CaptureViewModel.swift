import Foundation
import MealKit
import Observation
import PhotosUI
import SwiftUI

/// State and actions of the camera screen ("Enquadre seu prato").
@MainActor
@Observable
public final class CaptureViewModel {

    public enum CameraState: Equatable, Sendable {
        /// Waiting for permission or for the session to start.
        case starting
        case running
        /// No camera on this device (the Simulator): the shutter uses a sample photo.
        case unavailable
        /// The user denied camera access.
        case denied
    }

    public private(set) var cameraState: CameraState = .starting
    public private(set) var isCapturing = false
    public var isPhotoPickerPresented: Bool
    public var pickedItem: PhotosPickerItem?
    public var showsLoadError = false

    let camera = CameraController()
    private let onEvent: @MainActor (CaptureEvent) -> Void

    init(source: ScanSource, onEvent: @escaping @MainActor (CaptureEvent) -> Void) {
        self.isPhotoPickerPresented = source == .gallery
        self.onEvent = onEvent
    }

    public var canTakePhoto: Bool {
        (cameraState == .running || cameraState == .unavailable) && !isCapturing
    }

    /// Called every time the screen appears, including when the user comes back to it.
    public func appeared() async {
        guard CameraController.hasCamera else {
            cameraState = .unavailable
            return
        }
        if await CameraController.requestAccess() {
            camera.start()
            cameraState = .running
        } else {
            cameraState = .denied
        }
    }

    public func disappeared() {
        camera.stop()
    }

    public func shutterTapped() async {
        guard canTakePhoto else { return }
        isCapturing = true
        defer { isCapturing = false }

        let jpeg: Data?
        switch cameraState {
        case .running:
            guard let raw = try? await camera.capturePhoto() else { return }
            jpeg = await PhotoProcessing.jpegInBackground(from: raw)
        case .unavailable:
            jpeg = PhotoProcessing.sampleJPEG()
        case .starting, .denied:
            return
        }

        if let jpeg {
            onEvent(.photoTaken(jpeg))
        }
    }

    public func galleryTapped() {
        isPhotoPickerPresented = true
    }

    /// Called when the photo picker returns an item.
    public func photoPicked(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        pickedItem = nil

        guard
            let data = try? await item.loadTransferable(type: Data.self),
            let jpeg = await PhotoProcessing.jpegInBackground(from: data)
        else {
            showsLoadError = true
            return
        }
        onEvent(.photoTaken(jpeg))
    }

    public func withoutPhotoTapped() {
        onEvent(.skipPhotoRequested)
    }

    public func closeTapped() {
        onEvent(.closeRequested)
    }
}
