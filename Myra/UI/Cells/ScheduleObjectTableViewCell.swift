//
//  ScheduleObjectTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleObjectTableViewCell: UITableViewCell {

    var scheduleObject: ScheduleObject?
    var rup: RUP?
    var scheduleViewReference: ScheduleViewController?

    @IBOutlet weak var pasture: UITextField!
    @IBOutlet weak var liveStock: UITextField!
    @IBOutlet weak var numberOfAniamls: UITextField!
    @IBOutlet weak var dateIn: UITextField!
    @IBOutlet weak var dateOut: UITextField!
    @IBOutlet weak var days: UITextField!
    @IBOutlet weak var graceDays: UITextField!
    @IBOutlet weak var crownAUM: UITextField!
    @IBOutlet weak var pldAUM: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableTextFields()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func lookupPastures(_ sender: Any) {
        let parent = self.parentViewController as! ScheduleViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: RUPManager.shared.getPasturesLookup(rup: rup!)) { (selected, obj) in
            if selected {
                // set This object's pasture object.
                // this function also update calculations for pld and crown fields
                RUPManager.shared.setPastureOn(scheduleObject: self.scheduleObject!, pastureName: (obj?.value)!, rup: self.rup!)
                // fill appropriate fields
                self.fillCurrentValues()
                parent.hidepopup(vc: lookup)
            } else {
                parent.hidepopup(vc: lookup)
            }
        }
        parent.showpopup(vc: lookup)
    }

    @IBAction func lookupLiveStockType(_ sender: Any) {
        let parent = self.parentViewController as! ScheduleViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let objects = RealmManager.shared.getLiveStockTypeLookup()
        lookup.setup(objects: objects) { (selected, obj) in
            if selected {
                if RUPManager.shared.setLiveStockTypeFor(scheduleObject: self.scheduleObject!, liveStock: (obj?.display)!) {
                    RealmRequests.updateObject(self.scheduleObject!)
                    self.update()
                    parent.hidepopup(vc: lookup)
                } else {
                    // todo: Handle error: Livestock not found.
                    // if this happens, something must be broken with the
                    // way names of livestock types are stored and retrieved
                    parent.hidepopup(vc: lookup)
                }
            } else {
                parent.hidepopup(vc: lookup)
                self.update()
            }
        }
        parent.showpopup(vc: lookup)
    }

    @IBAction func numberOfAnimalsChanged(_ sender: UITextField) {
        let curr = numberOfAniamls.text
        if (curr?.isInt)! {
            numberOfAniamls.textColor = UIColor.black
            do {
                let realm = try Realm()
                try realm.write {
                    self.scheduleObject?.numberOfAnimals = Int(curr!)!
                }
            } catch _ {
                fatalError()
            }
        } else {
            numberOfAniamls.textColor = UIColor.red
            do {
                let realm = try Realm()
                try realm.write {
                    self.scheduleObject?.numberOfAnimals = 0
                }
            } catch _ {
                fatalError()
            }
        }
        update()
    }

    @IBAction func dateInAction(_ sender: Any) {
        dismissKeyboard()
        let parent = self.parentViewController as! ScheduleViewController

        DatePickerController.present(on: parent, completion: { (date) in
            guard let date = date else { return }
            self.dateIn.text = date.string()
            do {
                let realm = try Realm()
                try realm.write {
                    self.scheduleObject?.dateIn = date
                }
            } catch _ {
                fatalError()
            }
            self.calculateDays()
            if self.dateOut.text != "" {
                let endDate = DateManager.from(string: self.dateOut.text!)
                if endDate < date {
                    self.dateOut.text = DateManager.toString(date: (self.scheduleObject?.dateIn)!)
                    do {
                        let realm = try Realm()
                        try realm.write {
                            self.scheduleObject?.dateOut = self.scheduleObject?.dateIn
                        }
                    } catch _ {
                        fatalError()
                    }
                    self.calculateDays()
                }
            }
        })
    }

    @IBAction func dateOutAction(_ sender: Any) {
        dismissKeyboard()
        let parent = self.parentViewController as! ScheduleViewController
        if dateIn.text != "" {
            let startDate = DateManager.from(string: dateIn.text!)
            DatePickerController.present(on: parent, minimum: startDate, completion: { (date) in
                guard let date = date else { return }
                self.dateOut.text = date.string()
                do {
                    let realm = try Realm()
                    try realm.write {
                        self.scheduleObject?.dateOut = date
                    }
                } catch _ {
                    fatalError()
                }
                self.calculateDays()
            })
        } else {
            DatePickerController.present(on: parent, completion: { (date) in
                guard let date = date else { return }
                self.dateOut.text = date.string()
                do {
                    let realm = try Realm()
                    try realm.write {
                        self.scheduleObject?.dateOut = date
                    }
                } catch _ {
                    fatalError()
                }
                self.calculateDays()
            })
        }
    }

    func setup(scheduleObject: ScheduleObject, rup: RUP, scheduleViewReference: ScheduleViewController) {
        self.rup = rup
        self.scheduleObject = scheduleObject
        self.scheduleViewReference = scheduleViewReference
        print(scheduleObject)
        autofill()
    }

    public func dismissKeyboard() {
        if scheduleViewReference == nil { return }
        scheduleViewReference?.view.endEditing(true)
    }

    func autofill() {
        if scheduleObject == nil {return}

        // fields that are not filled by user
        fillCurrentValues()

        self.numberOfAniamls.text = "\(scheduleObject?.numberOfAnimals ?? 0)"

        if let inDate = scheduleObject?.dateIn {
            self.dateIn.text = DateManager.toString(date: inDate)
        }

        if let outDate = scheduleObject?.dateOut {
            self.dateOut.text = DateManager.toString(date: outDate)
        }

        calculateDays()
    }

    // update calculations
    func update() {
        if scheduleObject == nil {return}
        RUPManager.shared.calculate(scheduleObject: (scheduleObject)!)
        self.fillCurrentValues()

        // call calculate total on parent
        scheduleViewReference?.calculateTotals()
    }

    func fillCurrentValues() {
        if scheduleObject == nil {return}

        if let ls = scheduleObject?.type {
            self.liveStock.text = ls.name
        }

        if let pasture = scheduleObject?.pasture {
            self.pasture.text = pasture.name
        }

        self.graceDays.text = "\(self.scheduleObject?.graceDays ?? 0)"
        self.pldAUM.text = "\(self.scheduleObject?.pldAUMs.rounded() ?? 0)"
        self.crownAUM.text = "\(self.scheduleObject?.crownAUMs.rounded() ?? 0.0)"
    }

    func calculateDays() {
        if self.dateIn.text == "" || self.dateOut.text == "" {return}
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: DateManager.from(string: self.dateIn.text!))
        let date2 = calendar.startOfDay(for: DateManager.from(string: self.dateOut.text!))
        self.days.text = "\(String(describing: DateManager.daysBetween(date1: date1, date2: date2)))"
        update()
    }

    func disableTextFields() {
        // All fields except for number of animals whould not allow free text entry.
        // labels weren't used because at the time of creation, i had no idea what values
        // the fields should take.
        pasture.isUserInteractionEnabled = false
        liveStock.isUserInteractionEnabled = false
        dateIn.isUserInteractionEnabled = false
        dateOut.isUserInteractionEnabled = false
        days.isUserInteractionEnabled = false
        graceDays.isUserInteractionEnabled = false
        crownAUM.isUserInteractionEnabled = false
        pldAUM.isUserInteractionEnabled = false
    }
}