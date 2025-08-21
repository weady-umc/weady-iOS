import SwiftUI

// MARK: - MyPageRoute
enum MyPageRoute: Hashable {
    case mypage
    case setting
    case profileEdit
    case weadyboardUpload
}

// MARK: - MyPageRouter
/// SwiftUI에서 @StateObject / @EnvironmentObject로 사용 가능
final class MyPageRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: MyPageRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

// MARK: - MyPageFlowHost
struct MyPageFlowHost: View {
    @StateObject private var router = MyPageRouter()
    @StateObject var mypageVM = MypageViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView(viewModel: mypageVM)
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .mypage:
                        MyPageView(viewModel: mypageVM)
                    case .setting:
                        SettingView()
                    case .profileEdit:
                        ProfileEditView(viewModel: ProfileEditViewModel(mypageViewModel: mypageVM))
                    case .weadyboardUpload:
                        UploadView()
                    }
                }
        }
        .environmentObject(router)  // 하위 뷰에서 접근 가능
    }
}
