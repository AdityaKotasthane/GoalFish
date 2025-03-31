// Sound.swift
import Foundation

enum Sound: String, CaseIterable {
    // Fish and Water Related
    case waterSplash = "watersplash"
    case bubbles = "bubbles"
    case waterDrop = "waterDrop"
    
    // UI Interactions
    case buttonTap = "ripple"
    case menuOpen = "menu_open"
    case timerTick = "timer_tick"
    
    // Status Sounds
    case success = "success"
    case failure = "failure"
    case achievement = "achievement"
    
    // Timer Related
    case timerStart = "timer_start"
    case timerComplete = "timer_complete"
    case timerWarning = "timer_warning"
}
