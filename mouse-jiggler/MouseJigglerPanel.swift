//
//  MouseJigglerPanel.swift
//  mouse-jiggler
//
//  Created by Abderrahim on 16/08/2025.
//

import SwiftUI
import AppKit
import LaunchAtLogin

struct MouseJigglerPanel: View {
    @StateObject var viewModel: MouseJigglerViewModel
    @State private var showDeactivateInfo = false
    @State private var showMoveEveryInfo = false
    @State private var showFeedbackEmail = false
    @State private var showSmartDetectionInfo = false
    @State private var showMovementTypeInfo = false
    @State private var showBatteryInfo = false
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(spacing: 12) {
                // Mouse Jiggler header with toggle
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mouse Jiggler")
                                .font(.system(size: 16, weight: .semibold))
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(viewModel.isActive ? Color.green : Color.gray.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                Text(viewModel.isActive ? "Active" : "Inactive")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "command")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Image(systemName: "control")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("K")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Toggle("", isOn: $viewModel.isActive)
                                .toggleStyle(.switch)
                                .scaleEffect(0.85)
                        }
                    }
                    .padding(16)

                    Divider()
                        .opacity(0.5)
                        .padding(.horizontal, 8)

                    // Deactivate at
                    HStack {
                        HStack(spacing: 4) {
                            Text("Deactivate at")
                                .font(.system(size: 13))
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .onHover { hovering in
                                    showDeactivateInfo = hovering
                                }
                                .popover(isPresented: $showDeactivateInfo) {
                                    Text("Automatically deactivate the mouse jiggler at a specific time each day. Perfect for ending work hours.")
                                        .font(.system(size: 12))
                                        .padding(12)
                                        .frame(width: 250)
                                }
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            HourInput(value: $viewModel.deactivateHour)
                            Text(":")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            MinuteInput(value: $viewModel.deactivateMinute)
                            Toggle("", isOn: $viewModel.deactivateEnabled)
                                .toggleStyle(.switch)
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(14)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 10)
                .padding(.top, 10)

                // Move every section
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 4) {
                            Text("Move every")
                                .font(.system(size: 14))
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .onHover { hovering in
                                    showMoveEveryInfo = hovering
                                }
                                .popover(isPresented: $showMoveEveryInfo) {
                                    Text("Sets how often the mouse will automatically move to prevent your computer from going to sleep or showing as idle.")
                                        .font(.system(size: 12))
                                        .padding(12)
                                        .frame(width: 250)
                                }
                        }
                        Spacer()
                        Picker("", selection: $viewModel.moveInterval) {
                            Text("5s").tag(5)
                            Text("10s").tag(10)
                            Text("30s").tag(30)
                            Text("1 min").tag(60)
                            Text("2 min").tag(120)
                            Text("5 min").tag(300)
                            Text("10 min").tag(600)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }

                    Divider()
                        .opacity(0.3)

                    HStack {
                        HStack(spacing: 4) {
                            Text("Smart activity detection")
                                .font(.system(size: 14))
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .onHover { hovering in
                                    showSmartDetectionInfo = hovering
                                }
                                .popover(isPresented: $showSmartDetectionInfo) {
                                    Text("Automatically pause jiggling when you're actively using your computer. Resumes after 2 minutes of inactivity.")
                                        .font(.system(size: 12))
                                        .padding(12)
                                        .frame(width: 250)
                                }
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.smartActivityDetection)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    }

                    Divider()
                        .opacity(0.3)

                    HStack {
                        HStack(spacing: 4) {
                            Text("Movement type")
                                .font(.system(size: 14))
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .onHover { hovering in
                                    showMovementTypeInfo = hovering
                                }
                                .popover(isPresented: $showMovementTypeInfo) {
                                    Text("Choose how the mouse cursor moves: Circular creates smooth circles, Figure-8 draws figure-eight patterns, Random moves unpredictably, and Straight Line moves back and forth.")
                                        .font(.system(size: 12))
                                        .padding(12)
                                        .frame(width: 250)
                                }
                        }
                        Spacer()
                        Picker("", selection: $viewModel.movementType) {
                            Text("Circular").tag("Circular")
                            Text("Figure-8").tag("Figure-8")
                            Text("Random").tag("Random")
                            Text("Straight Line").tag("Straight Line")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 10)

                // Click option section
                HStack {
                    Text("Click option")
                        .font(.system(size: 14))
                    Spacer()
                    Picker("", selection: $viewModel.clickOption) {
                        Text("None").tag("None")
                        Text("Left click").tag("Left")
                        Text("Right click").tag("Right")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 10)

                // Battery deactivation section
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 4) {
                            Text("Deactivate on low battery")
                                .font(.system(size: 14))
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .onHover { hovering in
                                    showBatteryInfo = hovering
                                }
                                .popover(isPresented: $showBatteryInfo) {
                                    Text("Automatically disable mouse jiggling when battery level drops below the selected percentage to preserve battery life.")
                                        .font(.system(size: 12))
                                        .padding(12)
                                        .frame(width: 250)
                                }
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.batteryDeactivationEnabled)
                            .toggleStyle(.switch)
                            .scaleEffect(0.85)
                    }

                    if viewModel.batteryDeactivationEnabled {
                        Divider()
                            .opacity(0.3)

                        HStack {
                            Text("Battery threshold")
                                .font(.system(size: 13))
                            Spacer()
                            Picker("", selection: $viewModel.batteryThreshold) {
                                Text("5%").tag(5)
                                Text("10%").tag(10)
                                Text("15%").tag(15)
                                Text("20%").tag(20)
                                Text("25%").tag(25)
                                Text("30%").tag(30)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 120)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 10)

                // Launch at login section
                HStack {
                    Text("Launch at login")
                        .font(.system(size: 14))
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { value in
                            LaunchAtLogin.isEnabled = value
                        }
                        .toggleStyle(.switch)
                        .scaleEffect(0.85)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 10)

                // Quit button
                Button(action: { NSApp.terminate(nil) }) {
                    Text("Quit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.9))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)

                // Donation links
                HStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://buymeacoffee.com/abderrahimghazali") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("☕")
                                .font(.system(size: 11))
                            Text("Coffee")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        if let url = URL(string: "https://www.paypal.com/paypalme/abderrahimghazali") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("🍕")
                                .font(.system(size: 11))
                            Text("Pizza")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)

                // App description and feedback
                VStack(spacing: 8) {
                    Text("Keep your Mac awake by automatically moving the mouse cursor at regular intervals.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: {
                        showFeedbackEmail.toggle()
                    }) {
                        Text("Feedback")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showFeedbackEmail) {
                        HStack(spacing: 8) {
                            Text("ghazali.abderrahim1@gmail.com")
                                .font(.system(size: 12))
                            Button(action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString("ghazali.abderrahim1@gmail.com", forType: .string)
                                showFeedbackEmail = false
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .frame(width: 320)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

struct HourInput: View {
    @Binding var value: Int

    var body: some View {
        HStack(spacing: 0) {
            Text(String(format: "%02d", value))
                .frame(width: 28, height: 26)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
            VStack(spacing: 0) {
                Button(action: {
                    if value < 23 { value += 1 }
                    else if value == 23 { value = 0 }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .frame(height: 0.5)

                Button(action: {
                    if value > 0 { value -= 1 }
                    else if value == 0 { value = 23 }
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 18)
            .background(Color.gray.opacity(0.08))
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

struct MinuteInput: View {
    @Binding var value: Int

    var body: some View {
        HStack(spacing: 0) {
            Text(String(format: "%02d", value))
                .frame(width: 28, height: 26)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
            VStack(spacing: 0) {
                Button(action: {
                    if value <= 50 { value += 5 }
                    else { value = 0 }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .frame(height: 0.5)

                Button(action: {
                    if value >= 5 { value -= 5 }
                    else { value = 55 }
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 18)
            .background(Color.gray.opacity(0.08))
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

class MouseJigglerViewModel: ObservableObject {
    @Published var isActive = false {
        didSet {
            UserDefaults.standard.set(isActive, forKey: "isActive")
        }
    }
    @Published var deactivateEnabled = false {
        didSet {
            UserDefaults.standard.set(deactivateEnabled, forKey: "deactivateEnabled")
        }
    }
    @Published var deactivateHour = 18 {
        didSet {
            UserDefaults.standard.set(deactivateHour, forKey: "deactivateHour")
        }
    }
    @Published var deactivateMinute = 0 {
        didSet {
            UserDefaults.standard.set(deactivateMinute, forKey: "deactivateMinute")
        }
    }
    @Published var moveInterval = 5 {
        didSet {
            UserDefaults.standard.set(moveInterval, forKey: "moveInterval")
        }
    }
    @Published var clickOption = "None" {
        didSet {
            UserDefaults.standard.set(clickOption, forKey: "clickOption")
        }
    }
    @Published var smartActivityDetection = false {
        didSet {
            UserDefaults.standard.set(smartActivityDetection, forKey: "smartActivityDetection")
        }
    }
    @Published var batteryDeactivationEnabled = false {
        didSet {
            UserDefaults.standard.set(batteryDeactivationEnabled, forKey: "batteryDeactivationEnabled")
        }
    }
    @Published var batteryThreshold = 20 {
        didSet {
            UserDefaults.standard.set(batteryThreshold, forKey: "batteryThreshold")
        }
    }
    @Published var movementType = "Straight Line" {
        didSet {
            UserDefaults.standard.set(movementType, forKey: "movementType")
        }
    }

    init() {
        isActive = UserDefaults.standard.bool(forKey: "isActive")
        deactivateEnabled = UserDefaults.standard.bool(forKey: "deactivateEnabled")
        deactivateHour = UserDefaults.standard.object(forKey: "deactivateHour") as? Int ?? 18
        deactivateMinute = UserDefaults.standard.object(forKey: "deactivateMinute") as? Int ?? 0
        moveInterval = UserDefaults.standard.object(forKey: "moveInterval") as? Int ?? 5
        clickOption = UserDefaults.standard.string(forKey: "clickOption") ?? "None"
        smartActivityDetection = UserDefaults.standard.bool(forKey: "smartActivityDetection")
        batteryDeactivationEnabled = UserDefaults.standard.bool(forKey: "batteryDeactivationEnabled")
        batteryThreshold = UserDefaults.standard.object(forKey: "batteryThreshold") as? Int ?? 20
        movementType = UserDefaults.standard.string(forKey: "movementType") ?? "Straight Line"
    }
}
