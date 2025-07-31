//
//  SwiftUIView.swift
//  skip-project
//
//  Created by Paul Berg on 31/07/2025.
//

import SwiftUI
#if !SKIP
import StripePaymentSheet

struct StripeView: View {
    @ObservedObject var paymentStateModel: PaymentStateModel
    let stripeData: StripeTestData
    
    @State var paymentSheet: PaymentSheet?
    @State var presentPaymentSheet = false
    
    var body: some View {
        VStack {
            if let paymentSheet {
                Button("Make payment") {
                    paymentStateModel.state = .loading
                    presentPaymentSheet = true
                }
                .paymentSheet(isPresented: $presentPaymentSheet,
                              paymentSheet: paymentSheet,
                              onCompletion: onPaymentCompletion)
                
            }
        }
        .onAppear(perform: prepareSheet)
    }
    
    func onPaymentCompletion(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            paymentStateModel.state = .completed
            print("Payment completed!")
        case .canceled:
            paymentStateModel.state = .canceled
            print("Payment canceled by user")
        case .failed(let error):
            paymentStateModel.state = .failed
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

struct PaymentsWithLoadingView: View {
    @State var stripeData: StripeTestData?
    @StateObject var paymentStateModel = PaymentStateModel()
    
    var body: some View {
        VStack {
            Text(stripeData == nil ? "Noww data" : "Data fetched")
                .bold()
            
            Text(paymentStateModel.state.rawValue)
                .italic()
                .onTapGesture {
                    declare()
                }
            
            Button("Get data") {
                Task {
                    do {
                        let stripeData = try await NetworkingManager.getStripeData()
                        self.stripeData = stripeData
                    } catch {
                        print(error)
                    }
                }
            }
            
            if let stripeData {
            #if !SKIP
                StripeView(paymentStateModel: paymentStateModel,
                           stripeData: stripeData)
            #else
                ComposeView { ctx in
                    StripeViewComposer(
                        customerId: stripeData.customerId,
                        ephemeralKey: stripeData.ephemeralKeysSecret,
                        paymentIntentSecret: stripeData.paymentIntentSecret,
                        publishableKey: stripeData.publishableKey
                    ) {
                        paymentStateModel.updateFromString($0)
                    }
                    .Compose(context: ctx)
                }
            #endif
            }

        }
    }
    
    func declare() {
        paymentStateModel.state = .loading
    }
}

#if SKIP
struct StripeViewComposer: ContentComposer {
    let customerId: String
    let ephemeralKey: String
    let paymentIntentSecret: String
    let publishableKey: String
    let stateUpdate: (String) -> Void
    
    @Composable func Compose(context: ComposeContext) {
        StripeCheckoutLoadingView(
            customerId,
            ephemeralKey,
            paymentIntentSecret,
            publishableKey,
            stateUpdate
        )
    }
}
#endif



class PaymentStateModel: ObservableObject {
    enum PaymentState: String {
        case standby
        case loading
        case failed
        case canceled
        case completed
    }

    @Published var state: PaymentState = .standby
    
    func updateFromString(_ str: String) {
        if let newState = PaymentState(rawValue: str) {
            state = newState
        } else {
            print("⚠ Couldn't initialize payment state from raw value: \(str)")
        }
    }
}
