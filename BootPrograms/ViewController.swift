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

class ViewController: NSViewController {
    
    @IBOutlet weak var timerLabel: NSTextField!
    var seconds = 30
    var timer = Timer()
    var timerIsRunning = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runTimer()
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
        let applications = ["Alfred 3", "Bartender 3", "BetterTouchTool", "Mail", "Dropzone 3", "iStat Menus", "Karabiner-Elements", "OmniFocus", "Resilio Sync", "TextExpander", "XMenu", "Yoink"]
        for app in applications {
            NSWorkspace.shared.openFile("/Applications/\(app).app")
        }
       
    }
    
    @IBAction func pauseTimer(_ sender: NSButton) {
        if sender.state == .off {
            timer.invalidate()
        } else if sender.state == .on {
            runTimer()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


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
