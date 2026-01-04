//
//  TimerView.swift
//  FocusBar
//
//  Created by Nicola Tomassini on 05/01/26.
//

import SwiftUI

struct TimerView: View {
    @StateObject var viewModel = TimerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("FocusBar")
                .font(.headline)
                .opacity(0.8)
            
            ZStack {
                // Sfondo cerchio
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.2)
                    .foregroundColor(.gray)
                
                // Progresso animato
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.progress))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(viewModel.progress > 0.2 ? .blue : .red)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 0.1), value: viewModel.progress)
                
                // Testo Tempo
                Text(viewModel.timeString)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
            .frame(width: 200, height: 200)
            .padding()
            
            // Pulsanti Controllo
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.isRunning ? viewModel.stopTimer() : viewModel.startTimer()
                }) {
                    Text(viewModel.isRunning ? "Pausa" : "Avvia")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: {
                    viewModel.resetTimer()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Divider()
            
            // --- NUOVO: Toggle Avvio al Login ---
            Toggle("Avvia al login", isOn: $viewModel.launchAtLogin)
                .toggleStyle(.switch)
                .font(.caption)
                .padding(.horizontal, 10)
            
            Divider()
            
            // --- NUOVO: Tasto Esci ---
            Button("Esci da FocusBar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.caption)
            .padding(.bottom, 5)
        }
        .padding(30)
        .frame(width: 320, height: 450) // Altezza aggiustata per far entrare i nuovi tasti
    }
}
