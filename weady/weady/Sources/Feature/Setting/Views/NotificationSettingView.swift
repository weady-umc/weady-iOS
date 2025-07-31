//
//  NotificationSettingView.swift
//  weady
//
//  Created by 김영택 on 7/17/25.
//
import SwiftUI

struct NotificationSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotificationSettingViewModel()
    
    /// 시트 표시 상태
    @State private var showTimePicker = false
    @State private var showConditionPicker = false
    
    @State private var showDailyTimePicker = false
    @State private var showDailyConditionPicker = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: 푸시 알림 섹션
            SectionView(title: "푸시 알림") {
                Spacer().frame(height:14.5)
                
                toggleRow(for: .appPush)
            }
            
            // MARK: 웨디 알림 섹션
            SectionView(title: "웨디 알림") {
                Spacer().frame(height:14.5)
                
                // 눈/비 알림
                toggleRow(for: .snowRain, showDivider: false)
                // 설명
                if let footer = NotificationType.snowRain.footerText {
                    Text(footer)
                        .font(AppTextStyle.metaMedium10.font)
                        .foregroundStyle(Color.gray900)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 구분선은 snowRain이 꺼져 있을 때만
                if !viewModel.binding(for: .snowRain).wrappedValue {
                    Divider()
                }
                
                if viewModel.binding(for: .snowRain).wrappedValue {
                    VStack(spacing: 12) {
                        // 시간 설정 버튼
                        Button {
                            showTimePicker = true
                        } label: {
                            HStack {
                                Text("시간")
                                    .font(AppTextStyle.metaMedium12.font)
                                    .foregroundStyle(Color.black100)
                                Spacer()
                                HStack(spacing: 13) {
                                    Text(viewModel.snowRainTimeText)
                                        .font(AppTextStyle.captionRegular14.font)
                                        .foregroundStyle(Color.gray200)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.gray200)
                                }
                            }
                        }
                        .padding(.top, 11)
                        
                        // 조건 설정 버튼
                        Button {
                            showConditionPicker = true
                        } label: {
                            HStack {
                                Text("조건")
                                    .font(AppTextStyle.metaMedium12.font)
                                    .foregroundStyle(Color.black100)
                                Spacer()
                                HStack(spacing: 13) {
                                    Text("설정 요일")
                                        .font(AppTextStyle.captionRegular14.font)
                                        .foregroundStyle(Color.gray200)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.gray200)
                                }
                            }
                        }
                        .padding(.bottom, 9)
                        
                    }
                    .padding(.horizontal, 15)
                    .background(Color.white400)
                    .cornerRadius(8)
                    .padding(.vertical, 7.5)
                }
                
                // 하루 추천 알림 토글
                toggleRow(for: .daily, showDivider: !viewModel.binding(for: .daily).wrappedValue)
                    .padding(.top, 12)
                
                if viewModel.binding(for: .daily).wrappedValue {
                    VStack(spacing: 12) {
                        // 시간 설정 버튼
                        Button {
                            showDailyTimePicker = true
                        } label: {
                            HStack {
                                Text("시간")
                                    .font(AppTextStyle.metaMedium12.font)
                                    .foregroundStyle(Color.black100)
                                Spacer()
                                HStack(spacing: 13) {
                                    Text(viewModel.dailyTimeText)
                                        .font(AppTextStyle.captionRegular14.font)
                                        .foregroundStyle(Color.gray200)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.gray200)
                                }
                            }
                        }
                        .padding(.top, 11)
                        
                        // 조건 설정 버튼
                        Button {
                            showDailyConditionPicker = true
                        } label: {
                            HStack {
                                Text("조건")
                                    .font(AppTextStyle.metaMedium12.font)
                                    .foregroundStyle(Color.black100)
                                Spacer()
                                HStack(spacing: 13) {
                                    Text("설정 요일")
                                        .font(AppTextStyle.captionRegular14.font)
                                        .foregroundStyle(Color.gray200)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.gray200)
                                }
                            }
                        }
                        .padding(.bottom, 9)
                    }
                    .padding(.horizontal, 15)
                    .background(Color.white400)
                    .cornerRadius(8)
                    .padding(.top, 26)
                }
                
            }
            
            // MARK: 웨디보드 알림 섹션
            SectionView(title: "웨디보드 알림") {
                Spacer().frame(height:14.5)
                
                toggleRow(for: .like)
                Spacer().frame(height:12)
                
                toggleRow(for: .comment)
                Spacer().frame(height:12)
                
                toggleRow(for: .scrap)
            }
            
            // MARK: 혜택·이벤트 및 기타 알림 섹션
            SectionView(title: "혜택•이벤트 및 기타 알림") {
                Spacer().frame(height:14.5)
                
                toggleRow(for: .personalInfoAgree)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 34)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.saveSettings()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.black)
                }
            }
        }
        .navigationTitle("알림 설정")
        .navigationBarTitleDisplayMode(.inline)
        
        // 시간 피커 시트
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                date: $viewModel.snowRainTime,
                dismissAction: { showTimePicker = false }
            )
            .presentationDetents([.fraction(0.4)])
        }
        // 조건 선택 시트
        .sheet(isPresented: $showConditionPicker) {
            ConditionPickerSheet(
                selected: $viewModel.snowRainSelectedWeekdays,
                dismissAction: { showConditionPicker = false }
            )
            .presentationDetents([.medium])
        }
        // 하루 추천 알림 시간 시트
        .sheet(isPresented: $showDailyTimePicker) {
            TimePickerSheet(
                date: $viewModel.dailyTime,
                dismissAction: { showDailyTimePicker = false }
            )
            .presentationDetents([.fraction(0.4)])
        }
        // 하루 추천 알림 조건 시트
        .sheet(isPresented: $showDailyConditionPicker) {
            ConditionPickerSheet(
                selected: $viewModel.dailySelectedWeekdays,
                dismissAction: { showDailyConditionPicker = false }
            )
            .presentationDetents([.medium])
        }
    }
    
    
    
    /// 개별 Row: 토글 + 옵션에 따른 Divider
    private func toggleRow(
        for type: NotificationType,
        showDivider: Bool = true
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(type.title)
                    .font(AppTextStyle.captionRegular14.font)
                    .foregroundStyle(type == .personalInfoAgree ? Color.gray300 : Color.black)
                    .underline(type == .personalInfoAgree, color: Color.gray300)
                Spacer()
                Toggle("", isOn: viewModel.binding(for: type))
                    .labelsHidden()
                    .toggleStyle(SmallToggleStyle())
            }
            
            if showDivider {
                Spacer().frame(height: 12)
                Divider()
            }
        }
    }
}


/// 공통 섹션 레이아웃
private struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTextStyle.captionSemibold14.font)
                .foregroundStyle(Color.black)
            content
        }
        .padding(.top, 32.5)
        
    }
}

/// 30×16.875pt 크기의 커스텀 토글 스타일
struct SmallToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 8.4375)
                .fill(configuration.isOn ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 30, height: 16.875)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 13, height: 13)
                        .offset(x: configuration.isOn ? 6.5 : -6.5)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: — 시간 선택 시트
private struct TimePickerSheet: View {
    @Binding var date: Date
    let dismissAction: () -> Void
    
    var body: some View {
        VStack {

            // 헤더
            HStack {
                Button("취소") { dismissAction() }
                    .font(AppTextStyle.captionMedium14.font)
                    .foregroundStyle(Color.black100)
                    .buttonStyle(.plain)
                
                Spacer()
                
                Button("선택") { dismissAction() }
                    .font(AppTextStyle.captionMedium14.font)
                    .foregroundStyle(Color.black100)
                    .buttonStyle(.plain)
            }
            .padding()
            
            // 휠 피커
            DatePicker(
                "",
                selection: $date,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            Spacer()
            
        }
    }
}

// MARK: — 조건 선택 시트
private struct ConditionPickerSheet: View {
    @Binding var selected: Set<NotificationWeekday>
    let dismissAction: () -> Void
    
    /// 로컬 임시 선택 (취소 시 복원)
    @State private var tempSelection: Set<NotificationWeekday> = []
    
    var body: some View {
        VStack {
            // 헤더
            HStack {
                Button("취소") { dismissAction() }
                    .font(AppTextStyle.captionMedium14.font)
                    .foregroundStyle(Color.black100)
                    .buttonStyle(.plain)
                
                Spacer()
                
                Button("선택") {
                    selected = tempSelection
                    dismissAction()
                }
                .font(AppTextStyle.captionMedium14.font)
                .foregroundStyle(Color.black100)
                .buttonStyle(.plain)
            }
            .padding()
            
            // 요일 리스트
            List {
                ForEach(NotificationWeekday
                    .allCases
                    .sorted(by: { $0.rawValue < $1.rawValue })
                ) { day in
                    HStack {
                        Text(day.title)
                            .font(AppTextStyle.bodyMedium16.font)
                            .foregroundStyle(tempSelection.contains(day) ? Color.gray900 : Color.gray800)
                        Spacer()
                        Image(
                            tempSelection.contains(day)
                            ? "check"
                            : "emptyCircle"
                        )
                        .resizable()
                        .frame(width: 20, height: 20)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if tempSelection.contains(day) {
                            tempSelection.remove(day)
                        } else {
                            tempSelection.insert(day)
                        }
                    }
                    .padding(.horizontal, 12)
                    .listRowSeparator(.hidden, edges: .all)
                }
            }
            .padding(.top, 15)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.white)
        .onAppear { tempSelection = selected }
    }
}



// Preview
#Preview {
    NavigationView{
        NotificationSettingView()
    }
}
