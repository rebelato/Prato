import Foundation
@preconcurrency import FirebaseAppCheck
@preconcurrency import FirebaseCore

/// Starts Firebase and App Check once, at launch.
public enum FirebaseBootstrap {

    /// Configures App Check and Firebase if the app has a `GoogleService-Info.plist`.
    ///
    /// - Returns: `false` when the file is missing; the app then keeps the mock analyzer.
    ///
    /// App Check uses the **debug provider only in Debug builds** (its token is printed in the
    /// Xcode console, to register in the Firebase console) and App Attest in Release builds.
    @MainActor
    public static func configure() -> Bool {
        if FirebaseApp.app() != nil { return true }
        guard FirebaseOptions.defaultOptions() != nil else { return false }

        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
        #endif

        FirebaseApp.configure()
        return true
    }
}

/// App Attest for every device: the app requires iOS 17, so there is no DeviceCheck fallback.
final class AppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        AppAttestProvider(app: app)
    }
}
