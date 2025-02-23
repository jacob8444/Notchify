import SwiftUI
import Foundation

struct CalculatorView: View {
    let appDelegate: AppDelegate?
    @StateObject private var monitor = SystemMonitor()
    
    // Calculator state
    @State private var currentInput: String = "0"
    @State private var previousNumber: Double? = nil
    @State private var currentOperation: Operation? = nil
    @State private var shouldResetInput = false
    
    // Existing AppStorage properties
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showMemory") private var showMemory = true
    @AppStorage("showGPU") private var showGPU = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("usePercentageColors") private var usePercentageColors = true
    @AppStorage("useBetterPercentages") private var useBetterPercentages = true
    
    // Calculator operations enum
    private enum Operation {
        case add, subtract, multiply, divide
    }
    
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
    
    private func handleNumber(_ number: String) {
        if shouldResetInput {
            currentInput = number
            shouldResetInput = false
        } else {
            currentInput = currentInput == "0" ? number : currentInput + number
        }
    }
    
    private func handleOperation(_ operation: Operation) {
        if let number = Double(currentInput) {
            if let previous = previousNumber {
                calculateResult()
            } else {
                previousNumber = number
            }
        }
        currentOperation = operation
        shouldResetInput = true
    }
    
    private func calculateResult() {
        guard let number1 = previousNumber,
              let number2 = Double(currentInput) else { return }
        
        let result: Double
        
        switch currentOperation {
        case .add:
            result = number1 + number2
        case .subtract:
            result = number1 - number2
        case .multiply:
            result = number1 * number2
        case .divide:
            result = number2 != 0 ? number1 / number2 : 0
        case .none:
            return
        }
        
        currentInput = String(format: "%.2f", result)
        previousNumber = nil
        currentOperation = nil
    }
    
    private func handlePercent() {
        if let number = Double(currentInput) {
            currentInput = String(format: "%.2f", number / 100.0)
        }
    }
    
    private func handleDelete() {
        if currentInput.count > 1 {
            currentInput.removeLast()
        } else {
            currentInput = "0"
        }
    }
    
    private func handlePlusMinus() {
        if let number = Double(currentInput) {
            currentInput = String(format: "%.2f", number * -1)
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                CustomInput(placeholder: "", text: .constant(currentInput))
                
                VStack {
                    HStack {
                        CustomButton(variant: .primary, size: .default, action: handleDelete) {
                            Image(systemName: "delete.backward")
                        }
                        CustomButton(variant: .primary, size: .default, action: handlePlusMinus) {
                            Image(systemName: "plus.forwardslash.minus")
                        }
                        CustomButton(variant: .primary, size: .default, action: handlePercent) {
                            Image(systemName: "percent")
                        }
                        CustomButton(variant: .primary, size: .default, action: calculateResult) {
                            Image(systemName: "equal")
                        }
                    }
                    HStack {
                        CustomButton(variant: .primary, size: .default, action: { handleOperation(.divide) }) {
                            Image(systemName: "divide")
                        }
                        CustomButton(variant: .primary, size: .default, action: { handleOperation(.multiply) }) {
                            Image(systemName: "multiply")
                        }
                        CustomButton(variant: .primary, size: .default, action: { handleOperation(.subtract) }) {
                            Image(systemName: "minus")
                        }
                        CustomButton(variant: .primary, size: .default, action: { handleOperation(.add) }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(.gray)
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
