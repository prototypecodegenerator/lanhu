//
//  WebViewViewModel.swift
//  LanHu+
//
//  Created by 张行 on 2021/12/27.
//

import Foundation
import WebView
import Fuzi

@MainActor
class WebViewViewModel: ObservableObject {
    let store = WebViewStore()
    
    func parseLanhuContainer() async throws {
        guard let documentText = try await store.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") as? String else {
            return
        }
        /// class = annotation_container lanhu_scrollbar flag-pl
        let document = try HTMLDocument(string: documentText)
        try parseHTML(document: document)
    }

    private func parseHTML(document: HTMLDocument) throws {
        guard let detailContainer = document.firstChild(css: "#detail_container") else {return}
        guard let detailElement = detailContainer.getFirstChild(classValue: "mu-paper mu-drawer info mu-paper-round mu-paper-2 open right")
            .flatMap({$0.getFirstChild(classValue:"annotation_container_b")})
            .flatMap({$0.children.first})
            .flatMap({$0.getFirstChild(classValue:"annotation_container lanhu_scrollbar flag-pl")}) else { return }
        /// 获取到所有的样式
        let allStyleElements = detailElement.getAllSubItem(classValue: "annotation_item")
        let viewAttribute = ViewAttribute()
        for element in allStyleElements {
            /// 获取 <ul>
            guard let ul = element.firstChild(css: "ul") else { continue }
            /// 获取<li>数组
            let lis = ul.children(tag: "li")
            for li in lis {
                /// 获取 item_title
                try viewAttribute.parse(element: li)
            }
        }
        
        if let data = try? JSONEncoder().encode(viewAttribute), let text = String(data: data, encoding: .utf8) {
            print(text)
        }
    }
}

extension Fuzi.XMLElement {
    func getFirstChild(classValue:String) -> Fuzi.XMLElement? {
        return getAllChild(classValue: classValue).first
    }
    
    func getAllChild(classValue:String) -> [Fuzi.XMLElement] {
        var items:[Fuzi.XMLElement] = []
        for element in self.children {
            guard element.isEqueal(classValue: classValue) else { continue }
            items.append(element)
        }
        return items
    }
    
    func isEqueal(classValue:String) -> Bool {
        guard let value = self.attributes["class"] else { return false }
        guard value == classValue else { return false }
        return true
    }
    
    func getAllSubItem(classValue:String) -> [Fuzi.XMLElement] {
        var items:[Fuzi.XMLElement] = []
        for element in self.children {
            if element.isEqueal(classValue: classValue) {
                items.append(element)
            }
            guard !element.children.isEmpty else {continue}
            items.append(contentsOf: element.getAllSubItem(classValue: classValue))
        }
        return items
    }
}
