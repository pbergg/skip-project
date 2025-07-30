//
//  SwiftUIView.swift
//  skip-project
//
//  Created by Paul Berg on 30/07/2025.
//

import SwiftUI
#if !SKIP
import StripePaymentSheet

struct StripeTestsView: View {
    let stripeData: StripeTestData
    @State var paymentSheet: PaymentSheet?
    @State  var presentPaymentSheet = false
    
    var body: some View {
        VStack {
            if let paymentSheet {
                Button("Make payment") { presentPaymentSheet = true }
                    .paymentSheet(isPresented: $presentPaymentSheet,
                                  paymentSheet: paymentSheet,
                                  onCompletion: onPaymentCompletion)

            } else {
                Button("Fetch payment info", action: prepareSheet)
            }
        }
    }
    
    func onPaymentCompletion(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("Payment completed!")
        case .canceled:
            print("Payment canceled by user")
        case .failed(let error):
            print("An error has occured: \(error.localizedDescription)")
        }
    }
    
    func prepareSheet() {
        STPAPIClient.shared.publishableKey = stripeData.publishableKey
        
        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = "Merchant inc"
        config.customer = .init(id: stripeData.customerId, ephemeralKeySecret: stripeData.ephemeralKeysSecret)
        
        paymentSheet = PaymentSheet(paymentIntentClientSecret: stripeData.paymentIntentSecret, configuration: config)
    }
}
#endif

struct StripeTestData: Codable {
    let customerId: String
    let ephemeralKeysSecret: String
    let paymentIntentSecret: String
    let publishableKey: String
}

let serverUrl = "http://192.168.1.251:8080"
class NetworkingManager {
    private init() { }
    
    static func getStripeData() async throws -> StripeTestData{
        let endpoint = "stripe-tests"
        guard let url = URL(string: "\(serverUrl)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(StripeTestData.self, from: data)
    }
}

struct PaymentsTestView: View {
    @State var stripeData: StripeTestData?
    @State var status = ""
    
    var body: some View {
        VStack {
            Text(stripeData == nil ? "No data" : "Data fetched")
                .bold()
            
            Text(status)
                .italic()
            
            Button("Get data") {
                Task {
                    do {
                        status = "Fetching data..."
                        let stripeData = try await NetworkingManager.getStripeData()
                        status = "Data fetched: \(stripeData.customerId)"
                        self.stripeData = stripeData
                    } catch {
                        print(error)
                        status = error.localizedDescription
                    }
                }
            }
            
            if let stripeData {
            #if !SKIP
                StripeTestsView(stripeData: stripeData)
            #else
                ComposeView { ctx in
                    // SKIP INSERT:
                    // StripeCheckoutView(
                    //     stripeData.customerId,
                    //     stripeData.ephemeralKeysSecret,
                    //     stripeData.paymentIntentSecret,
                    //     stripeData.publishableKey
                    // )
                }
            #endif
            }

        }
    }
}
