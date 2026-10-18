import DesignSystem
import MealKit
import PhotosUI
import SwiftUI

/// "Enquadre seu prato": live camera, library and the way out without a photo.
public struct CaptureView: View {

    @Bindable private var viewModel: CaptureViewModel
    @Environment(\.openURL) private var openURL

    public init(viewModel: CaptureViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 0) {
                Button {
                    viewModel.closeTapped()
                } label: {
                    CloseIcon()
                }
                .padding(.leading, -12)
                .accessibilityLabel(L10n.Common.close)

                ScreenHeader(title: L10n.Capture.title, subtitle: L10n.Capture.subtitle)
                    .padding(.top, 12)

                viewfinder
                    .padding(.top, 28)

                controls
                    .padding(.top, 28)

                if viewModel.cameraState == .unavailable {
                    Text(L10n.Capture.unavailable)
                        .font(PratoFont.caption)
                        .foregroundStyle(PratoColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(PratoColor.background)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.appeared() }
        .onDisappear { viewModel.disappeared() }
        .photosPicker(isPresented: $viewModel.isPhotoPickerPresented, selection: $viewModel.pickedItem, matching: .images)
        .onChange(of: viewModel.pickedItem) { _, item in
            Task { await viewModel.photoPicked(item) }
        }
        .alert(L10n.Capture.loadFailed, isPresented: $viewModel.showsLoadError) {
            Button(L10n.Common.ok, role: .cancel) {}
        }
    }

    private var viewfinder: some View {
        PratoColor.softSurface
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                switch viewModel.cameraState {
                case .running:
                    CameraPreview(session: viewModel.camera.session)
                case .unavailable:
                    PlateIllustration()
                        .padding(56)
                case .starting:
                    ProgressView()
                case .denied:
                    deniedMessage
                }
            }
            .overlay {
                if viewModel.cameraState == .running || viewModel.cameraState == .unavailable {
                    Circle()
                        .strokeBorder(.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .padding(28)
                        .accessibilityHidden(true)
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.cameraState == .running || viewModel.cameraState == .unavailable {
                    Text(L10n.Capture.guide)
                        .font(PratoFont.caption)
                        .foregroundStyle(PratoColor.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PratoColor.surface, in: .capsule)
                        .padding(.bottom, 16)
                }
            }
            .clipShape(.rect(cornerRadius: 28))
    }

    private var deniedMessage: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundStyle(PratoColor.textSecondary)
                .accessibilityHidden(true)
            Text(L10n.Capture.deniedTitle)
                .font(PratoFont.bodyEmphasized)
                .foregroundStyle(PratoColor.textPrimary)
            Text(L10n.Capture.deniedMessage)
                .font(PratoFont.secondary)
                .foregroundStyle(PratoColor.textSecondary)
                .multilineTextAlignment(.center)
            Button(L10n.Capture.openSettings) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .font(PratoFont.bodyEmphasized)
            .foregroundStyle(PratoColor.accent)
            .frame(minHeight: 44)
        }
        .padding(24)
    }

    private var controls: some View {
        HStack {
            Button(L10n.Capture.gallery) { viewModel.galleryTapped() }
                .font(PratoFont.body.weight(.medium))
                .foregroundStyle(PratoColor.accent)
                .frame(minWidth: 88, minHeight: 44)

            Spacer()

            Button {
                Task { await viewModel.shutterTapped() }
            } label: {
                ZStack {
                    Circle()
                        .fill(PratoColor.primaryButton)
                    if viewModel.isCapturing {
                        ProgressView()
                            .tint(PratoColor.onPrimaryButton)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(PratoColor.onPrimaryButton)
                    }
                }
                .frame(width: 80, height: 80)
            }
            .disabled(!viewModel.canTakePhoto)
            .opacity(viewModel.canTakePhoto || viewModel.isCapturing ? 1 : 0.4)
            .accessibilityLabel(L10n.Capture.shutter)

            Spacer()

            Button(L10n.Capture.withoutPhoto) { viewModel.withoutPhotoTapped() }
                .font(PratoFont.body.weight(.medium))
                .foregroundStyle(PratoColor.accent)
                .frame(minWidth: 88, minHeight: 44)
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView(viewModel: CaptureViewModel(source: .camera) { _ in })
    }
}
