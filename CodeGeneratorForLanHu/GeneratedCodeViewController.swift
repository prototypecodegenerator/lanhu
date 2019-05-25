//
//  GeneratedCodeViewController.swift
//  CodeGeneratorForLanHu
//
//  Created by zhang hang on 2019/5/26.
//  Copyright © 2019 zhang hang. All rights reserved.
//

import Cocoa

class GeneratedCodeViewController: NSViewController,NSTextFieldDelegate, NSTextViewDelegate {
    var context:[String:Any] = [:]
    @IBOutlet weak var prefixTextField: NSTextField! {
        didSet {
            self.prefixTextField.delegate = self
        }
    }
    @IBOutlet var templateCodeTextView: NSTextView! {
        didSet {
            self.templateCodeTextView.delegate = self
            
        }
    }
    @IBOutlet var generatedCodeTextView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prefixTextField.isEnabled = self.context.keys.count > 0
        self.templateCodeTextView.isEditable = self.context.keys.count > 0
        self.generatedCodeTextView.isEditable = self.context.keys.count > 0
        self.templateCodeTextView.string = UserDefaults.standard.object(forKey: self.templateCodeKey()) as? String ?? ""
        self.generatedCode()
    }
    
    func generatedCode() {
        guard let template = try? Template(string: self.templateCodeTextView.string), var rendering = try? template.render(self.context) else {
            return
        }
        rendering = rendering.replacingOccurrences(of: "        \n", with: "")
        self.generatedCodeTextView.string = rendering
    }
    
    func templateCodeKey() -> String {
        guard let type = self.context["type"] as? Int else {
            return "templateCodeTextView-0"
        }
        return "templateCodeTextView-\(type)"
    }
    
    //MARK: NSTextFieldDelegate
    func controlTextDidChange(_ obj: Notification) {
        self.context["prefix"] = self.prefixTextField.stringValue
        self.generatedCode()
    }
    
    
    //MARK: NSTextViewDelegate
    func textDidChange(_ notification: Notification) {
        UserDefaults.standard.set(self.generatedCodeTextView.string, forKey: self.templateCodeKey())
        UserDefaults.standard.synchronize()
        self.generatedCode()
    }
    
}
