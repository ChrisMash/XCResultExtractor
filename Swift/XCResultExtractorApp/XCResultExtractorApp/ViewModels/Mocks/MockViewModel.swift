//
//  MockViewModel.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 02/07/2025.
//

class MockViewModel: ViewModelInterface {
    
    private(set) var state: ViewModelState = .idle
    
    init(state: ViewModelState) {
        self.state = state
    }
    
    func closeLogs() {
        state = .idle
    }
    
    func revealLogsInFinder() {}
    
}
