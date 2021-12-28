//
//  WebContentView.swift
//  LanHu+
//
//  Created by 张行 on 2021/12/27.
//

import SwiftUI
import WebView

struct WebContentView: View {
    @ObservedObject var webViewStore: WebViewStore
    var body: some View {
        WebView(webView: webViewStore.webView)
            .onAppear {
                let lanhuURL = "https://lanhuapp.com"
                guard let url = URL(string: lanhuURL) else {
                          return
                }
                let request = URLRequest(url: url)
                webViewStore.webView.load(request)
            }
    }
}

struct WebContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebContentView(webViewStore: WebViewStore())
    }
}
