//
//  PerformanceView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI
import Foundation

class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var gpuUsage: Double = 0
    @Published var storageUsage: Double = 0
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        updateMetrics()
    }
    
    private func updateMetrics() {
        // CPU Usage
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let total = Double(cpuInfo.cpu_ticks.0 + cpuInfo.cpu_ticks.1 + cpuInfo.cpu_ticks.2 + cpuInfo.cpu_ticks.3)
            let idle = Double(cpuInfo.cpu_ticks.3)
            self.cpuUsage = (1.0 - idle / total) * 100
        }
        
        // Memory Usage
        var stats = vm_statistics64()
        count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let hostPort = mach_host_self()
        let vmResult = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }
        if vmResult == KERN_SUCCESS {
            let used = Double(stats.active_count + stats.wire_count + stats.inactive_count)
            let total = used + Double(stats.free_count)
            self.memoryUsage = (used / total) * 100
        }
        
        // Storage Usage
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let size = attrs[.systemSize] as? Int64,
               let free = attrs[.systemFreeSize] as? Int64 {
                let used = Double(size - free)
                self.storageUsage = (used / Double(size)) * 100
            }
        }
        
        // GPU Usage (simplified approximation)
        self.gpuUsage = Double.random(in: 20...40) // Simplified for demo
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct PerformanceView: View {
    let appDelegate: AppDelegate?
    @StateObject private var monitor = SystemMonitor()
    
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showMemory") private var showMemory = true
    @AppStorage("showGPU") private var showGPU = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("usePercentageColors") private var usePercentageColors = true
    @AppStorage("useBetterPercentages") private var useBetterPercentages = true
    
    private func getColor(for percentage: Double) -> Color {
        guard usePercentageColors else { return .blue }
        
        switch percentage {
        case 0..<50:
            return .green
        case 50..<75:
            return .yellow
        default:
            return .red
        }
    }
    
    var body: some View {
        HStack {
            HStack {
            if showCPU {
                CircularProgressView(
                    percentage: useBetterPercentages ? monitor.cpuUsage : min(monitor.cpuUsage * 1.5, 100),
                    label: "CPU",
                    color: getColor(for: monitor.cpuUsage)
                )
                .frame(width: 44, height: 44)
            }
            if showMemory {
                CircularProgressView(
                    percentage: useBetterPercentages ? monitor.memoryUsage : min(monitor.memoryUsage * 1.2, 100),
                    label: "MEMORY",
                    color: getColor(for: monitor.memoryUsage)
                )
            }
            if showGPU {
                CircularProgressView(
                    percentage: useBetterPercentages ? monitor.gpuUsage : min(monitor.gpuUsage * 1.3, 100),
                    label: "GPU",
                    color: getColor(for: monitor.gpuUsage)
                )
            }
            if showStorage {
                CircularProgressView(
                    percentage: monitor.storageUsage,
                    label: "STORAGE",
                    color: getColor(for: monitor.storageUsage)
                )
            }
        }
            .frame(maxWidth: .infinity)
            .padding(5)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .padding(.horizontal, 22)
        .padding(.bottom, 10)
    }
}

#Preview {
    NotchView()
        .environmentObject(AppDelegate())
}
