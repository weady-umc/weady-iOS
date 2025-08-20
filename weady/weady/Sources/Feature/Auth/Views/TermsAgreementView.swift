//
//  TermsAgreementView.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import SwiftUI
import SafariServices

private struct WebLink: Identifiable {
    let id = UUID()
    let url: URL
}

@MainActor
struct TermsAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TermsAgreementViewModel()

    // 약관 payload를 시트와 1:1로 연결하기 위한 식별 가능한 래퍼
      private struct AgreementsBox: Identifiable {
          let id = UUID()
          let value: [OnboardingAgreement]
      }
    
    // isPresented 플래그 대신 item을 사용해 레이스 조건 제거
    @State private var nextAgreements: AgreementsBox? = nil
    
    @State private var activeLink: WebLink? // 현재 선택된 약관 URL
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("서비스 이용약관")
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)
                .padding(.top, 25)
                .padding(.bottom, 36)
                .padding(.horizontal, 10)
            
            // 모두 동의
            Button {
                viewModel.toggleAll(!viewModel.isAllSelected)
            } label: {
                HStack {
                    Image(viewModel.isAllSelected ? "darkCheck" : "lightCheck")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 10)
                    Text("모두 동의")
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.black100)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            
            Divider()
                .padding(.horizontal, 13)
                .padding(.bottom, 22)
            
            // 개별 항목
            ForEach($viewModel.items) { $item in
                HStack(spacing: 12) {
                    Button {
                        item.isOn.toggle()
                    } label: {
                        HStack {
                            Image(item.isOn ? "darkCheck" : "lightCheck")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 10)
                            Text(item.label)
                                .fontName(.bodyRegular16)
                                .foregroundStyle(Color.black100)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let url = item.url {
                        Button {
                            activeLink = WebLink(url: url) //
                        } label: {
                            Text("보기")
                                .fontName(.captionSemibold14)
                                .underline()
                                .foregroundStyle(Color.gray700)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(item.title) 전문 보기")
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 22)
            }
            
            Spacer()
            
            // 다음
            Button {
                let payload = viewModel.makeAgreementsPayload()
                // 디버그 & 안전 가드
                assert(!payload.isEmpty, "Agreements payload should NOT be empty at TermsAgreementView")
                print("DEBUG Terms →", payload.map { "\($0.termsType)=\($0.isAgreed)" })
                nextAgreements = AgreementsBox(value: payload)
            } label: {
                Text("다음")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.requiredAgreed ? Color.black100 : Color.gray800)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.requiredAgreed)
            .padding(.bottom, 22)
            
        }
        .padding(.horizontal, 20)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("authBackIcon")
                        .resizable()
                        .frame(width:10, height: 16)
                        .padding(.leading, 5)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(item: $nextAgreements) { box in
            NicknameInputView(agreements: box.value)
        }
        // URL 시트 표시
        .sheet(item: $activeLink) { link in
            SafariSheet(url: link.url)
                .ignoresSafeArea()
        }
    }
}
// SFSafariViewController 래퍼
private struct SafariSheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = .label
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 업데이트 로직 필요 없음
    }
}


#Preview {
    NavigationStack {
        TermsAgreementView()
    }
}

