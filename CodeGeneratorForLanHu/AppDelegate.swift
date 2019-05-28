//
//  AppDelegate.swift
//  CodeGeneratorForLanHu
//
//  Created by zhang hang on 2019/5/25.
//  Copyright © 2019 zhang hang. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var thems:[Language] = []
    @IBOutlet weak var pluginMenu: NSMenu!
    
    var windowController:NSWindowController = NSWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.windowController.showWindow(nil)
        self.windowController.window?.makeKeyAndOrderFront(nil)
        
        if let data = UserDefaults.standard.object(forKey: "currentTemplate") as? Data, let template = try? JSONDecoder().decode(Language.Template.self, from: data) {
            currentTemplate = template
        }
        self.reloadPlugin()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    @IBAction func reloadPlugin(_ sender: Any) {
        self.reloadPlugin()
    }
    
    func reloadPlugin() {
        self.thems.removeAll()
        guard let user = ProcessInfo.processInfo.environment["HOME"] else {
            return
        }
        let path = "\(user)/Library/Caches/CodeGenerator/Themes/"
        var isDirectory:ObjCBool = ObjCBool(booleanLiteral: false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return
        }
        guard isDirectory.boolValue else {
            return
        }
        guard let languageItems = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return
        }
        
        for language in languageItems {
            let languagePath = "\(path)/\(language)"
            guard FileManager.default.fileExists(atPath: languagePath, isDirectory: &isDirectory) , isDirectory.boolValue, let themeItems = try? FileManager.default.contentsOfDirectory(atPath: languagePath) else {
                continue
            }
            var templates:[Language.Template] = []
            for theme in themeItems  {
                let themePath = "\(languagePath)/\(theme)"
                let viewMustache = "\(themePath)/view.mustache"
                let labelMustache = "\(themePath)/label.mustache"
                let imageViewMustache = "\(themePath)/imageView.mustache"
                let buttonMustache = "\(themePath)/button.mustache"
                guard FileManager.default.fileExists(atPath: themePath, isDirectory: &isDirectory) , isDirectory.boolValue, FileManager.default.fileExists(atPath: viewMustache), FileManager.default.fileExists(atPath: imageViewMustache), FileManager.default.fileExists(atPath: buttonMustache), FileManager.default.fileExists(atPath: labelMustache) else {
                    continue
                }
                templates.append(Language.Template(name: theme, path: themePath, language: language))
            }
            self.thems.append(Language(name: language, templates: templates))
        }
        var languageMenuItems:[NSMenuItem] = []
        for theme in self.thems {
            let item = NSMenuItem()
            item.title = theme.name
            var subMenuItems:[NSMenuItem] = []
            for template in theme.templates {
                let templateItem = NSMenuItem(title: template.name, action: #selector(self.menuItemClick), keyEquivalent: "")
                if let currentTemplate = currentTemplate, currentTemplate.language == theme.name, currentTemplate.name == template.name {
                    templateItem.image = #imageLiteral(resourceName: "selected")
                    self.loadMustache(template: template)
                }
                subMenuItems.append(templateItem)
            }
            let subMenu = NSMenu(title: theme.name)
            subMenu.items = subMenuItems
            item.submenu = subMenu
            languageMenuItems.append(item)
        }
        self.pluginMenu.items = languageMenuItems
    }
    
    @objc func menuItemClick(sender:NSMenuItem) {
        guard let menu = sender.menu else {
            return
        }
        for language in self.thems {
            if menu.title == language.name {
                for template in language.templates {
                    if template.name == sender.title {
                        currentTemplate = template
                        guard let data = try? JSONEncoder().encode(template) else {
                            return
                        }
                        UserDefaults.standard.set(data, forKey: "currentTemplate")
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
        self.reloadPlugin()
        
    }
    
    func loadMustache(template:Language.Template) {
        let viewMustache = "\(template.path)/view.mustache"
        let labelMustache = "\(template.path)/label.mustache"
        let imageViewMustache = "\(template.path)/imageView.mustache"
        let buttonMustache = "\(template.path)/button.mustache"
        if let string = try? String(contentsOf: URL(fileURLWithPath: viewMustache), encoding: String.Encoding.utf8) {
            mustaches[.view] = string
        }
        if let string = try? String(contentsOf: URL(fileURLWithPath: imageViewMustache), encoding: String.Encoding.utf8) {
            mustaches[.imageView] = string
        }
        if let string = try? String(contentsOf: URL(fileURLWithPath: labelMustache), encoding: String.Encoding.utf8) {
            mustaches[.label] = string
        }
        if let string = try? String(contentsOf: URL(fileURLWithPath: buttonMustache), encoding: String.Encoding.utf8) {
            mustaches[.button] = string
        }
    }
}



struct Language : Codable {
    let name:String
    let templates:[Template]
    struct Template : Codable {
        let name:String
        let path:String
        var language:String
    }
}

