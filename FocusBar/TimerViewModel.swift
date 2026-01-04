//
//  TimerViewModel.swift
//  FocusBar
//
//  Created by Nicola Tomassini on 05/01/26.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
import ServiceManagement // <--- Gestisce l'avvio automatico

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var progress: Double = 1.0
    
    // Variabile collegata all'interruttore nella UI
    // Legge lo stato attuale dal sistema all'avvio
    @Published var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled {
        didSet {
            updateLaunchAtLogin()
        }
    }
    
    private var timer: Timer?
    private var endTime: Date?
    private let defaultTime: TimeInterval = 25 * 60 // 25 minuti
    
    // Per evitare App Nap
    private var activity: NSObjectProtocol?
    
    init() {
        self.timeRemaining = defaultTime
        requestNotificationPermission()
    }
    
    // MARK: - Launch Logic
    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Errore nel modificare l'avvio automatico: \(error)")
        }
    }
    
    // MARK: - Timer Logic
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        
        // Calcola fine esatta
        endTime = Date().addingTimeInterval(timeRemaining)
        
        // Evita sospensione app
        activity = ProcessInfo.processInfo.beginActivity(options: .userInitiated, reason: "Timer Pomodoro")
        
        // Schedula notifica futura
        scheduleNotification(at: timeRemaining)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateTimer()
            }
        }
    }
    
    private func updateTimer() {
        guard let endTime = endTime else { return }
        
        let now = Date()
        let remaining = endTime.timeIntervalSince(now)
        
        if remaining > 0 {
            self.timeRemaining = remaining
            withAnimation {
                self.progress = remaining / self.defaultTime
            }
        } else {
            stopTimer()
            self.timeRemaining = 0
            self.progress = 0
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        endTime = nil
        
        // Rimuove notifiche pendenti se fermato a mano
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Rilascia attività sistema
        if let activity = activity {
            ProcessInfo.processInfo.endActivity(activity)
            self.activity = nil
        }
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = defaultTime
        withAnimation {
            progress = 1.0
        }
    }
    
    // MARK: - Helpers
    var timeString: String {
        let totalSeconds = Int(ceil(timeRemaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func scheduleNotification(at interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Completato!"
        content.body = "Ottimo lavoro! Prenditi una pausa."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "PomodoroTimer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
