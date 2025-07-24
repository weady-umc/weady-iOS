//
//  WeadyboardPostReportNavigationSheet.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyboardPostReportNavigationSheet: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            WeadyboardPostReportSheet()
                .navigationDestination(for: ReportReason.self) { reason in
                    WeadyboardPostReportDetailView(reason: reason)
                }
        }
        .frame(width: 375, height: 759)
    }
}
