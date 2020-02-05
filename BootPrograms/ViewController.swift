//
//  ViewController.swift
//  BootPrograms
//
//  Created by Fool on 10/7/19.
//  Copyright © 2019 Fool. All rights reserved.
//
//  DispatchQueue extension cribbed from:
//  https://stackoverflow.com/questions/24056205/how-to-use-background-thread-in-swift
import Cocoa

protocol DropZoneDelegate: class {
    var droppedURL:String { get set }
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, DropZoneDelegate {
    
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var appsTable: NSTableView!
    
    var seconds = 30
    var timer = Timer()
    var timerIsRunning = false
    
    var bootItemArray = [BootItem]()
    var bootStringArray = [String]()
    
    var droppedURL: String {
        get {
            return ""
        }
        set(newURL) {
            bootStringArray.append(newURL)
            print(bootStringArray)
            //reload the table
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get file list from JSON

        appsTable.delegate = self
        appsTable.dataSource = self
        runTimer()
        
        if let dropView = self.view as? DropView {
            dropView.dzDelegate = self
        }
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            DispatchQueue.background(delay: 0.0, background: {
                self.openApps()
            }, completion: {
                NSApplication.shared.terminate(self)
            })
        } else {
            seconds -= 1
            timerLabel.stringValue = "\(seconds)"
        }
    }
    
    func openApps() {
        let applications = ["Bartender 3", "BetterTouchTool", "Mail", "Dropzone 3", "iStat Menus", "Karabiner-Elements", "OmniFocus", "Resilio Sync", "TextExpander", "XMenu", "Yoink", "Setapp/Filepane"]
        for app in applications {
            NSWorkspace.shared.openFile("/Applications/\(app).app")
            //I think this might get the icon, but I need to test it and move it to the table section
            NSWorkspace.shared.icon(forFile: "/Applications/\(app).app")
        }
       
    }
    
    @IBAction func startNow(_ sender: NSButton) {
        seconds = 0
        timerLabel.stringValue = "0"
        updateTimer()
        //openApps()
    }
    
    @IBAction func pauseTimer(_ sender: NSButton) {
        if sender.state == .off {
            timer.invalidate()
        } else if sender.state == .on {
            runTimer()
        }
    }
    
//    func getAppData() {
//        let filePath = "/Applications/Resilio Sync.app"
//        var fileSize : UInt64
//
//        do {
//            //return [FileAttributeKey : Any]
//            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
//            fileSize = attr[FileAttributeKey.size] as! UInt64
//            print("File attributes: \(attr)")
//            //if you convert to NSDictionary, you can get file size old way as well.
//            let dict = attr as NSDictionary
//            fileSize = dict.fileSize()
//            print("File size: \(fileSize)")
//        } catch {
//            print("Error: \(error)")
//        }
//    }
    
    //MARK: Table Handling
    func numberOfRows(in tableView: NSTableView) -> Int {
        print(bootItemArray.count)
        return bootItemArray.count
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let currentBootItem = bootItemArray[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "nameCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
            cellView.textField?.stringValue = currentBootItem.name
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "iconColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "iconCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
            cellView.imageView?.image = currentBootItem.icon
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "delayColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "delayCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
            cellView.textField?.stringValue = String(currentBootItem.delay)
            return cellView
        }
            
            return nil
        }
    
    //When window closes save file array to JSON
        
        
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
