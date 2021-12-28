//
//  ContentView.swift
//  LanHu+
//
//  Created by 张行 on 2021/12/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WebViewViewModel()
    var body: some View {
        VStack {
            WebContentView(webViewStore: viewModel.store)
            Button("Tap") {
                Task {
                    do {
                        try await viewModel.parseLanhuContainer()
                    } catch(let e) {
                        print(e.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
