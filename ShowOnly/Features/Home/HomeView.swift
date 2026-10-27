import SwiftUI
import PhotosUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var session: PhotoSessionStore
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var loadedPhotos: [UIImage] = []
    @State private var isLoading = false
    @State private var message: String?
    @State private var showGuide = false

    private let authentication = AuthenticationService()
    private let tint = Color(red: 0.12, green: 0.63, blue: 0.55)

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                Spacer(minLength: 20)

                Image(systemName: "hand.raised.fingers.spread.fill")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(tint)
                    .accessibilityHidden(true)

                Text("이것만 봐")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("친구에게 휴대폰을 건넬 땐,\n보여주고 싶은 사진만 골라주세요.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    Label("선택하지 않은 사진은 불러오지 않아요", systemImage: "photo.on.rectangle")
                    Label("보여주기 종료 시 기기 인증을 요청해요", systemImage: "faceid")
                    Label("사진은 서버로 전송되지 않아요", systemImage: "iphone")
                }
                .font(.subheadline)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                Spacer()

                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Label("사진 선택하기", systemImage: "photo.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                }
                .buttonStyle(.borderedProminent)
                .tint(tint)
                .disabled(isLoading)

                if isLoading {
                    ProgressView("선택한 사진을 불러오는 중")
                        .frame(maxWidth: .infinity)
                } else if !loadedPhotos.isEmpty {
                    Button("선택한 \(loadedPhotos.count)장 보여주기") {
                        guard authentication.canAuthenticate() else {
                            message = "기기에 Face ID 또는 암호가 설정되어 있어야 보호 모드를 시작할 수 있어요."
                            return
                        }
                        session.begin(with: loadedPhotos)
                        // 뷰어는 세션이 보유하므로, 홈에서는 참조를 내려놓습니다.
                        loadedPhotos.removeAll()
                        pickerItems.removeAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .frame(maxWidth: .infinity)
                }

                Button {
                    showGuide = true
                } label: {
                    Label("카톡 알림·앱 이동 보호 설정", systemImage: "shield.lefthalf.filled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Text("참고: 앱 자체는 홈 화면 이동이나 다른 앱의 알림을 차단할 수 없어요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showGuide) {
                ProtectionGuideView()
            }
            .fullScreenCover(isPresented: $session.isPresented) {
                HandoffViewer()
                    .environmentObject(session)
            }
            .alert("확인해 주세요", isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            )) {
                Button("확인", role: .cancel) { message = nil }
            } message: {
                Text(message ?? "")
            }
            .onChange(of: pickerItems) { items in
                Task { await loadPhotos(items) }
            }
        }
    }

    @MainActor
    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        isLoading = true
        loadedPhotos = []
        if items.isEmpty {
            isLoading = false
            return
        }
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        // 이미지가 큰 경우 메모리 최적화가 추후 필요합니다.
        loadedPhotos = images
        isLoading = false
        if images.isEmpty {
            message = "사진을 불러오지 못했어요. 다른 사진을 선택해 주세요."
        } else if images.count != items.count {
            message = "일부 사진은 불러오지 못했어요. 불러온 \(images.count)장만 보여줄 수 있어요."
        }
    }
}
