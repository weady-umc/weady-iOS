//
//  WeadyboardFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

enum WeadyboardRoute: Hashable {
    case list
    case post(boardId: Int)
    case reportDetail(ReportReason, boardId: Int)
}

@Observable
final class WeadyboardRouter {
    var path = NavigationPath()
    func push(_ route: WeadyboardRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

struct WeadyboardFlowHost: View {
    @State private var router = WeadyboardRouter()
    @StateObject private var reportVM = WeadyboardReportViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            WeadyboardView() 
                .navigationDestination(for: WeadyboardRoute.self) { route in
                    switch route {
                    case .list:
                        WeadyboardView()
                    case .post(let boardId):
                        WeadyboardPostView(isTabBarHidden: .constant(true), boardId: boardId)
                    case .reportDetail(let reason, let boardId):
                        WeadyboardPostReportDetailView(
                            reason: reason,
                            selectedReasonIndex: reportVM.selectedReasonIndex ?? 0,
                            boardId: boardId,
                            reportViewModel: reportVM
                        )
                    }
                }
        }
        .environment(router)
    }
}
