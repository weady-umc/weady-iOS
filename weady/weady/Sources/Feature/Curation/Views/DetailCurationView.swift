//
//  DetailCurationView.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//



import SwiftUI
import UIKit


struct DetailCurationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isTabBarHidden: Bool
    @EnvironmentObject private var homeRouter: HomeRouter
    

    let curationId: Int64

    init(curationId: Int64, isTabBarHidden: Binding<Bool>) {
        self.curationId = curationId
        self._isTabBarHidden = isTabBarHidden

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    @StateObject private var vm = DetailCurationViewModel()
    @StateObject private var scrapVm = WeadychiveViewModel()
    @State private var currentIndex: Int = 0
    @State private var isScrapped: Bool = false
    @State private var currentAddress: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 25) {
                DetailCurationImageCarousel(currentIndex: $currentIndex,
                                            imageURLs: vm.detail?.imageURLs ?? [])
                DetailCurationMapButton(address: currentAddress, currentIndex: currentIndex)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            if vm.isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            DetailTopBar(
                title: titleTwoLinesAuto(vm.detail?.title ?? ""),
                onBack: {
                    homeRouter.push(.weatherhome(initial: .third))
                },
                isScrapped: isScrapped,
                onToggleScrap: { toggleScrap() }
            )
            .padding(.top, 36)
            
        }
        .task { await vm.load(curationId: curationId) }
        .onChange(of: scrapVm.scrappedCurationItems, initial: true) { _, newList in
            // WeadychiveViewModel.init()에서 fetchScrappedCurations()가 호출되어
            // scrappedCurationItems 채움. 목록에 현재 curationId가 있으면 꽉채워지 북마크로 동기화.
            let ids = Set(newList.map { Int64($0.id) })  // CurationItem(id:title:firstImgUrl:)
            withAnimation(.easeInOut(duration: 0.2)) {
                isScrapped = ids.contains(curationId)
            }
        }
        .onAppear { isTabBarHidden = true }
        .onDisappear { isTabBarHidden = false }
        .onChange(of: currentIndex) { _, _ in
            updateCurrentAddress()
        }
        .onChange(of: vm.detail?.images ?? [], initial: true) { _, _ in
            updateCurrentAddress()
        }
    }
       
}

// MARK: - Custom Top Bar (replaces Toolbar)
private struct DetailTopBar: View {
    let title: String
    let onBack: () -> Void
    let isScrapped: Bool
    let onToggleScrap: () -> Void

    var body: some View {
        ZStack {
           
            Text(title)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .allowsTightening(true)
                .fontName(.captionMedium14)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.68)

          
            HStack {
                Button(action: onBack) {
                    Image("backicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 20)
                        .padding(10)
                        .contentShape(Rectangle())
                }

                Spacer(minLength: 0)

                Button(action: onToggleScrap) {
                    ZStack {
                        Image("scrap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 60)
                            .opacity(isScrapped ? 0 : 1)
                        Image("scrapfilled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 60)
                            .opacity(isScrapped ? 1 : 0)
                    }
                    .padding(10)
                    .contentShape(Rectangle())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .padding(.horizontal, 8)
        .background(Color.white)
      
    }
    
    
}


// MARK: - ViewModel
@MainActor
final class DetailCurationViewModel: ObservableObject {
    @Published var detail: CurationDetail? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func load(curationId: Int64) async {
        isLoading = true
        errorMessage = nil
        await withCheckedContinuation { cont in
            CurationServices.shared.getCurationDetail(curationId: curationId) { [weak self] (result: Result<ApiResponseCurationByCurationIdResponseDto, CurationServices.APIError>) in
                guard let self = self else { cont.resume(); return }
                self.isLoading = false
                switch result {
                case .success(let dto):
                    // 서버 응답 → 도메인 매핑! (imgOrder 기준 정렬 포함)
                    self.detail = CurationMapper.toDetail(from: dto)
                case .failure(let error):
                    self.errorMessage = String(describing: error)
                }
                cont.resume()
            }
        }
    }
}

// MARK: - 이미지 캐러셀 (에러 처리도 포함)
private struct DetailCurationImageCarousel: View {
    @Binding var currentIndex: Int
    let imageURLs: [URL]

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            VStack(spacing: 10) {
                                ProgressView()
                                    .controlSize(.large)
//MARK: - 로딩 오래 걸린다해서 로딩 중 표시 문구 만듬
                                Text("로딩중이에요. 잠시 기다려주세요:)")
                                    .font(.system(size: 13, weight: .medium))
                                    .multilineTextAlignment(.center)
                                Text("회원님이 선택한 장소와 날씨를 조합해서 추천 장소를 만들고 있어요!")
                                    .font(.system(size: 13, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 600)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(12)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth:.infinity)
                                .frame(height : 600)
                                .clipped()
                        case .failure:
                            ProgressView()
                                .controlSize(.large)
//MARK: - 로딩 오래 걸린다해서 로딩 중 표시 문구 만듬
                            Text("로딩중이에요. 잠시 기다려주세요:)")
                                .font(.system(size: 13, weight: .medium))
                                .multilineTextAlignment(.center)
                            Text("회원님이 선택한 장소와 날씨를 조합해서 추천 장소를 만들고 있어요!")
                                .font(.system(size: 13, weight: .medium))
                                .multilineTextAlignment(.center)
                        @unknown default:
                            ProgressView()
                                .controlSize(.large)
//MARK: - 로딩 오래 걸린다해서 로딩 중 표시 문구 만듬
                            Text("로딩중이에요. 잠시 기다려주세요:)")
                                .font(.system(size: 13, weight: .medium))
                                .multilineTextAlignment(.center)
                            Text("회원님이 선택한 장소와 날씨를 조합해서 추천 장소를 만들고 있어요!")
                                .font(.system(size: 13, weight: .medium))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 370, height: 556)
            .cornerRadius(10)
            .ignoresSafeArea(.all, edges: .horizontal)

            IndicatorBarView(currentIndex: currentIndex, count: max(imageURLs.count, 1))
                .padding(.top, 16)
        }
    }
}

// MARK: - 네이버 지도 연결 버튼 (ContentView 스타일 로그 포함)
private struct DetailCurationMapButton: View {
    let address: String
    let currentIndex: Int
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        Button(action: onTap) {
            Image("goToNaverMap")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
        }
        .alert("안내", isPresented: $showAlert, actions: { Button("확인", role: .cancel) {} }, message: { Text(alertMessage) })
    }

    private func onTap() {
        print("[NaverMap] 🔹 tap. currentIndex=\(currentIndex), raw address='\(address)'")

        // 표지(첫 장)는 길찾기 대상이 아님
        if currentIndex == 0 {
            alertMessage = "첫 번째 이미지는 표지입니다. 다음 이미지부터 길찾기를 이용할 수 있어요."
            showAlert = true
            print("[NaverMap] ℹ️ index 0 (표지) → 길찾기 차단")
            return
        }

        let query = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, query != "표지" else {
            alertMessage = "주소 정보가 없어요. 다른 이미지를 선택해 주세요."
            showAlert = true
            print("[NaverMap] ℹ️ 빈 주소/표지 → 중단")
            return
        }

        // 런타임 점검 로그: Info.plist와 LSApplicationQueriesSchemes, bundleID
        let bundleID = Bundle.main.bundleIdentifier ?? "com.weady.Weady"
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            print("[NaverMap] ℹ️ Info.plist path =", infoPath)
        } else {
            print("[NaverMap] ℹ️ Info.plist path not found via Bundle.main")
        }
        print("[NaverMap] ℹ️ LSApplicationQueriesSchemes =", Bundle.main.infoDictionary?["LSApplicationQueriesSchemes"] ?? "nil")
        print("[NaverMap] ℹ️ bundleID =", bundleID)

        // 1) 검색어 인코딩
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // 2) Naver Map 검색 URL (문서 규격)
        //    nmap://search?query=<encoded>&appname=<bundleID>
        let schemeString = "nmap://search?query=\(encoded)&appname=\(bundleID)"
        guard let schemeURL = URL(string: schemeString) else {
            print("[NaverMap] ❌ URL 생성 실패:", schemeString)
            alertMessage = "주소 URL을 만들지 못했어요."
            showAlert = true
            return
        }
        print("[NaverMap] 🔍 schemeURL =", schemeURL.absoluteString)

        // 3) App Store 폴백 URL (네이버 지도: id311867728)
        let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id311867728")!

        // 4) 바로 열어보고 실패 시 App Store로 폴백
        print("[NaverMap] ▶️ open 시도")
        UIApplication.shared.open(schemeURL, options: [:]) { ok in
            print("[NaverMap] open 완료:", ok)
            if !ok {
                print("[NaverMap] ⚠️ open 실패 → App Store로 폴백:", appStoreURL.absoluteString)
                UIApplication.shared.open(appStoreURL, options: [:]) { ok2 in
                    print("[NaverMap] App Store open 완료:", ok2)
                }
            }
        }
    }
}

// MARK: - 이미지 인디케이터
private struct IndicatorBarView: View {
    let currentIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                if index == currentIndex {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 20, height: 6)
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

extension DetailCurationView {
    /// 토글: 스크랩 ⇄ 스크랩 취소
    fileprivate func toggleScrap() {
        let id = Int(curationId)
        if isScrapped {
            scrapVm.removeCurationScrap(curationId: id)
            withAnimation { isScrapped = false }
        } else {
            scrapVm.postCurationScrap(curationId: id)
            withAnimation { isScrapped = true }
        }
    }
    
    /// 현재 캐러셀 인덱스에 해당하는 이미지 주소를 `currentAddress`에 저장
    fileprivate func updateCurrentAddress() {
        let imgs = vm.detail?.images ?? []
        if currentIndex >= 0 && currentIndex < imgs.count {
            currentAddress = imgs[currentIndex].address
        } else {
            currentAddress = ""
        }
    }
    
    //MARK: -큐레이션 제목 받은거 적절히 두줄로 분기시켜주는 알고리즘
    /// 제목을 두 줄로 보이게 하기 위해 문자열 중앙 근처의 공백(또는 적절한 위치)에 줄바꿈을 삽입
    /// - 전략: 문자열 길이의 절반에 가장 가까운 공백을 찾고, 없으면 정확히 절반 지점에서 줄바꿈
    fileprivate func twoLineTitle(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 0 else { return s }
        let mid = trimmed.index(trimmed.startIndex, offsetBy: trimmed.count / 2)

        // 공백 인덱스 후보: mid에서 좌/우로 가장 가까운 공백
        let leftSpace = trimmed[..<mid].lastIndex(of: " ")
        let rightSpace = trimmed[mid...].firstIndex(of: " ")

        let breakIndex: String.Index
        if let l = leftSpace, let r = rightSpace {
            // mid와 더 가까운 쪽 선택
            let distL = trimmed.distance(from: l, to: mid)
            let distR = trimmed.distance(from: mid, to: r)
            breakIndex = distL <= distR ? l : r
        } else if let l = leftSpace {
            breakIndex = l
        } else if let r = rightSpace {
            breakIndex = r
        } else {
            // 공백이 전혀 없으면 정확히 중앙에서 줄바꿈
            breakIndex = mid
        }

        var result = trimmed
        result.replaceSubrange(breakIndex...breakIndex, with: "\n")
        return result
    }
    /// 공백 단위로 두 줄을 균형 있게 나누어 모든 글자가 보이도록 구성
    /// - 전략: 문자열 렌더링 폭을 측정하여 첫 줄 폭이 전체 폭의 절반을 넘지 않도록 적절한 위치에 줄바꿈 삽입
    fileprivate func balancedTwoLineTitle(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return s }

    
        let attributes: [NSAttributedString.Key: Any] = [.font: font]

     
        let fullWidth = (trimmed as NSString).size(withAttributes: attributes).width
        let halfWidth = fullWidth / 2

       
        var breakIndex: String.Index? = nil
        var lastSpaceBeforeHalf: String.Index? = nil
        var currentLine = ""

        for (i, char) in trimmed.enumerated() {
            let index = trimmed.index(trimmed.startIndex, offsetBy: i)
            currentLine.append(char)
            let currentWidth = (currentLine as NSString).size(withAttributes: attributes).width
            if currentWidth > halfWidth {
             
                if let spaceIndex = lastSpaceBeforeHalf {
                    breakIndex = spaceIndex
                } else {
                  
                    breakIndex = index
                }
                break
            }
            if char == " " {
                lastSpaceBeforeHalf = index
            }
        }


        if breakIndex == nil {
            return trimmed
        }

        var result = trimmed
        result.replaceSubrange(breakIndex!...breakIndex!, with: "\n")
        return result
    }
    /// 툴바 중앙 타이틀을 두 줄로 나누어 모든 글자가 보이도록 줄바꿈 위치를 결정
    /// 공백 위치들을 후보로 삼아, 좌/우 렌더링 폭이 모두 허용 폭을 넘지 않도록 하되,
    /// 초과폭이 최소이고 좌우 균형이 좋은 후보를 선택한다.
    fileprivate func titleTwoLinesAuto(_ s: String) -> String {
        let text = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return s }

        
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]

        
        let maxWidth = UIScreen.main.bounds.width * 0.68

      
        func lineWidth(_ str: String) -> CGFloat {
            (str as NSString).size(withAttributes: attrs).width
        }

       
        let spaces = text.indices.filter { text[$0] == " " }
        if spaces.isEmpty {
            let mid = text.index(text.startIndex, offsetBy: text.count/2)
            return String(text[..<mid]) + "\n" + String(text[mid...])
        }

     
        let punctuation: Set<Character> = [",", "，", "、"]
        let mid = text.index(text.startIndex, offsetBy: text.count/2)

    
        let punctIndices: [String.Index] = text.indices.filter { punctuation.contains(text[$0]) }

        struct Candidate { let idx: String.Index; let overflow: CGFloat; let balance: CGFloat; let distToMid: Int }

        func evaluateCandidate(_ at: String.Index, consumePunctuation: Bool) -> Candidate {
           
            let left = String(text[..<text.index(after: at)])
            let rightRaw = String(text[text.index(after: at)...])
            let right = rightRaw.trimmingCharacters(in: .whitespaces)
            let lw = lineWidth(left)
            let rw = lineWidth(right)
            let overflow = max(0, lw - maxWidth) + max(0, rw - maxWidth)
            let dist = abs(text.distance(from: at, to: mid))
            let balance = abs(lw - rw)
            return Candidate(idx: at, overflow: overflow, balance: balance, distToMid: dist)
        }

      
        var bestPunct: Candidate? = nil
        for idx in punctIndices {
            let cand = evaluateCandidate(idx, consumePunctuation: true)
            if let cur = bestPunct {
                if cand.overflow < cur.overflow ||
                   (cand.overflow == cur.overflow && (cand.distToMid < cur.distToMid ||
                   (cand.distToMid == cur.distToMid && cand.balance < cur.balance))) {
                    bestPunct = cand
                }
            } else {
                bestPunct = cand
            }
        }

       
        if let p = bestPunct, p.overflow == 0 {
            let left = String(text[..<text.index(after: p.idx)])
            let right = String(text[text.index(after: p.idx)...]).trimmingCharacters(in: .whitespaces)
            return left + "\n" + right
        }

       
        struct SpaceCandidate { let idx: String.Index; let overflow: CGFloat; let balance: CGFloat }
        var best: SpaceCandidate? = nil
        for idx in spaces {
            let left = String(text[..<idx])
            let right = String(text[text.index(after: idx)...])
            let lw = lineWidth(left)
            let rw = lineWidth(right)
            let overflow = max(0, lw - maxWidth) + max(0, rw - maxWidth)
            let balance = abs(lw - rw)
            let cand = SpaceCandidate(idx: idx, overflow: overflow, balance: balance)
            if let cur = best {
                if cand.overflow < cur.overflow || (cand.overflow == cur.overflow && cand.balance < cur.balance) {
                    best = cand
                }
            } else {
                best = cand
            }
        }

        if let cut = best?.idx {
            let left = String(text[..<cut])
            let right = String(text[text.index(after: cut)...])
            return left + "\n" + right
        }

      
        let hard = text.index(text.startIndex, offsetBy: text.count/2)
        return String(text[..<hard]) + "\n" + String(text[hard...])
    }
}



//MARK: -일반 프릐뷰
#Preview {
    DetailCurationView(curationId: 8, isTabBarHidden: .constant(true))
}

// MARK: - 푸시용 프리뷰 (툴바까지 보게해줌!)
private struct DetailCurationToolbarPreviewHarness: View {
    @State private var path: [Int] = []

    var body: some View {
        NavigationStack(path: $path) {
         
            Color.clear
                .onAppear {
                 
                    if path.isEmpty { path.append(1) }
                }
                .navigationDestination(for: Int.self) { _ in
                    DetailCurationView(curationId:11, isTabBarHidden: .constant(false))
                        .toolbarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
        }
    }
}

#Preview("DetailCuration Toolbar (pushed)") {
    DetailCurationToolbarPreviewHarness()
}
