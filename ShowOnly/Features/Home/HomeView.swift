import SwiftUI
import PhotosUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var session: PhotoSessionStore
    @StateObject private var selection = PhotoSelectionStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var authStatus = AuthenticationService().status()
    @State private var showsPicker = false
    @State private var showsGuide = false
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            HomeContent(
                snapshot: HomeSnapshot(
                    photos: selection.photos,
                    authStatus: authStatus,
                    showsSessionEndedNotice: session.showsSessionEndedNotice
                ),
                onPick: { showsPicker = true },
                onRetry: retryFailed,
                onStart: start,
                onGuide: { showsGuide = true },
                onOpenSettings: openSettings
            )
            // 가이드의 뒤로 버튼에 "홈"이 보이도록 제목만 지정하고 바는 숨김
            .navigationTitle("홈")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showsGuide) {
                ProtectionGuideView()
            }
        }
        .tint(Theme.Colors.primary)
        .photosPicker(
            isPresented: $showsPicker,
            selection: $selection.pickerItems,
            maxSelectionCount: PhotoSelectionStore.maxCount,
            matching: .images
        )
        .onChange(of: selection.pickerItems) { items in
            if !items.isEmpty {
                session.dismissSessionEndedNotice()
            }
            loadTask?.cancel()
            loadTask = Task { await selection.load(items) }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                authStatus = AuthenticationService().status()
            }
        }
        .fullScreenCover(isPresented: $session.isPresented) {
            HandoffViewer()
                .environmentObject(session)
        }
    }

    private func retryFailed() {
        loadTask?.cancel()
        loadTask = Task { await selection.retryFailed() }
    }

    private func start() {
        let status = AuthenticationService().status()
        authStatus = status
        guard status.canAuthenticate, !selection.isLoading else { return }
        let images = selection.loadedImages
        guard !images.isEmpty else { return }
        loadTask?.cancel()
        session.begin(with: images)
        // 사진은 세션이 보유하므로 홈에서는 비웁니다.
        selection.clear()
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

/// 홈 화면을 그리는 데 필요한 값. 미리보기에서도 그대로 만들어 씁니다.
@MainActor
struct HomeSnapshot {
    var photos: [SelectedPhoto]
    var authStatus: AuthStatus
    var showsSessionEndedNotice = false

    var isEmpty: Bool { photos.isEmpty }
    var isLoading: Bool { photos.contains { $0.state == .loading } }
    var failedCount: Int { photos.filter { $0.state == .failed }.count }
    var loadedCount: Int {
        photos.filter { if case .loaded = $0.state { return true } else { return false } }.count
    }
    var isAtLimit: Bool { photos.count >= PhotoSelectionStore.maxCount }
    var canAuthenticate: Bool { authStatus.canAuthenticate }
}

private struct HomeContent: View {
    let snapshot: HomeSnapshot
    let onPick: () -> Void
    let onRetry: () -> Void
    let onStart: () -> Void
    let onGuide: () -> Void
    let onOpenSettings: () -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Theme.Spacing.s2),
        count: 3
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("ShowOnly")
                    .font(Theme.Fonts.wordmark)
                    .foregroundStyle(Theme.Colors.text)
                    .padding(.top, Theme.Spacing.s4)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: Theme.Spacing.s3) {
                    Text(headline)
                        .font(Theme.Fonts.largeTitle)
                        .tracking(Theme.Tracking.largeTitle)
                        .foregroundStyle(Theme.Colors.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(subheadline)
                        .font(Theme.Fonts.subhead)
                        .foregroundStyle(Theme.Colors.text2)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, Theme.Spacing.s6 + Theme.Spacing.s4)

                if snapshot.isEmpty {
                    emptyBody
                        .padding(.top, Theme.Spacing.s5)
                } else {
                    selectedBody
                        .padding(.top, Theme.Spacing.s6)
                }
            }
            .padding(.horizontal, Theme.Spacing.margin)
            .padding(.bottom, Theme.Spacing.s5)
        }
        .background(Theme.Colors.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { bottomBar }
    }

    // MARK: 비어 있음

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s5) {
            if snapshot.showsSessionEndedNotice {
                BannerView(
                    tone: .info,
                    title: "이전 보여주기가 끝났어요",
                    message: "앱이 다시 시작되면서 고른 사진을 비웠어요. 다시 골라주세요."
                )
            }
            VStack(spacing: 0) {
                FactRow(index: 1, text: "고른 사진 말고는 불러오지 않아요", showsTopSeparator: true)
                FactRow(index: 2, text: "앱을 나갔다 오면 사진을 가리고 잠가요")
                FactRow(index: 3, text: "사진은 이 기기 밖으로 나가지 않아요")
            }
        }
    }

    // MARK: 선택됨

    private var selectedBody: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s3) {
            HStack(alignment: .center) {
                Text(countText)
                    .font(Theme.Fonts.numeric)
                    .foregroundStyle(snapshot.isAtLimit && !showsLoadProgress ? Theme.Colors.primary : Theme.Colors.text3)
                    .accessibilityLabel(countAccessibilityText)
                Spacer()
                Button("다시 고르기", action: onPick)
                    .buttonStyle(.soLink)
                    .padding(.trailing, -Theme.Spacing.s4)
                    .accessibilityHint("사진 선택 화면을 다시 열어요")
            }

            LazyVGrid(columns: columns, spacing: Theme.Spacing.s2) {
                ForEach(Array(visiblePhotos.enumerated()), id: \.element.id) { offset, photo in
                    PhotoCell(
                        state: photo.state,
                        order: offset + 1,
                        overflowCount: offset == visiblePhotos.count - 1 ? hiddenCount : 0
                    )
                }
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.s3) {
                if !snapshot.canAuthenticate {
                    BannerView(
                        tone: .error,
                        title: "기기 암호가 설정되어 있지 않아요",
                        message: "보여주기를 끝낼 때 주인 확인이 필요해서, 암호를 켜야 시작할 수 있어요."
                    )
                }
                if snapshot.failedCount > 0 && !snapshot.isLoading {
                    BannerView(
                        tone: .warning,
                        title: "\(snapshot.failedCount)장을 불러오지 못했어요",
                        message: "iCloud에서 원본을 받지 못했어요. 네트워크를 확인해 주세요.",
                        actionTitle: "다시 시도",
                        action: onRetry
                    )
                } else if snapshot.isAtLimit && !snapshot.isLoading {
                    BannerView(
                        tone: .info,
                        title: "최대 \(PhotoSelectionStore.maxCount)장까지 고를 수 있어요",
                        message: "다른 사진을 넣으려면 '다시 고르기'로 바꿔주세요."
                    )
                } else if !snapshot.isLoading && snapshot.canAuthenticate {
                    Text("보여주기를 끝내면 고른 사진도 앱에서 비워져요.")
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.text3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, Theme.Spacing.s1)
        }
    }

    // MARK: 하단

    private var bottomBar: some View {
        VStack(spacing: Theme.Spacing.s2) {
            if !snapshot.isEmpty && snapshot.canAuthenticate {
                HStack(spacing: Theme.Spacing.s1) {
                    Image(systemName: snapshot.authStatus.kind.glyphName)
                        .accessibilityHidden(true)
                    Text("끝낼 때는 내 \(snapshot.authStatus.kind.displayName)가 필요해요")
                }
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.text3)
                .multilineTextAlignment(.center)
                .padding(.bottom, Theme.Spacing.s1)
                .accessibilityElement(children: .combine)
            }

            primaryButton

            if !snapshot.isEmpty && !snapshot.canAuthenticate {
                Button("설정에서 기기 암호 켜기", action: onOpenSettings)
                    .buttonStyle(.soLink)
            } else {
                Button("알림·앱 이동 막는 법 보기", action: onGuide)
                    .buttonStyle(.soText)
            }
        }
        .padding(.horizontal, Theme.Spacing.margin)
        .padding(.top, Theme.Spacing.s3)
        .padding(.bottom, Theme.Spacing.s2)
        .background(Theme.Colors.bg.ignoresSafeArea())
    }

    @ViewBuilder
    private var primaryButton: some View {
        if snapshot.isEmpty {
            Button("사진 고르기", action: onPick)
                .buttonStyle(.soPrimary)
        } else if snapshot.isLoading {
            Button("불러오는 중…") {}
                .buttonStyle(.soPrimary)
                .disabled(true)
        } else if snapshot.loadedCount == 0 {
            // 모두 실패했으면 시작할 사진이 없으므로 다시 고르게 합니다.
            Button("사진 다시 고르기", action: onPick)
                .buttonStyle(.soPrimary)
        } else {
            Button("\(snapshot.loadedCount)장 보여주기", action: onStart)
                .buttonStyle(.soPrimary)
                .disabled(!snapshot.canAuthenticate)
                .accessibilityHint("끝낼 때는 \(snapshot.authStatus.kind.displayName) 인증이 필요해요")
        }
    }

    // MARK: 문구

    private var showsLoadProgress: Bool { snapshot.isLoading || snapshot.failedCount > 0 }

    private var headline: String {
        if snapshot.isEmpty { return "보여줄 사진만\n골라서 건네세요" }
        if snapshot.isLoading { return "사진을 불러오는 중이에요" }
        if snapshot.failedCount > 0 {
            return snapshot.loadedCount == 0 ? "사진을 불러오지 못했어요" : "\(snapshot.loadedCount)장만 불러왔어요"
        }
        return "\(snapshot.photos.count)장을 골랐어요"
    }

    private var subheadline: String {
        if snapshot.isEmpty { return "고른 사진끼리만 넘겨볼 수 있어요.\n끝낼 때는 휴대폰 주인 인증이 필요해요." }
        if snapshot.isLoading { return "iCloud에 있는 사진은 조금 더 걸릴 수 있어요." }
        if snapshot.failedCount > 0 {
            return snapshot.loadedCount == 0
                ? "다시 시도하거나 다른 사진을 골라주세요."
                : "불러온 사진만으로 바로 시작할 수 있어요."
        }
        if snapshot.isAtLimit { return "한 번에 보여줄 수 있는 최대 장수예요." }
        return "이 사진들만, 이 순서대로 보여줘요."
    }

    /// 불러오는 중·실패가 있으면 "불러온 / 고른", 아니면 "고른 / 최대"
    private var countText: String {
        if showsLoadProgress {
            return String(format: "%02d / %02d", snapshot.loadedCount, snapshot.photos.count)
        }
        return String(format: "%02d / %02d", snapshot.photos.count, PhotoSelectionStore.maxCount)
    }

    private var countAccessibilityText: String {
        if showsLoadProgress {
            return "\(snapshot.photos.count)장 중 \(snapshot.loadedCount)장 불러옴"
        }
        return "최대 \(PhotoSelectionStore.maxCount)장 중 \(snapshot.photos.count)장 선택"
    }

    /// 그리드는 한 줄(3칸)만 보여주고, 나머지는 마지막 칸의 "+N"으로 표시합니다.
    private var visiblePhotos: [SelectedPhoto] { Array(snapshot.photos.prefix(3)) }
    private var hiddenCount: Int { max(0, snapshot.photos.count - visiblePhotos.count) }
}

// MARK: - Preview

private extension HomeSnapshot {
    static let faceID = AuthStatus(canAuthenticate: true, kind: .faceID, isBiometryLockedOut: false, isBiometryUnavailable: false)
    static let noAuth = AuthStatus(canAuthenticate: false, kind: .passcodeOnly, isBiometryLockedOut: false, isBiometryUnavailable: false)

    static func sample(_ states: [PhotoLoadState], auth: AuthStatus? = nil, ended: Bool = false) -> HomeSnapshot {
        HomeSnapshot(
            photos: states.enumerated().map { SelectedPhoto(id: "\($0.offset)", state: $0.element) },
            authStatus: auth ?? faceID,
            showsSessionEndedNotice: ended
        )
    }

    static func loaded(_ count: Int) -> [PhotoLoadState] {
        let colors: [UIColor] = [.systemOrange, .systemBrown, .systemTeal, .systemIndigo, .systemGreen]
        return (0..<count).map { .loaded(.previewPlaceholder(colors[$0 % colors.count])) }
    }
}

private struct HomePreview: View {
    let snapshot: HomeSnapshot
    var body: some View {
        HomeContent(snapshot: snapshot, onPick: {}, onRetry: {}, onStart: {}, onGuide: {}, onOpenSettings: {})
    }
}

#Preview("Empty") { HomePreview(snapshot: .sample([])) }
#Preview("Selected") { HomePreview(snapshot: .sample(HomeSnapshot.loaded(3))) }
#Preview("Loading") { HomePreview(snapshot: .sample(HomeSnapshot.loaded(2) + [.loading])) }
#Preview("Partial failure") { HomePreview(snapshot: .sample(HomeSnapshot.loaded(2) + [.failed])) }
#Preview("Limit reached") { HomePreview(snapshot: .sample(HomeSnapshot.loaded(10))) }
#Preview("No device auth") { HomePreview(snapshot: .sample(HomeSnapshot.loaded(3), auth: HomeSnapshot.noAuth)) }
#Preview("Session ended") { HomePreview(snapshot: .sample([], ended: true)) }
