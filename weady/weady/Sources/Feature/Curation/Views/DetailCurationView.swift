//
//  DetailCurationView.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import SwiftUI


struct DetailCurationView: View {
    @Environment(\.dismiss) private var dismiss
    

    let curationId: Int64

    init(curationId: Int64) {
        self.curationId = curationId
        // iOS 16 이하에서도 네비게이션 바 밑 선 제거
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    @StateObject private var vm = DetailCurationViewModel()
    @StateObject private var scrapVm = WeadychiveViewModel()
    @State private var currentIndex: Int = 0
    @State private var isScrapped: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 25) {

                DetailCurationImageCarousel(currentIndex: $currentIndex,
                                            imageURLs: vm.detail?.imageURLs ?? [])

                DetailCurationMapButton()
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 100)

            if vm.isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .navigationBarBackButtonHidden(true)

        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
      
       
        

        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("backicon")
                        .padding(.top, 50)
                        .padding(10)
                        .frame(width: 44, height: 44, alignment: .center)
                }
            }

           
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(titleTwoLinesAuto(vm.detail?.title ?? ""))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                        .fontName(.captionMedium14)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.68)
                   
                }
                .padding(.top, 50)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { toggleScrap() }) {
                    Image(isScrapped ? "scrapfilled" : "scrap")
                        .padding(.top, 50)
                }
            }
        }
        
        .task { await vm.load(curationId: curationId) }
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
                    // 서버 응답 → 도메인 매핑 (imgOrder 기준 정렬 포함)
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
                            Color.gray.opacity(0.15)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        case .failure:
                            Color.gray.opacity(0.25)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        @unknown default:
                            Color.gray.opacity(0.2)
                                .frame(width: UIScreen.main.bounds.width, height: 600)
                                .clipped()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 350, height: 556)
            .cornerRadius(10)
            .ignoresSafeArea(.all, edges: .horizontal)

            IndicatorBarView(currentIndex: currentIndex, count: max(imageURLs.count, 1))
                .padding(.top, 16)
        }
    }
}

// MARK: - 네이버 지도 연결 버튼
private struct DetailCurationMapButton: View {
    var body: some View {
        Button(action: { /* TODO: - 네이버 지도로 연결 */ }) {
            Image("goToNaverMap")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
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
           
            isScrapped = true
           
            self.isScrapped = false
        } else {
            scrapVm.postCurationScrap(curationId: id)
           
            isScrapped = false
            self.isScrapped = true
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
    DetailCurationView(curationId: 8)
}

// MARK: - 푸시용 프리뷰 (툴바까지 보게해줌!)
private struct DetailCurationToolbarPreviewHarness: View {
    @State private var path: [Int] = []

    var body: some View {
        NavigationStack(path: $path) {
            // Dummy root; we immediately push to show a back button in the toolbar
            Color.clear
                .onAppear {
                    // Push once so DetailCurationView is not the root
                    if path.isEmpty { path.append(1) }
                }
                .navigationDestination(for: Int.self) { _ in
                    DetailCurationView(curationId: 9)
                        .toolbarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
        }
    }
}

#Preview("DetailCuration Toolbar (pushed)") {
    DetailCurationToolbarPreviewHarness()
}
