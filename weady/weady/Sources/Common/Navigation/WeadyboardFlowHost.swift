//
//  WeadyboardFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

// MARK: - WeadyboardRoute
/// 웨디보드 플로우에서 사용하는 라우트 정의
enum WeadyboardRoute: Hashable {
    case weadyboard
    case weadyboardPost(boardId: Int)
    case weadyboardPostReportDetail(ReportReason, boardId: Int)
    case weadyboardUpload
}

// MARK: - WeadyboardRouter
/// 웨디보드 플로우의 NavigationPath와 push/pop/reset 제공
@Observable
final class WeadyboardRouter {
    // MARK: Properties
    var path = NavigationPath()
    
    // MARK: Navigation Actions
    func push(_ route: WeadyboardRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

// MARK: - WeadyboardFlowHost
/// 웨디보드 플로우 전용 NavigationStack
/// 웨디보드 관련 화면 전환은 여기에서 관리
struct WeadyboardFlowHost: View {
    // MARK: Properties
    @State private var router = WeadyboardRouter()
    @StateObject private var reportVM = WeadyboardReportViewModel()
    @Environment(WeadyboardRouteBridge.self) private var weadyboardBridge
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $router.path) {
            WeadyboardView()
                .navigationDestination(for: WeadyboardRoute.self) { route in
                    switch route {
                    case .weadyboard:
                        WeadyboardView()
                    case .weadyboardPost(let boardId):
                        WeadyboardPostView(boardId: boardId, isTabBarHidden: .constant(true))
                    case .weadyboardPostReportDetail(let reason, let boardId):
                        WeadyboardPostReportDetailView(
                            reason: reason,
                            selectedReasonIndex: reportVM.selectedReasonIndex ?? 0,
                            boardId: boardId,
                            reportViewModel: reportVM
                        )
                    case .weadyboardUpload:
                        UploadView()
                    }
                }
        }
        // 다른 탭에서 웨디보드 플로우로 연결
        .onAppear {
            weadyboardBridge.handler = { route in
                router.push(route)
            }
        }
        .onDisappear {
            weadyboardBridge.handler = nil
        }
        // 필요 시 하위 뷰에서 @Environment(WeadyboardRouter.self)로 직접 push/pop 가능
        .environment(router)
    }
}
