//
//  WeadyboardPostReportNavigationSheet.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyboardPostReportNavigationSheet: View {
    @State private var path = NavigationPath()
    let boardId: Int
    @ObservedObject var reportViewModel: WeadyboardReportViewModel

    var body: some View {
        NavigationStack(path: $path) {
            WeadyboardPostReportSheet(reportViewModel: reportViewModel, navigationPath: $path)
                .navigationDestination(for: ReportReason.self) { reason in
                    WeadyboardPostReportDetailView(
                        reason: reason,
                        selectedReasonIndex: reportViewModel.selectedReasonIndex ?? 0,
                        boardId: boardId,
                        reportViewModel: reportViewModel
                    )
                }
        }
        .frame(width: 375, height: 759)
    }
}
