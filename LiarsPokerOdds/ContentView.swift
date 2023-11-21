//
//  ContentView.swift
//  LiarsPokerOdds
//
//  Created by Nick Warriner on 11/20/23.
//
import SwiftUI

struct ContentView: View {
    @State private var numberOfPlayers = 0
    @State private var nOfAKind = 0
    @State private var cardRank = 0
    @State private var numDigits = 8
    @State private var amountOwned = 0
    @State private var probability = 1.0
    @State private var lastCalculatedProbability = 1.0
    @State private var lastNOfAKindWord = "zero"
    @State private var lastCardRankWord = "zero"
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
    
    var body: some View {
        Form {
            Section(header: Text("Liar's Poker Bet Variables")
                .frame(maxWidth: .infinity, alignment: .center)){
                    VStack(alignment: .leading) {
                        Text("Serial Number Length (US Bills = 8)").bold()
                        TextField("", value: $numDigits, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading) {
                        Text("Number of Players").bold()
                        TextField("", value: $numberOfPlayers, formatter: NumberFormatter()).keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading) {
                        Text("N-of-a-kind").bold()
                        TextField("", value: $nOfAKind, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading) {
                        Text("Number being bet on (0-9)").bold()
                        TextField("", value: $cardRank, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading) {
                        Text("How many do you have?").bold()
                        TextField("", value: $amountOwned, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                }
            
            Button(action: {calculateProbability(numberOfPlayers, nOfAKind, amountOwned, numDigits)}) {
                HStack {
                    Spacer()
                    Text("Calculate Probability")
                    Spacer()
                }
            }
            
            Section {
                let probabilityString = String(format: "%.2f", probability * 100) + "%"
                Text(probabilityString)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(
                        probability < 0.25 ? Color.red :
                            probability < 0.50 ? Color.orange :
                            probability < 0.75 ? Color.blue :
                            Color.green
                    ).listRowSeparator(.hidden)
                
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                    Text("There is a \(probabilityString) chance that other players have at least \(lastNOfAKindWord) \(lastCardRankWord)s").padding(.bottom)
                }.padding(.horizontal).listRowInsets(EdgeInsets())
                
            }.listRowInsets(EdgeInsets())
        }
    }
    
    func calculateProbability(_ numPlayers: Int, _ nOfAKind: Int, _ amountOwned: Int, _ numDigits: Int){
        hideKeyboard()
        let trials = nOfAKind-amountOwned-1
        let digitsInPlay = (numPlayers-1) * numDigits
        
        if trials < 0 {
            probability = 1.0
            return
        }
        
        if trials > digitsInPlay{
            probability = 0.0
            return
        }
        
        probability = binomialCumulativeDistribution(n: digitsInPlay, k: trials, p: 0.1)
        
        lastCalculatedProbability = probability
        if let nOfAKindWord = formatter.string(from: NSNumber(value: nOfAKind-amountOwned)),
           let cardRankWord = formatter.string(from: NSNumber(value: cardRank)) {
            lastNOfAKindWord = nOfAKindWord
            lastCardRankWord = cardRankWord
        }
    }
    
    /*
     Function: binomialCumulativeDistribution(n: Int, k: Int, p: Double)
     
     Parameters:
     - n: The total number of trials. This should be a positive integer.
     - k: The total number of successful trials. This should be a positive integer less than or equal to 'n'.
     - p: The probability of success in a single trial. This should be a Double between 0 and 1 inclusive.
     
     This function calculates the cumulative distribution of a binomial distribution given the parameters.
     */
    func binomialCumulativeDistribution(n: Int, k: Int, p: Double) -> Double {
        var probability = 1.0
        for i in 0...k {
            let combinations = nCr(n, i)
            let successProbability = pow(p, Double(i))
            let failureProbability = pow(1.0 - p, Double(n - i))
            probability -= (combinations * successProbability * failureProbability)
        }
        return probability
    }
    
    
    func factorial(_ x: Int) -> Double {
        return (x == 0) ? 1.0 : Double(x) * factorial(x - 1)
    }
    
    func nCr(_ n: Int, _ r: Int) -> Double {
        return factorial(n) / (factorial(r) * factorial(n - r))
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

#Preview {
    ContentView()
}
