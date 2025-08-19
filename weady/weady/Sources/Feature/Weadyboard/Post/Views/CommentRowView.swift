//
//  CommentRowView.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import SwiftUI

/// List에서 한 줄(부모/자식 공통)을 그리는 뷰
struct CommentRowView: View {
    let row: CommentRow
    let now: Date
    var onTapReply: ((Int, String) -> Void)? = nil

    private var leadingIndent: CGFloat { row.level == 0 ? 0 : 44 * .deviceScale }
    /// 대댓글  축소 비율
    private let childScale: CGFloat = 0.92

    var body: some View {
        HStack(alignment: .top, spacing: 10 * .deviceScale) {
            if leadingIndent > 0 { Spacer().frame(width: leadingIndent) }
            
            AsyncImage(url: URL(string: row.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("profileimage")
                    .resizable()
            }
            .frame(width: 35 * .deviceScale, height: 35 * .deviceScale)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: row.level == 0 ? 6 * .deviceScale : 4 * .deviceScale) {
                HStack(spacing: 6 * .deviceScale) {
                    Text(row.username)
                        .fontName(.metaMedium12)
                    
                    Text(row.createdAt.relativeTimeString(now: now))
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray800)
                }
                
                Text(row.content)
                    .fontName(.captionRegular14)
                    .foregroundStyle(.black)
                
                if row.level == 0 {
                    Button {
                        let parentId = row.id
                        onTapReply?(parentId, row.username)
                    } label: {
                        Text("답글 달기")
                            .fontName(.metaRegular10)
                            .foregroundColor(.gray900)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2 * .deviceScale)
                }
            }
        }
        .padding(.vertical, 2 * .deviceScale)
        .scaleEffect(row.level == 1 ? childScale : 1.0, anchor: .leading)
    }
}

/// List에서 사용할 평탄화된 Row 모델
struct CommentRow: Identifiable, Hashable {
    let id: Int
    let level: Int             // 0 = 부모, 1 = 자식
    let isParent: Bool
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let createdAt: String
}

extension Array where Element == CommentResponseDTO {
    /// 부모-자식 댓글 트리를 List 한 줄씩으로 평탄화 (배열 순서를 그대로 사용)
    func flattenedRows() -> [CommentRow] {
        var rows: [CommentRow] = []
        for parent in self {
            rows.append(
                CommentRow(
                    id: parent.commentId,
                    level: 0,
                    isParent: true,
                    parentId: nil,
                    username: parent.username,
                    profileImageUrl: parent.profileImageUrl,
                    content: parent.content,
                    createdAt: parent.createdAt
                )
            )
            for child in parent.childCommentsList {
                rows.append(
                    CommentRow(
                        id: child.commentId,
                        level: 1,
                        isParent: false,
                        parentId: child.parentId ?? parent.commentId,
                        username: child.username,
                        profileImageUrl: child.profileImageUrl,
                        content: child.content,
                        createdAt: child.createdAt
                    )
                )
            }
        }
        return rows
    }
}
