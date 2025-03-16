//
//  ContentView.swift
//  DealAnalysis
//
//  Created by Karla Sosa on 3/15/25.
//

import SwiftUI
import MapKit

class SearchCompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func updateQuery(_ query: String) {
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var propertyAddress: String = ""
    @State private var addressSuggestions: [String] = []
    @State private var propertyPrice: String = ""
    @State private var grossIncome: String = ""
    @State private var operatingExpenses: String = ""
    @State private var debtService: String = ""
    @State private var cashInvested: String = ""
    
    @State private var noi: Double? = nil
    @State private var capRate: Double? = nil
    @State private var cashFlow: Double? = nil
    @State private var cashOnCashReturn: Double? = nil
    @State private var showSuggestions: Bool = false // Added state to control suggestions visibility
    @StateObject private var searchDelegate = SearchCompleterDelegate()
    
    var body: some View {
        VStack {
            Text("Real Estate Metrics Calculator")
                .font(.title)
                .padding()
            
            TextField("Property Address", text: $propertyAddress)
                .onChange(of: propertyAddress) { _, _ in
                    searchDelegate.updateQuery(propertyAddress)
                }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
        
                List(searchDelegate.searchResults, id: \ .self) { suggestion in
                    Text("\(suggestion.title), \(suggestion.subtitle)" )
                        .onTapGesture {
                            propertyAddress = suggestion.title
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        searchDelegate.searchResults.removeAll()
                                    }
                        }
                }
                .frame(height: searchDelegate.searchResults.isEmpty ? 0 : 150)
            
            Group {
                TextField("Property Price ($)", text: $propertyPrice)
                TextField("Gross Income ($/year)", text: $grossIncome)
                TextField("Operating Expenses ($/year)", text: $operatingExpenses)
                TextField("mortgage (principal + interest) ($/year)", text: $debtService)
                TextField("Cash Invested ($)", text: $cashInvested)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .padding()
            
            HStack {
                
                Button("Calculate") {
                    calculateMetrics()
                    hideKeyboard()
                } .frame(width: 80)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                
                Button("Reset") {
                    resetFields ()
                }.frame(width: 80)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                
            }
            
            
            if let noi = noi, let capRate = capRate, let cashFlow = cashFlow, let cashOnCashReturn = cashOnCashReturn {
                VStack(alignment: .leading) {
                    Text("NOI: $\(noi, specifier: "%.2f")")
                    Text("Cap Rate: \(capRate, specifier: "%.2f")%")
                    Text("Cash Flow: $\(cashFlow, specifier: "%.2f")")
                    Text("Cash on Cash Return: \(cashOnCashReturn, specifier: "%.2f")%")
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func calculateMetrics() {
        guard let price = Double(propertyPrice),
              let income = Double(grossIncome),
              let expenses = Double(operatingExpenses),
              let debt = Double(debtService),
              let invested = Double(cashInvested) else {
            return
        }
        
        noi = income - expenses
        capRate = (noi! / price) * 100
        cashFlow = noi! - debt
        cashOnCashReturn = (cashFlow! / invested) * 100
    }
    
    func resetFields () {
        propertyPrice = ""
        grossIncome = ""
        operatingExpenses = ""
        debtService = ""
        cashInvested = ""
        noi = nil
        capRate = nil
        cashFlow = nil
        cashOnCashReturn = nil
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
    
    
    #Preview {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
    

