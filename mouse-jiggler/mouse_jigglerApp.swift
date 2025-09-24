//
//  mouse_jigglerApp.swift
//  mouse-jiggler
//
//  Created by Abderrahim on 16/08/2025.
//

import SwiftUI
import AppKit
import CoreGraphics
import Combine
import IOKit.ps

@main
struct mouse_jigglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    var deactivationTimer: Timer?
    var viewModel = MouseJigglerViewModel()
    var eventMonitor: Any?
    var keyboardMonitors: [Any] = []
    var activityMonitors: [Any] = []
    var lastActivityTime: Date = Date()
    var activityCheckTimer: Timer?
    var batteryCheckTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Create status item with variable length but ensure proper sizing
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Set button frame and constraints to prevent cropping
            button.frame = NSRect(x: 0, y: 0, width: 32, height: 24)
            button.imagePosition = .imageOnly

            // Try to use system icons with proper configuration
            if #available(macOS 11.0, *) {
                let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
                if let image = NSImage(systemSymbolName: "computermouse", accessibilityDescription: "Mouse Jiggler")?.withSymbolConfiguration(config) {
                    button.image = image
                    button.image?.isTemplate = true
                } else {
                    // Fallback to creating a custom mouse icon
                    button.image = createCustomMouseIcon()
                }
            } else {
                // For older macOS versions
                button.image = createCustomMouseIcon()
            }
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover with SwiftUI content
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 200)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MouseJigglerPanel(viewModel: self.viewModel))
        
        // Monitor clicks outside popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover?.isShown == true {
                self?.closePopover()
            }
        }
        
        // Observe changes in view model
        viewModel.$isActive
            .sink { [weak self] isActive in
                self?.updateStatusIcon(isActive: isActive)
                if isActive {
                    self?.startJiggling()
                } else {
                    self?.stopJiggling()
                }
            }
            .store(in: &cancellables)
        
        // Start jiggling if it was active before
        if viewModel.isActive {
            startJiggling()
        }

        // Set initial icon state
        updateStatusIcon(isActive: viewModel.isActive)

        // Set up global keyboard shortcut for Cmd+Ctrl+K
        setupGlobalKeyboardShortcut()

        // Set up activity monitoring for smart detection
        setupActivityMonitoring()

        // Set up battery monitoring
        setupBatteryMonitoring()
        
        viewModel.$moveInterval
            .dropFirst() // Skip initial value to avoid restarting on app launch
            .sink { [weak self] newInterval in
                print("Move interval changed to: \(newInterval) seconds")
                if self?.viewModel.isActive == true {
                    self?.startJiggling(withInterval: newInterval)
                }
            }
            .store(in: &cancellables)

        viewModel.$deactivateEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.setDeactivationTimer()
                } else {
                    self?.cancelDeactivationTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    func createCustomMouseIcon() -> NSImage {
        return NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            NSColor.labelColor.setFill()
            let path = NSBezierPath(ovalIn: NSRect(x: 2, y: 1, width: 14, height: 16))
            path.fill()
            let divider = NSBezierPath()
            divider.move(to: NSPoint(x: 9, y: 1))
            divider.line(to: NSPoint(x: 9, y: 10))
            divider.lineWidth = 1
            NSColor.controlBackgroundColor.setStroke()
            divider.stroke()
            return true
        }
    }

    func updateStatusIcon(isActive: Bool) {
        guard let button = statusItem?.button else { return }

        if #available(macOS 11.0, *) {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)

            if isActive {
                // Active state - use filled mouse icon
                if let image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "Mouse Jiggler Active")?.withSymbolConfiguration(config) {
                    button.image = image
                    button.image?.isTemplate = true
                    button.alphaValue = 1.0
                } else {
                    button.image = createCustomMouseIcon()
                    button.image?.isTemplate = true
                    button.alphaValue = 1.0
                }
            } else {
                // Inactive state - use outlined mouse icon with reduced opacity
                if let image = NSImage(systemSymbolName: "computermouse", accessibilityDescription: "Mouse Jiggler Inactive")?.withSymbolConfiguration(config) {
                    button.image = image
                    button.image?.isTemplate = true
                    button.alphaValue = 0.5
                } else {
                    button.image = createCustomMouseIcon()
                    button.image?.isTemplate = true
                    button.alphaValue = 0.5
                }
            }
        } else {
            // For older macOS versions
            button.image = createCustomMouseIcon()
            button.image?.isTemplate = true
            button.alphaValue = isActive ? 1.0 : 0.5
        }
    }

    func setupGlobalKeyboardShortcut() {
        let keyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check for Cmd+Ctrl+K
            if event.modifierFlags.contains([.command, .control]) && event.keyCode == 40 { // K key
                self?.toggleMouseJiggler()
            }
        }

        // Also monitor local events when the app has focus
        let localKeyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check for Cmd+Ctrl+K
            if event.modifierFlags.contains([.command, .control]) && event.keyCode == 40 { // K key
                self?.toggleMouseJiggler()
                return nil // Consume the event
            }
            return event
        }

        // Store monitors for cleanup
        if let globalMonitor = keyboardMonitor {
            self.keyboardMonitors.append(globalMonitor)
        }
        if let localMonitor = localKeyboardMonitor {
            self.keyboardMonitors.append(localMonitor)
        }
    }

    @objc func toggleMouseJiggler() {
        viewModel.isActive.toggle()
    }

    func setupActivityMonitoring() {
        // Monitor mouse movement
        let mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown, .scrollWheel]) { [weak self] _ in
            self?.recordActivity()
        }

        // Monitor keyboard activity
        let keyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] _ in
            self?.recordActivity()
        }

        // Store monitors for cleanup
        if let mouseMonitor = mouseMonitor {
            activityMonitors.append(mouseMonitor)
        }
        if let keyboardMonitor = keyboardMonitor {
            activityMonitors.append(keyboardMonitor)
        }

        // Start timer to check for inactivity
        startActivityCheckTimer()
    }

    func recordActivity() {
        lastActivityTime = Date()
    }

    func startActivityCheckTimer() {
        activityCheckTimer?.invalidate()
        activityCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkForInactivity()
        }
    }

    func checkForInactivity() {
        guard viewModel.smartActivityDetection && viewModel.isActive else { return }

        let timeSinceLastActivity = Date().timeIntervalSince(lastActivityTime)
        let inactivityThreshold: TimeInterval = 120 // 2 minutes

        if timeSinceLastActivity < 30 {
            // User is active, stop jiggling temporarily
            if timer != nil {
                print("User active - pausing jiggling")
                stopJiggling()
            }
        } else if timeSinceLastActivity >= inactivityThreshold {
            // User has been inactive for 2+ minutes, resume jiggling
            if timer == nil && viewModel.isActive {
                print("User inactive for 2+ minutes - resuming jiggling")
                startJiggling()
            }
        }
    }

    func setupBatteryMonitoring() {
        // Check battery level every 30 seconds
        batteryCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkBatteryLevel()
        }
    }

    func checkBatteryLevel() {
        guard viewModel.batteryDeactivationEnabled && viewModel.isActive else { return }

        let batteryLevel = getBatteryLevel()

        if batteryLevel <= Double(viewModel.batteryThreshold) {
            print("Battery level (\(Int(batteryLevel))%) is below threshold (\(viewModel.batteryThreshold)%) - deactivating mouse jiggler")
            viewModel.isActive = false
        }
    }

    func getBatteryLevel() -> Double {
        // Get battery information using IOKit
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        for source in sources {
            let sourceInfo = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as! [String: AnyObject]

            if let type = sourceInfo[kIOPSTypeKey] as? String,
               type == kIOPSInternalBatteryType,
               let capacity = sourceInfo[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = sourceInfo[kIOPSMaxCapacityKey] as? Int,
               maxCapacity > 0 {
                return Double(capacity) / Double(maxCapacity) * 100.0
            }
        }

        // Return 100% if no battery found (desktop Mac) or if unable to read
        return 100.0
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                closePopover()
            } else {
                showPopover(button)
            }
        }
    }
    
    func showPopover(_ button: NSStatusBarButton) {
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // Activate the app to bring the popover to focus
        NSApp.activate(ignoringOtherApps: true)

        // Make sure the popover gets focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.popover?.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
        }
    }
    
    func closePopover() {
        popover?.performClose(nil)
    }
    
    func startJiggling(withInterval customInterval: Int? = nil) {
        // Stop any existing timer first
        stopJiggling()

        let interval = TimeInterval(customInterval ?? viewModel.moveInterval)
        print("Starting mouse jiggler with interval: \(interval) seconds")

        // Start jiggling immediately, then at the specified interval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.jiggleMouse()
        }
        timer?.tolerance = 0.5

        // Jiggle immediately
        jiggleMouse()
    }
    
    func stopJiggling() {
        timer?.invalidate()
        timer = nil
    }
    
    func jiggleMouse() {
        guard viewModel.isActive else { return }

        // Get current mouse location
        let currentEvent = CGEvent(source: nil)
        let currentLocation = currentEvent?.location ?? CGPoint.zero

        // Perform movement based on selected type
        switch viewModel.movementType {
        case "Circular":
            performCircularMovement(from: currentLocation)
        case "Figure-8":
            performFigure8Movement(from: currentLocation)
        case "Random":
            performRandomMovement(from: currentLocation)
        default: // "Straight Line"
            performStraightLineMovement(from: currentLocation)
        }

        print("Mouse jiggled (\(viewModel.movementType)) at \(Date())") // Debug log
    }

    func performStraightLineMovement(from currentLocation: CGPoint) {
        let moveDistance: CGFloat = 10
        if let moveEvent = CGEvent(mouseEventSource: nil,
                                   mouseType: .mouseMoved,
                                   mouseCursorPosition: CGPoint(x: currentLocation.x + moveDistance, y: currentLocation.y),
                                   mouseButton: .left) {
            moveEvent.post(tap: .cghidEventTap)

            // Move back after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                if let moveBackEvent = CGEvent(mouseEventSource: nil,
                                              mouseType: .mouseMoved,
                                              mouseCursorPosition: currentLocation,
                                              mouseButton: .left) {
                    moveBackEvent.post(tap: .cghidEventTap)
                }
                self?.performClickIfNeeded(at: currentLocation)
            }
        }
    }

    func performCircularMovement(from currentLocation: CGPoint) {
        let radius: CGFloat = 15
        let steps = 8
        let angleStep = 2 * CGFloat.pi / CGFloat(steps)

        for i in 0..<steps {
            let angle = CGFloat(i) * angleStep
            let x = currentLocation.x + radius * cos(angle)
            let y = currentLocation.y + radius * sin(angle)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) { [weak self] in
                if let moveEvent = CGEvent(mouseEventSource: nil,
                                           mouseType: .mouseMoved,
                                           mouseCursorPosition: CGPoint(x: x, y: y),
                                           mouseButton: .left) {
                    moveEvent.post(tap: .cghidEventTap)
                }

                // Return to center and perform click on last step
                if i == steps - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        if let returnEvent = CGEvent(mouseEventSource: nil,
                                                    mouseType: .mouseMoved,
                                                    mouseCursorPosition: currentLocation,
                                                    mouseButton: .left) {
                            returnEvent.post(tap: .cghidEventTap)
                        }
                        self?.performClickIfNeeded(at: currentLocation)
                    }
                }
            }
        }
    }

    func performFigure8Movement(from currentLocation: CGPoint) {
        let width: CGFloat = 20
        let height: CGFloat = 15
        let steps = 16

        for i in 0..<steps {
            let t = CGFloat(i) / CGFloat(steps) * 2 * CGFloat.pi
            let x = currentLocation.x + width * sin(t)
            let y = currentLocation.y + height * sin(t * 2) / 2

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.04) { [weak self] in
                if let moveEvent = CGEvent(mouseEventSource: nil,
                                           mouseType: .mouseMoved,
                                           mouseCursorPosition: CGPoint(x: x, y: y),
                                           mouseButton: .left) {
                    moveEvent.post(tap: .cghidEventTap)
                }

                // Return to center and perform click on last step
                if i == steps - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        if let returnEvent = CGEvent(mouseEventSource: nil,
                                                    mouseType: .mouseMoved,
                                                    mouseCursorPosition: currentLocation,
                                                    mouseButton: .left) {
                            returnEvent.post(tap: .cghidEventTap)
                        }
                        self?.performClickIfNeeded(at: currentLocation)
                    }
                }
            }
        }
    }

    func performRandomMovement(from currentLocation: CGPoint) {
        let maxDistance: CGFloat = 25
        let steps = 5

        for i in 0..<steps {
            let randomX = currentLocation.x + CGFloat.random(in: -maxDistance...maxDistance)
            let randomY = currentLocation.y + CGFloat.random(in: -maxDistance...maxDistance)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) { [weak self] in
                if let moveEvent = CGEvent(mouseEventSource: nil,
                                           mouseType: .mouseMoved,
                                           mouseCursorPosition: CGPoint(x: randomX, y: randomY),
                                           mouseButton: .left) {
                    moveEvent.post(tap: .cghidEventTap)
                }

                // Return to center and perform click on last step
                if i == steps - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        if let returnEvent = CGEvent(mouseEventSource: nil,
                                                    mouseType: .mouseMoved,
                                                    mouseCursorPosition: currentLocation,
                                                    mouseButton: .left) {
                            returnEvent.post(tap: .cghidEventTap)
                        }
                        self?.performClickIfNeeded(at: currentLocation)
                    }
                }
            }
        }
    }

    func performClickIfNeeded(at location: CGPoint) {
        if viewModel.clickOption != "None" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.performClick(type: self.viewModel.clickOption, at: location)
            }
        }
    }

    func performClick(type: String, at location: CGPoint) {
        let mouseButton: CGMouseButton
        let mouseDownType: CGEventType
        let mouseUpType: CGEventType

        switch type {
        case "Left":
            mouseButton = .left
            mouseDownType = .leftMouseDown
            mouseUpType = .leftMouseUp
        case "Right":
            mouseButton = .right
            mouseDownType = .rightMouseDown
            mouseUpType = .rightMouseUp
        default:
            return
        }

        // Create mouse down event
        if let mouseDownEvent = CGEvent(mouseEventSource: nil,
                                        mouseType: mouseDownType,
                                        mouseCursorPosition: location,
                                        mouseButton: mouseButton) {
            mouseDownEvent.post(tap: .cghidEventTap)

            // Create mouse up event after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if let mouseUpEvent = CGEvent(mouseEventSource: nil,
                                             mouseType: mouseUpType,
                                             mouseCursorPosition: location,
                                             mouseButton: mouseButton) {
                    mouseUpEvent.post(tap: .cghidEventTap)
                }
            }
        }
    }
    
    func setDeactivationTimer() {
        deactivationTimer?.invalidate()
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = viewModel.deactivateHour
        components.minute = viewModel.deactivateMinute
        
        if let targetDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) {
            let timeInterval = targetDate.timeIntervalSinceNow
            deactivationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                self?.viewModel.isActive = false
            }
        }
    }
    
    func cancelDeactivationTimer() {
        deactivationTimer?.invalidate()
        deactivationTimer = nil
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }

        // Clean up keyboard monitors
        for monitor in keyboardMonitors {
            NSEvent.removeMonitor(monitor)
        }
        keyboardMonitors.removeAll()

        // Clean up activity monitors
        for monitor in activityMonitors {
            NSEvent.removeMonitor(monitor)
        }
        activityMonitors.removeAll()

        // Stop activity check timer
        activityCheckTimer?.invalidate()
        activityCheckTimer = nil

        // Stop battery check timer
        batteryCheckTimer?.invalidate()
        batteryCheckTimer = nil
    }
}

