//
//  TinySlider.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct TinySlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let accentColor: Color
    
    @State private var isDragging: Bool = false
    
    init(value: Binding<Double>,
         in range: ClosedRange<Double>,
         step: Double = 1,
         accentColor: Color = .accentColor) {
        self._value = value
        self.range = range
        self.step = step
        self.accentColor = accentColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                trackBackground
                trackProgress(width: geometry.size.width)
                knob(size: geometry.size.width)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(dragGesture(in: geometry.size.width))
        }
        .frame(height: 20)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var trackBackground: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(NSColor.separatorColor))
            .frame(height: 4)
    }
    
    @ViewBuilder
    private func trackProgress(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(accentColor)
            .frame(width: knobOffset(in: width), height: 4)
    }
    
    @ViewBuilder
    private func knob(size width: CGFloat) -> some View {
        Circle()
            .fill(Color(NSColor.controlTextColor))
            .overlay(knobBorder)
            .frame(width: knobSize, height: knobSize)
            .offset(x: knobOffset(in: width) - knobSize/2)
            .animation(.easeInOut(duration: 0.1), value: isDragging)
    }
    
    @ViewBuilder
    private var knobBorder: some View {
        Circle()
            .stroke(Color(NSColor.controlAccentColor), lineWidth: 0.5)
    }
    
    private var knobSize: CGFloat {
        isDragging ? 14 : 12
    }
    
    // MARK: Private functions
    
    private func dragGesture(in width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                isDragging = true
                updateValue(from: drag.location.x, totalWidth: width)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    private func updateValue(from x: CGFloat, totalWidth: CGFloat) {
        let ratio = (x / totalWidth).clamped(to: 0...1)
        let raw = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
        let stepped = (raw / step).rounded() * step
        value = stepped.clamped(to: range)
    }
    
    private func knobOffset(in width: CGFloat) -> CGFloat {
        let ratio = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(ratio) * width
    }
}

