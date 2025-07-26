

//import Foundation
//import SwiftData
//import Combine
//
//final class ScrapViewModel: ObservableObject {
//    @Published private(set) var scrappedItemList: [ScrappedItem] = []
//
//    init(modelContext: ModelContext) {
//        let descriptor = FetchDescriptor<ScrappedItem>()
//        if let result = try? modelContext.fetch(descriptor) {
//            self.scrappedItemList = result
//        }
//
//        // Insert dummy data only if list is empty (for testing)
//        if scrappedItemList.isEmpty {
//            let curationDummyIDs = Array(0..<10)
//            for id in curationDummyIDs {
//                let dummyItem = ScrappedItem(id: id, type: .curation)
//                modelContext.insert(dummyItem)
//            }
//
//            let weadyboardDummyIDs = (0..<18).map { ($0 % 7) + 1 }
//            for id in weadyboardDummyIDs {
//                let dummyItem = ScrappedItem(id: id, type: .weadyboard)
//                modelContext.insert(dummyItem)
//            }
//
//            if let result = try? modelContext.fetch(descriptor) {
//                self.scrappedItemList = result
//            }
//        }
//    }
//
//    var scrappedCurationIDs: [Int] {
//        scrappedItemList.filter { $0.type == .curation }.map(\.id)
//    }
//
//    var scrappedWeadyboardIDs: [Int] {
//        scrappedItemList.filter { $0.type == .weadyboard }.map(\.id)
//    }
//
//    func toggle(id: Int, type: DeleteContentType, context: ModelContext) {
//        if let existing = scrappedItemList.first(where: { $0.id == id && $0.type == type }) {
//            context.delete(existing)
//        } else {
//            let newItem = ScrappedItem(id: id, type: type)
//            context.insert(newItem)
//        }
//        reload(context: context)
//    }
//
//    func delete(ids: [Int], type: DeleteContentType, context: ModelContext) {
//        for item in scrappedItemList where ids.contains(item.id) && item.type == type {
//            context.delete(item)
//        }
//        reload(context: context)
//    }
//
//    func reload(context: ModelContext) {
//        if let result = try? context.fetch(FetchDescriptor<ScrappedItem>()) {
//            self.scrappedItemList = result
//        }
//    }
//}
