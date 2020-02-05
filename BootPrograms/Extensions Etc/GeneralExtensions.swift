//
//  GeneralExtensions.swift
//  Labs Injections ROS
//
//  Created by Fool on 10/5/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Cocoa

protocol StructsWithDescriptionOutput {
    func getOutputFor(_ id:Int) -> String?
}

protocol PopulateComboBoxProtocol {
	func matchValuesFrom(_ id:Int) -> [String]?
}

protocol ProcessTabProtocol {
	var selfView:NSView { get set }
	func processTab() -> String
	func clearTab(_ sender: Any)
	func selectNorms(_ sender: NSButton)
}

func getDescriptionOfItem(_ items:[(Int, String?)], fromStruct theStruct:StructsWithDescriptionOutput) -> [String]? {
    var resultsArray = [String]()
    
    for item in items {
        if var description = theStruct.getOutputFor(item.0) {
            if let itemVerbiage = item.1 {
                description = "\(description)\(itemVerbiage)"
            }
            resultsArray.append(description)
        }
    }
    
    return resultsArray
    
}



extension NSView {
    func clearControllers() {
        func clearChecksTextfields(theView: NSView) {
            for item in theView.subviews {
                if item is NSButton {
                    let checkbox = item as? NSButton
                    if (checkbox?.isEnabled)! {
                    checkbox?.state = .off
                    }
                } else if item is NSTextField {
                    let textfield = item as? NSTextField
                    if (textfield?.isEditable)!{
                    textfield?.stringValue = ""
                    }
                } else if item is NSMatrix {
                    let matrix = item as? NSMatrix
                    matrix?.deselectAllCells()
				} else if item is NSTextView {
					let textView = item as? NSTextView
					if (textView?.isEditable)! {
						textView?.string = ""
					}
                } else {
                    clearChecksTextfields(theView: item)
                }
            }
        }
    clearChecksTextfields(theView: self)
    }
	
	//Populates the choices of the comboboxes and popup buttons in a view based on matching
	//the items tag with a switching function in the selected struct
	func populateSelectionsInViewUsing(_ theStruct: PopulateComboBoxProtocol) {
		for item in self.subviews {
			if let isCombobox = item as? NSComboBox {
				if let selections = theStruct.matchValuesFrom(isCombobox.tag) {
					isCombobox.removeAllItems()
					isCombobox.addItems(withObjectValues: selections)
					isCombobox.selectItem(at: 0)
					isCombobox.completes = true
				}
			} else if let isPopup = item as? NSPopUpButton {
				if let selections = theStruct.matchValuesFrom(isPopup.tag) {
					isPopup.removeAllItems()
					isPopup.addItems(withTitles: selections)
					isPopup.selectItem(at: 0)
				}
			} else {
				item.populateSelectionsInViewUsing(theStruct)
			}
		}
		
	}
	
	func makeButtonsInViewInactive() {
		for item in self.subviews {
			if let isButton = item as? NSButton {
				isButton.state = .off
				isButton.isEnabled = false
			} else {
				item.makeButtonsInViewInactive()
			}
		}
	}
	
	func makeButtonsInViewActive() {
		for item in self.subviews {
			if let isButton = item as? NSButton {
				isButton.isEnabled = true
			} else {
				item.makeButtonsInViewActive()
			}
		}
	}
    
    func turnButtonsInViewOff() {
        for item in self.subviews {
            if let isButton = item as? NSButton {
                isButton.state = .off
            } else {
                item.turnButtonsInViewOff()
            }
        }
    }
	
	func getButtonsInView() -> [NSButton] {
		var results = [NSButton]()
		for item in self.subviews {
			if let button = item as? NSButton {
				results.append(button)
			} else {
				results += item.getButtonsInView()
			}
		}
		return results
	}
    
    func getActiveButtonInView() -> String {
        let activeButtons = self.getActiveButtonsInView()
        if !activeButtons.isEmpty {
            return activeButtons[0]
        }
        return ""
    }
    
    func getActiveButtonsInView() -> [String] {
        let allButtons = self.getButtonsInView()
        let activeButtons = allButtons.filter { $0.state == .on }
        return activeButtons.map { $0.title }
    }
    
    func getNormalButtonsInView() -> [NSButton] {
        var results = [NSButton]()
        for item in self.subviews {
            if let button = item as? NSButton, button.title == "N:"{
                results.append(item as! NSButton)
            } else {
                results += item.getNormalButtonsInView()
            }
        }
        return results
    }

	
	func getComboBoxesInView() -> [NSComboBox] {
		var results = [NSComboBox]()
		for item in self.subviews {
			if let box = item as? NSComboBox {
				results.append(box)
			} else {
				results += item.getComboBoxesInView()
			}
		}
		return results
	}
    
    func getContainingBox() -> NSBox? {
        var theView:NSView?
        
        if self is NSBox {
            return self as? NSBox
        } else {
            theView = self.superview?.getContainingBox()
        }
        return theView as? NSBox
    }
    
    func getListOfButtons() -> [NSButton] {
        var results = [NSButton]()
        for item in self.subviews {
            if let item = item as? NSButton {
                results.append(item)
            } else {
                results += item.getListOfButtons()
            }
        }
        return results
    }
    
    func addButtonsToViewWithNames(_ names:[String], andSelector theSelector:Selector?) {
        
        //        func labelSize(for text: String, fontSize: CGFloat, maxWidth: CGFloat, startingY: CGFloat) -> CGRect{
        //
        //            let font = NSFont.systemFont(ofSize: fontSize)//(name: "HelveticaNeue", size: fontSize)!
        //            let label = NSTextField(frame: CGRect(x: 0, y: startingY, width: maxWidth, height: 18/*CGFloat.leastNonzeroMagnitude*/))
        //            //label.numberOfLines = numberOfLines
        //            label.font = font
        //            label.stringValue = text
        //
        //            label.sizeToFit()
        //            print(label.frame)
        //            return label.frame
        //        }
        //print("Received names: \(names)")
        var buttonY: Int = Int(self.frame.size.height - 20)
        //print(buttonY)
        //print(names)
        for name in names {
            //print(name)
            //let newButton = NSButton(frame: labelSize(for: name, fontSize: 16, maxWidth: 500, startingY: CGFloat(buttonY)))
            var nameSize: Int {
                if name.count > 5 {
                    return name.count * 15
                } else {
                    return name.count * 100
                }
            }
            //print(nameSize)
            let newButton = NSButton(frame: CGRect(x: 0, y: buttonY, width: nameSize, height: 16))
            //let newButton = NSButton(checkboxWithTitle: name, target: self, action: nil)
            newButton.setButtonType(.switch)
            let theUserFont:NSFont = NSFont.systemFont(ofSize: 16)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            let myAttributedTitle = NSAttributedString(string: name, attributes: fontAttributes as? [NSAttributedString.Key : Any])
            newButton.attributedTitle = myAttributedTitle
            newButton.frame.size = newButton.fittingSize
            if let theSelector = theSelector {
                newButton.action = theSelector
            }
        
            self.addSubview(newButton)
            buttonY = buttonY - 20
        }
    }
    
}

extension NSBox {
    func setUpSectionBoxUsingTitle(title: String, font:NSFont, referenceView view:NSView, andButtonList buttons: [String], inView superView: NSView, withHeightAdjustment xAdjust:CGFloat = 62) {
        //guard let max = buttons.max(by: {$1.count > $0.count})?.count else { return }
        self.title = title
        self.titleFont = font
        sizeToFit()
        superView.addSubview(self)
        
        self.setFrameOrigin(NSPoint(x: view.frame.maxX + 5, y: superView.frame.height - self.frame.height - xAdjust))
       
        //self.setFrameSize(NSSize(width: CGFloat((Double(max) * 10.0) + 4), height: self.frame.height))
        
        //Swift.print(self.intrinsicContentSize)
    }
}

extension NSButton {
    
}


extension NSTextView {
	func addToViewsExistingText(_ text:String) {
		if !self.string.isEmpty {
			self.string += "\n\(text)"
		} else {
			self.string = text
		}
	}
}

extension NSComboBox {
    func clearComboBox(menuItems: [String]) {
        self.removeAllItems()
        self.addItems(withObjectValues: menuItems)
        self.selectItem(at: 0)
		self.completes = true
    }
}

extension NSPopUpButton {
    func clearPopUpButton(menuItems: [String]) {
        self.removeAllItems()
        self.addItems(withTitles: menuItems)
        self.selectItem(at: 0)
    }
}

func makeFirstCharacterInStringArrayUppercase(_ theArray: [String])->[String] {
    var changedArray = theArray
    var firstItem = theArray[0]
    //Added this check to avoid an error in cases where the first item in a passed array is an empty string
    if firstItem != "" {
        firstItem.replaceSubrange(firstItem.startIndex...firstItem.startIndex, with: String(firstItem[firstItem.startIndex]).uppercased())
    }
    changedArray[0] = firstItem
    return changedArray
}

func getMatricesIn(view: NSView) -> [NSMatrix] {
    var results = [NSMatrix]()
    
        for item in view.subviews {
            if let isMatrix = item as? NSMatrix {
                results.append(isMatrix)
            } else {
                results += getMatricesIn(view: item)
            }
    }
    //print("getMatricesIn: \(results)")
    return results
}

func getActiveCellsFromMatrix(_ matrix:NSMatrix) -> [Int] {
    var results = [Int]()
    for item in matrix.cells {
            if item.state == .on {
                results.append(item.tag)
        }
    }
    //print("getActiveCellsFromMatrix: \(results)")
    return results
}

func getButtonsInView(_ view:NSView) -> [NSButton] {
	var results = [NSButton]()
	for item in view.subviews {
		if let button = item as? NSButton {
			results.append(button)
		} else {
			results += getButtonsInView(item)
		}
	}
	return results
}

func getTextFieldsInView(_ view:NSView) -> [NSTextField] {
    var results = [NSTextField]()
    for item in view.subviews {
        if let field = item as? NSTextField {
            results.append(field)
        } else {
            results += getTextFieldsInView(item)
        }
    }
    return results
}

func getButtonsIn(view: NSView) -> [(Int, String?)]{
    var results = [(Int, String?)]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton.tag, (isButton as! NSPopUpButton).titleOfSelectedItem))
                    }
                default:
                    results.append((item.tag, nil))
                }
            } else if isButton.state == .mixed {
                results.append((item.tag + 20, nil))
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item.tag, (item as! NSTextField).stringValue))
            }
        } else {
            results += getButtonsIn(view: item)
        }
    }
    return results.sorted(by: {$0.0 < $1.0})
}

func getActiveButtonInfoIn(view: NSView) -> [(Int, String?)]{
    var results = [(Int, String?)]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton.tag, (isButton as! NSPopUpButton).titleOfSelectedItem))
                    }
                default:
                    results.append((isButton.tag, isButton.title))
                }
            } else if isButton.state == .mixed {
                results.append((isButton.tag + 30, isButton.title))
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item.tag, (item as! NSTextField).stringValue))
            }
        } else {
            results += getActiveButtonInfoIn(view: item)
        }
    }
    return results.sorted(by: {$0.0 < $1.0})
}

func getStringsForButtonsIn(view: NSView) -> [String]{
    var results = [String]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton as! NSPopUpButton).titleOfSelectedItem!.lowercased())
                    }
                default:
                    results.append(isButton.title.lowercased())
                }
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item as! NSTextField).stringValue)
            }
        } else {
            results += getStringsForButtonsIn(view: item)
        }
    }
    return results
}

func processAndContinue() {
	let apps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.TextEdit")
	if let mainAPP = apps.first {
		mainAPP.activate(options: .activateIgnoringOtherApps)
	}
}

func turnButtons(_ buttons:[NSButton], InRange range:[Int], ToState state:NSButton.StateValue) {
	for button in buttons {
		if range.contains(button.tag) {
			button.state = state
		}
	}
}

extension Date {
    func addingDays(_ daysToAdd: Int) -> Date? {
        var components = DateComponents()
        components.setValue(daysToAdd, for: .day)
        let newDate = Calendar.current.date(byAdding: components, to: self)
        return newDate
    }
}

func getDateFromString(_ date: [String]) -> [Date]? {
    var results = [Date]()
    
    for item in date {
        if !item.contains("/") {
            return nil
        }
        
        var components = item.components(separatedBy: "/")
        if components.count < 3 {
            components.insert("01", at: 1)
        }
        
        if components[0].count == 1 {
            components[0] = "0" + components[0]
        }
        if components[1].count == 1 {
            components[1] = "0" + components[1]
        }
        if components[2].count == 2 {
            components[2] = "20" + components[2]
        }
        let workingDate = components.joined(separator: "/")
        //print(workingDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let theDate = dateFormatter.date(from: workingDate) else { continue }
        let calendar = Calendar.current
        let calendarComponents = calendar.dateComponents([.year, .month, .day], from: theDate)
        results.append(calendar.date(from: calendarComponents)!)
    }
    
    return results
}

func setFontSizeOf(_ size: CGFloat, forFields textFields: [NSTextView]) {
    let theUserFont:NSFont = NSFont.systemFont(ofSize: size)
    let fontAttributes = NSDictionary(object: theUserFont, forKey: kCTFontAttributeName as! NSCopying)
    //let fontAttributes = NSDictionary(object: theUserFont, forKey: NSFontAttributeName as NSCopying)
    for field in textFields {
        field.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
    }
}

func getPrefDataFrom(_ filePath:String) -> String? {
    var data = String()
    
    do {
        data = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
    } catch {
        let theAlert = NSAlert()
        theAlert.messageText = "Could not import the cleaning text from file at \(filePath)."
        theAlert.alertStyle = NSAlert.Style.warning
        theAlert.addButton(withTitle: "OK")
        theAlert.runModal()
        return nil
    }
    
    return data
}

func getSectionDataStartingFrom(_ start:String, andEndingWith stop:String) -> [String]? {
    var returnData = [String]()
    guard let rawData = getPrefDataFrom("\(NSHomeDirectory())/WPCMSharedFiles/WPCM Software Bits/00 CAUTION - Data Files/LIROSPrefFile.txt") else {return nil}
    if let sectionData = rawData.findRegexMatchBetween(start, and: stop) {
        let cleanData = sectionData.removeWhiteSpace()
        returnData = cleanData.components(separatedBy: "\n")
    }
    return returnData
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

//MARK: Date Extensions
extension Date {
    func shortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        return formatter.string(from: self)
    }
}

//MARK: Decodable Extensions
extension Decodable {
    static func parse(jsonFile: URL) -> Self? {
        //guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
        guard let data = try? Data(contentsOf: jsonFile),
            let output = try? JSONDecoder().decode(self, from: data)
            else {
                return nil
        }
        
        return output
    }
}
extension Encodable {
    static func saveEncodedData<T: Encodable>(_ data: [T], toFilePath path: URL) {
        let json = try? JSONEncoder().encode(data)
        
        do {
            try json!.write(to: path)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
}
