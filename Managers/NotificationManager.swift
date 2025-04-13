//
//  NotificationManager.swift
//  
//
//  Created by Dylan Geraci on 4/12/25.
//

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    // Request permission on app launch
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    // Send a reminder before lockout (e.g. 5 minutes left)
    func scheduleReminder(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Heads up 🛰️"
        content.body = "You're nearing your screen time limit. Consider taking a break!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "pauseReminder", content: content, trigger: trigger)

        center.add(request)
    }
    
    // Send a notification when time limit is reached
    func scheduleLockoutNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time’s Up 🚀"
        content.body = "You’ve hit your screen time limit. Take a break and reset your orbit."
        content.sound = .default

        let request = UNNotificationRequest(identifier: "pauseLockout", content: content, trigger: nil)
        center.add(request)
    }

    // Clear all scheduled notifications (optional use)
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
