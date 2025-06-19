//
//  ContentView.swift
//  BypassesIOSSecuritySuite
//
//  Created by Farias Igor on 18/06/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var results: [CheckOutput] = []
    @State private var isRunning = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView(.horizontal){
                    HStack(spacing: 12) {
                        Button {
                            runChecksOnce()
                        } label: {
                            Label("One Time", systemImage: "bolt.fill")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            startLoop()
                        } label: {
                            Label("Play", systemImage: "play.fill")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            stopLoop()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            results.removeAll()
                        } label: {
                            Label("Clear", systemImage: "trash.fill")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                
                List(results) { result in
                    HStack {
                        Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.octagon.fill")
                            .foregroundColor(result.passed ? .green : .red)
                        VStack(alignment: .leading) {
                            Text(result.checkName).bold()
                            if !result.passed {
                                Text(result.message)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Verbose Logs")
        }
        .scrollIndicators(.hidden)
        
    }
    
    
    private func runChecksOnce() {
        results = generateCheckResults()
    }
    
    private func startLoop() {
        guard !isRunning else { return }
        isRunning = true
        
        DispatchQueue.global(qos: .background).async {
            while isRunning {
                let newResults = generateCheckResults()
                DispatchQueue.main.async {
                    results = newResults
                }
                sleep(3)
            }
        }
    }
    
    private func stopLoop() {
        isRunning = false
    }
    
    private func generateCheckResults() -> [CheckOutput] {
        var logs: [CheckOutput] = []
        let status = JailbreakChecker.amIJailbrokenWithFailedChecks()
        let allChecks = FailedCheck.allCases
        
        for check in allChecks {
            if let failed = status.failedChecks.first(where: { $0.check == check }) {
                logs.append(CheckOutput(checkName: check.rawValue,
                                        passed: false,
                                        message: failed.failMessage))
            } else {
                logs.append(CheckOutput(checkName: check.rawValue,
                                        passed: true,
                                        message: ""))
            }
        }
        
        return logs
    }
}

extension ContentView {
    struct CheckOutput: Identifiable {
        let id = UUID()
        let checkName: String
        let passed: Bool
        let message: String
    }
}

#Preview {
    ContentView()
}
