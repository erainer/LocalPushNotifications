//
//  ViewController.swift
//  HuliPizzaNotification
//
//  Created by Emily Rainer on 2/09/19.
//  Copyright © 2019 Emily Rainer. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    //
    // - MARK: Variables
    //
    var isGrantednotificationAccess: Bool = false
    var pizzaNumber: Int = 0
    let pizzaSteps = ["Make Pizza", "Roll Dough", "Add Sauce", "Add Cheese", "Add Ingredients", "Bake", "Done"]
    
    
    func updatePizzaSteps(request: UNNotificationRequest) {
        if request.identifier.hasPrefix("message.pizza") {
            var stepNumber = request.content.userInfo["step"] as! Int
            stepNumber = (stepNumber + 1) % pizzaSteps.count
            let updatedContent = makePizzaContent()
            updatedContent.body = pizzaSteps[stepNumber]
            updatedContent.userInfo["step"] = stepNumber
            updatedContent.subtitle = request.content.subtitle
            addnotification(trigger: request.trigger, content: updatedContent, identifier: request.identifier)
            
        }
    }
    func makePizzaContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "A Timed Pizza Step"
        content.body = "Making Pizza"
        content.userInfo = ["step":0]
        return content
    }
    
    func addnotification(trigger: UNNotificationTrigger?, content: UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Error adding notification: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func schedulePizza(_ sender: UIButton) {
        if isGrantednotificationAccess {
            let content = UNMutableNotificationContent()
            content.title = "A Scheduled Pizza"
            content.body = "Time to make a pizza"
            
            let unitFlags: Set<Calendar.Component> = [.minute, .hour, .second]
            var date = Calendar.current.dateComponents(unitFlags, from: Date())
            guard let seconds = date.second else { return }
            date.second = seconds + 15
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            
            addnotification(trigger: trigger, content: content, identifier: "message.schedule")
        }
    }
    @IBAction func makePizza(_ sender: UIButton) {
        if isGrantednotificationAccess {
            let content = makePizzaContent()
            pizzaNumber += 1
            content.subtitle = "Pizza \(pizzaNumber)"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0, repeats: true)
            addnotification(trigger: trigger, content: content, identifier: "message.pizza.\(pizzaNumber)")
            
        }
    }
    
    @IBAction func nextPizzaStep(_ sender: UIButton) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            if let request = requests.first {
                if request.identifier.hasPrefix("message.pizza") {
                    self.updatePizzaSteps(request: request)
                } else {
                    let content = request.content.mutableCopy() as! UNMutableNotificationContent
                    self.addnotification(trigger: request.trigger!, content: content, identifier: request.identifier)
                }
            }
        }
    }
    
    @IBAction func viewPendingPizzas(_ sender: UIButton) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requestList) in
            print("\(Date()) --> \(requestList.count) requests pending")
            for request in requestList {
                print("\(request.identifier) body: \(request.content.body)")
            }
        }
    }
    
    @IBAction func viewDeliveredPizzas(_ sender: UIButton) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            print("\(Date()) ---- \(notifications.count) delivered")
            for notification in notifications {
                print("\(notification.request.identifier)  \(notification.request.content.body)")
            }
        }
    }
    
    @IBAction func removeNotification(_ sender: UIButton) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
            if let request = request.first {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge, .sound]) { (granted, error) in
            self.isGrantednotificationAccess = granted
            if !granted {
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    // - MARK: Delegates
    //
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}

