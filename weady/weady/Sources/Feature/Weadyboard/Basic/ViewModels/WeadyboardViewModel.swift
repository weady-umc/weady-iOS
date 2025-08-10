//
//  WeadyboardViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//
import Foundation

@MainActor
final class WeadyboardViewModel: ObservableObject {
    @Published var posts: [BoardPreviewDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchBoards(
        seasonTagId: Int? = nil,
        weatherTagId: Int? = nil,
        temperatureTagId: Int? = nil,
        size: Int = 20
    ) {
        isLoading = true
        errorMessage = nil

        BoardService().fetchBoards(
            seasonTagId: seasonTagId,
            weatherTagId: weatherTagId,
            temperatureTagId: temperatureTagId,
            size: size
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let dto):
                    self.posts = dto.content

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
