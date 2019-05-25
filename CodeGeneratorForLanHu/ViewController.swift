//
//  ViewController.swift
//  CodeGeneratorForLanHu
//
//  Created by zhang hang on 2019/5/25.
//  Copyright © 2019 zhang hang. All rights reserved.
//

import Cocoa
import WebKit
import SwiftSoup

class Item : Codable {
    
    enum ItemType :Int, Codable {
        case label = 0
        case button
        case view
        case imageView
    }
    var type:ItemType = .view
    var textColor:String?
    var font:String?
    var text:String?
    var fontBlod:String?
    var boardWidth:String?
    var boardColor:String?
    var backgroundColor:String?
    var cornerRadio:String?
}

class ViewController: NSViewController {
    var needParse = 0
    var item:Item = Item()
    var needParseTitle:[String] = []
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var popButton: NSPopUpButton! {
        didSet {
            self.popButton.removeAllItems()
        }
    }
    @IBOutlet weak var tipLabel: NSTextField!
    @IBOutlet weak var generatedCodeButton: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: "http://lanhuapp.com") else {
            return
        }
        self.webView.load(URLRequest(url: url))
    }

    override var representedObject: Any? {
        didSet {
        
        }
    }

    @IBAction func analysisStructureAction(sender:AnyObject) {
        if self.popButton.itemTitles.count == 0 || self.popButton.indexOfSelectedItem == 0 {
            self.item = Item()
        } else {
            self.item.type = .button
        }
        self.webView.evaluateJavaScript("document.getElementsByClassName('annotation_container lanhu_scrollbar flag-pl')[0].innerHTML") { (value, error) in
            guard let htmlContent = value as? String else {
                return
            }
            guard let document = try? SwiftSoup.parse(htmlContent), let elenments = try? document.getElementsByClass("annotation_item").array() else {
                return
            }
            if let slice_tab_box = try? document.getElementsByClass("slice_tab_box").array(), slice_tab_box.count > 0 {
                self.item.type = .imageView
                self.completionParse()
            } else {
                for elenment in elenments {
                    if self.containText(elenment: elenment, contain: "字体") {
                        print("文本区域")
                        self.item.font = self.parseAnnotationItem(elenment: elenment, itemTitle: "字号")
                        self.item.fontBlod = self.parseAnnotationItem(elenment: elenment, itemTitle: "字重")
                        self.item.text = self.parseAnnotationItem(elenment: elenment, itemTitle: "内容")
                        self.item.textColor = self.getColor(elenment: elenment)
                        self.item.type = .label
                        
                    } else if self.containText(elenment: elenment, contain: "中心边框") {
                        print("边框区域")
                        self.item.boardWidth = self.parseAnnotationItem(elenment: elenment, itemTitle: "粗细")
                        self.item.boardColor = self.getColor(elenment: elenment)
                    } else if self.containText(elenment: elenment, contain: "颜色") {
                        print("试图的颜色")
                        self.item.backgroundColor = self.getColor(elenment: elenment)
                    } else if self.containText(elenment: elenment, contain: "圆角") {
                        print("试图的圆角大小")
                        self.item.cornerRadio = self.parseAnnotationItem(elenment: elenment, itemTitle: "圆角")
                    }
                }
                self.completionParse()
            }
        }
    }
    
    func containText(elenment:Element, contain:String) -> Bool {
        guard let text = try? elenment.text() else {
            return false
        }
        return text.range(of: contain) != nil
    }
    
    func getColor(elenment:Element) -> String? {
        guard let colorItemActives = try? elenment.getElementsByClass("color-item active").array(), colorItemActives.count == 1, let tags = try? colorItemActives[0].getElementsByTag("p").array(), tags.count == 1, let text = try? tags[0].text() else {
            return nil
        }
        return text.replacingOccurrences(of: "HEX#", with: "")
    }
    
    func parseAnnotationItem(elenment:Element, itemTitle:String) -> String? {
        guard let lis = try? elenment.getElementsByTag("li").array(), lis.count > 0 else {
            return nil
        }
        for li in lis {
            if let value = self.parseLi(elenment: li, itemTitle: itemTitle) {
                return value
            }
        }
        return nil
    }
    
    func parseLi(elenment:Element, itemTitle:String) -> String? {
        guard let itemTitles = try? elenment.getElementsByClass("item_title").array(), itemTitles.count == 1, let _itemTitle = try? itemTitles[0].text() else {
            return nil
        }
        guard _itemTitle == itemTitle else {
            return nil
        }
        guard let divs = try? elenment.getElementsByTag("div").array(), let last = divs.last else {
            return nil
        }
        guard let text = try? last.text() else {
            return nil
        }
        return text.replacingOccurrences(of: "pt", with: "")
    }
    
    func completionParse() {
        self.popButton.removeAllItems()
        if self.item.type == .label {
            self.generatedCodeButton.isEnabled = true
            self.popButton.addItem(withTitle: "UILabel")
        } else if self.item.type == .imageView {
            self.generatedCodeButton.isEnabled = true
            self.popButton.addItem(withTitle: "UIImageView")
        } else if self.item.type == .view {
            self.generatedCodeButton.isEnabled = true
            self.popButton.addItem(withTitle: "UIView")
        } else if self.item.type == .button {
            self.generatedCodeButton.isEnabled = true
        }
        self.popButton.addItem(withTitle: "UIButton")
        self.popButton.selectItem(at: 0)
        
        self.tipLabel.stringValue = "如果是属于UIButton，请切换类型为UIButton继续选择。"
        
    }
    
    @IBAction func popUpButtonUsed(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            self.tipLabel.stringValue = "如果是属于UIButton，请切换类型为UIButton继续选择。"
        } else {
            self.generatedCodeButton.isEnabled = false
            if self.item.type == .imageView || self.item.type == .label {
                self.tipLabel.stringValue = "请继续选择按钮的整个边框完成解析"
            } else {
                self.tipLabel.stringValue = "请继续选择按钮的内部完成解析"
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let source = segue.destinationController as? GeneratedCodeViewController else {
            return
        }
        guard let data = try? JSONEncoder().encode(self.item), var context = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
            return
        }
        var isBold = false
        if let fontBlod = self.item.fontBlod, fontBlod == "Bold" {
            isBold = true
        }
        context["isBold"] = isBold
        if self.item.type == .label {
            context["prefix"] = "title"
        } else if self.item.type == .view {
            context["prefix"] = "content"
        } else if self.item.type == .imageView {
            context["prefix"] = "icon"
        } else if self.item.type == .button {
            context["prefix"] = "action"
        }
        source.context = context
    }
    
}

