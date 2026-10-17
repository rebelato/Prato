@preconcurrency import AVFoundation

enum CameraError: Error {
    case unavailable
    case busy
    case noPhotoData
}

/// Runs the capture session and takes photos.
///
/// Every touch of the session happens on one private serial queue, which is what makes
/// the `@unchecked Sendable` safe: `start()`, `stop()` and `capturePhoto()` can be
/// called from any thread.
final class CameraController: NSObject, @unchecked Sendable {

    /// Shown by the preview layer. Configured and driven only on `queue`.
    let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "com.rebelato.prato.camera")
    private var isConfigured = false
    private var pendingCapture: CheckedContinuation<Data, any Error>?

    /// Whether the device has a back camera. False on the Simulator.
    static var hasCamera: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    /// Asks for camera access the first time; afterwards returns the user's earlier answer.
    static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    func start() {
        queue.async { [self] in
            configureIfNeeded()
            if isConfigured, !session.isRunning {
                session.startRunning()
            }
        }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    /// Takes a photo and returns its file data (JPEG or HEIC, as the device prefers).
    func capturePhoto() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                guard isConfigured, session.isRunning else {
                    continuation.resume(throwing: CameraError.unavailable)
                    return
                }
                guard pendingCapture == nil else {
                    continuation.resume(throwing: CameraError.busy)
                    return
                }
                pendingCapture = continuation
                output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    /// Must run on `queue`.
    private func configureIfNeeded() {
        guard !isConfigured else { return }
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo
        guard session.canAddInput(input), session.canAddOutput(output) else { return }
        session.addInput(input)
        session.addOutput(output)
        output.maxPhotoQualityPrioritization = .balanced
        isConfigured = true
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        let data = photo.fileDataRepresentation()
        queue.async { [self] in
            guard let continuation = pendingCapture else { return }
            pendingCapture = nil
            if let error {
                continuation.resume(throwing: error)
            } else if let data {
                continuation.resume(returning: data)
            } else {
                continuation.resume(throwing: CameraError.noPhotoData)
            }
        }
    }
}
