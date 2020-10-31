//
//  ViewController.swift
//  MLAdjectives
//
//  Created by troquer on 10/26/20.
//

import Cocoa

struct WordRow {
    var adjective: String
    var count: Int = 1
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var tableView: NSTableView!
    var arRows: [WordRow] = [WordRow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arRows.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let text: String
        let cellIdentifier: String
        if tableColumn == tableView.tableColumns[0] {
            text = arRows[row].adjective
            cellIdentifier = "AdjectiveCell"
        } else {
            text = String(arRows[row].count)
            cellIdentifier = "CountCell"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
        
    }
    
    @IBAction func analyzeClicked(_ sender: NSButton) {
        let text = textView.string
        let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
            
            if let tag = tag, tag == .adjective {
                let word = (text as NSString).substring(with: tokenRange)
                let foundWordIndex = arRows.firstIndex { $0.adjective == word}
                if let foundWordIndex = foundWordIndex {
                    arRows[foundWordIndex].count += 1
                } else {
                    let newWordRow = WordRow(adjective: word)
                    arRows.append(newWordRow)
                }
            }
        }
        arRows.sort(by: { $0.count > $1.count })
        tableView.reloadData()
    }
}
