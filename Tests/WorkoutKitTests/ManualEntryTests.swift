import Testing
import Foundation
@testable import WorkoutKit

@Suite("ManualEntryStore")
@MainActor
struct ManualEntryTests {
    @Test("初期状態で SetEntry が1件")
    func initialState() {
        let store = ManualEntryStore()
        #expect(store.setEntries.count == 1)
    }

    @Test("addSetEntry で件数が増える")
    func addSetEntry() {
        let store = ManualEntryStore()
        store.addSetEntry()
        #expect(store.setEntries.count == 2)
    }

    @Test("全エントリが空なら isValid = false")
    func invalidWhenAllEmpty() {
        let store = ManualEntryStore()
        #expect(!store.isValid)
    }

    @Test("1件でも名前があれば isValid = true")
    func validWhenOneHasName() {
        let store = ManualEntryStore()
        store.setEntries[0].exerciseName = "スクワット"
        #expect(store.isValid)
    }
}
