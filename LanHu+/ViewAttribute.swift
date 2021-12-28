//
//  ViewAttribute.swift
//  LanHu+
//
//  Created by 张行 on 2021/12/27.
//

import Foundation
import Fuzi

class ViewAttribute: Codable {
    /// 图层值
    var viewName:String?
    /// X坐标
    var x:String?
    /// Y坐标
    var y:String?
    /// 宽度
    var width:String?
    /// 高度
    var height:String?
    /// 透明度
    var noTransparency:String?
    /// 字体名称
    var fontName:String?
    /// 字重
    var fontWeight:String?
    /// 字号
    var fontSize:String?
    /// 文本内容
    var text:String?
    /// 边框的粗细
    var boardWidth:String?
    /// 圆角大小
    var filletSize:String?
    /// 颜色
    var color:ViewAttribute.Color?
    /// 字间距
    var wordSpacing:String?
    /// 行高
    var lineHeight:String?
    /// 段落
    var paragraph:String?
    
    func parse(element: Fuzi.XMLElement) throws {
        print("->>>>\n\(element)\n\n")
        subParse(itemTitle: "图层", element: element) { attribute, element in
            attribute.viewName = element.getFirstChild(classValue: "layer_name layer_name_wrap")?.stringValue
        }
        
        subParse(itemTitle: "位置", element: element) { attribute, element in
            let two = element.getAllSubItem(classValue: "two")
            guard two.count == 2 else { return }
            attribute.x = two[0].stringValue
            attribute.y = two[1].stringValue
        }
        
        subParse(itemTitle: "大小", element: element) { attribute, element in
            let two = element.getAllSubItem(classValue: "two")
            guard two.count == 2 else { return }
            attribute.width = two[0].stringValue
            attribute.height = two[1].stringValue
        }
        subParse(itemTitle: "不透明度", element: element) { attribute, element in
            attribute.noTransparency = element.getFirstChild(classValue: "item_one")?.stringValue
                .replacingOccurrences(of: "\n              ", with: "")
                .replacingOccurrences(of: "%\n            ", with: "")
        }
        
        subParse(itemTitle: "字体", element: element) { attribute, element in
            attribute.fontName = element.getFirstChild(classValue: "layer_name")?.stringValue
        }
        
        subParse(itemTitle: "字重", element: element) { attribute, element in
            attribute.fontWeight = element.getFirstChild(classValue: "item_one")?.stringValue
        }
        
        subParse(itemTitle: "字号", element: element) { attribute, element in
            attribute.fontSize = element.getAllSubItem(classValue: "two").first?.stringValue
        }
        
        subParse(itemTitle: "内容", element: element) { attribute, element in
            attribute.text = element.getFirstChild(classValue: "item_one item_content")?.stringValue
        }
        
        subParse(itemTitle: "粗细", element: element) { attribute, element in
            attribute.boardWidth = element.getAllSubItem(classValue: "two").first?.stringValue
        }
        subParse(itemTitle: "圆角", element: element) { attribute, element in
            attribute.filletSize = element.getAllSubItem(classValue: "item_two copy_text 321").first?.stringValue
        }
        
        subParse(itemTitle: "空间", element: element) { attribute, element in
            let itemTwos = element.getAllSubItem(classValue: "item_two")
            itemTwos.forEach { element in
                guard  let name = element.children(tag: "span").first?.stringValue else { return }
                guard let value = element.children(tag: "div").first?.stringValue
                        .replacingOccurrences(of: "\n                      ", with: "")
                        .replacingOccurrences(of: "\n                    ", with: "") else { return }
                if name == "字间距" {
                    self.wordSpacing = value
                } else if name == "行高" {
                    self.lineHeight = value
                } else if name == "段落" {
                    self.paragraph = value
                }
            }
        }
        
        parseColor(element: element)
    }
    
    private func subParse(itemTitle:String, element:Fuzi.XMLElement, handle:(_ attribute:ViewAttribute, _ element:Fuzi.XMLElement) -> Void) {
        guard let title = element.getFirstChild(classValue: "item_title")?.stringValue else {return}
        guard itemTitle == title else {return}
        handle(self,element)
    }
    
    private func parseColor(element:Fuzi.XMLElement) {
        guard element.getAllSubItem(classValue: "color-item").count > 0 else { return }
        guard let currentValue = element.getAllSubItem(classValue: "color-item active").first?.stringValue.replacingOccurrences(of: "\n          ", with: "") else {
            return
        }
        guard let currentColorValue = Color.ColorValue.value(value: currentValue) else {
            return
        }
        var colorValues:[Color.ColorValue] = []
        let colorItems = element.getAllSubItem(classValue: "color-item")
        colorItems.forEach { element in
            let value = element.stringValue.replacingOccurrences(of: "\n          ", with: "")
            guard let colorValue = Color.ColorValue.value(value: value) else { return }
            colorValues.append(colorValue)
        }
        self.color = ViewAttribute.Color(current: currentColorValue, values: colorValues)
    }
}


extension ViewAttribute {
    struct Color: Codable {
        enum ColorValue: Codable {
            case hex(hex:String)
            case ahex(ahex:String)
            case hexa(hexa:String)
            case rgba(r:String, g:String, b:String, a:String)
            case hsla(h:String, s:String, l:String, a:String)
            
            static func value(value:String) -> ColorValue? {
                if value.contains("HEX"), value.count == 10 {
                    let start = value.index(value.startIndex, offsetBy: 4)
                    let end  = value.index(start, offsetBy: 6)
                    return .hex(hex: String(value[start ..< end]))
                } else if value.contains("AHEX"), value.count == 13 {
                    let start = value.index(value.startIndex, offsetBy: 5)
                    let end  = value.index(start, offsetBy: 8)
                    return .ahex(ahex: String(value[start ..< end]))
                } else if value.contains("HEXA"), value.count == 13 {
                    let start = value.index(value.startIndex, offsetBy: 5)
                    let end  = value.index(start, offsetBy: 8)
                    return .hexa(hexa: String(value[start ..< end]))
                } else if value.contains("RGBA"), value.count == 17 {
                    let start = value.index(value.startIndex, offsetBy: 4)
                    let end  = value.index(start, offsetBy: 13)
                    let content = String(value[start ..< end])
                    let contents = content.components(separatedBy: ", ")
                    guard contents.count == 4 else { return nil}
                    return .rgba(r: contents[0],
                                 g: contents[1],
                                 b: contents[2],
                                 a: contents[3])
                } else if value.contains("HSLA"), value.count == 17 {
                    let start = value.index(value.startIndex, offsetBy: 4)
                    let end  = value.index(start, offsetBy: 13)
                    let content = String(value[start ..< end])
                    let contents = content.components(separatedBy: ", ")
                    guard contents.count == 4 else { return nil}
                    return .hsla(h: contents[0],
                                 s: contents[1].replacingOccurrences(of: "%", with: ""),
                                 l: contents[2].replacingOccurrences(of: "%", with: ""),
                                 a: contents[3])
                } else {
                    return nil
                }
            }
        }
        let current:ColorValue
        let values:[ColorValue]
        
    }
}
