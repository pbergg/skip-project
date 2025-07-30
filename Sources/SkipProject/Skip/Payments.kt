package skip.project

import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import com.stripe.android.PaymentConfiguration
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult

@Composable
fun StripeCheckoutView(
    customerId: String,
    ephemeralKey: String,
    paymentIntentSecret: String,
    publishableKey: String
) {
    val paymentSheet = remember { PaymentSheet.Builder(::onPaymentSheetResult) }.build()
    val context = LocalContext.current

    var customerConfig by remember { mutableStateOf<PaymentSheet.CustomerConfiguration?>(null) }
    var clientSecret by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(context, customerId, ephemeralKey, paymentIntentSecret, publishableKey) {
        PaymentConfiguration.init(context, publishableKey)
        clientSecret = paymentIntentSecret
        customerConfig = PaymentSheet.CustomerConfiguration(
            id = customerId,
            ephemeralKeySecret = ephemeralKey
        )

        PaymentConfiguration.init(context, publishableKey)
    }

    Button(onClick = {
        val currentConfig = customerConfig
        val currentClientSecret = clientSecret

        if (currentConfig != null && currentClientSecret != null) {
            presentPaymentSheet(paymentSheet, currentConfig, currentClientSecret)
        }
    }) {
        Text("Checkout")
    }
}

private fun presentPaymentSheet(
    paymentSheet: PaymentSheet,
    customerConfig: PaymentSheet.CustomerConfiguration,
    paymentIntentClientSecret: String
) {
    paymentSheet.presentWithPaymentIntent(
        paymentIntentClientSecret,
        PaymentSheet.Configuration.Builder(merchantDisplayName = "My merchant name")
            .customer(customerConfig)
            // Set `allowsDelayedPaymentMethods` to true if your business handles
            // delayed notification payment methods like US bank accounts.
            .allowsDelayedPaymentMethods(true)
            .build()
    )
}

private fun onPaymentSheetResult(paymentSheetResult: PaymentSheetResult) {
    when(paymentSheetResult) {
        is PaymentSheetResult.Canceled -> {
            print("Canceled")
        }
        is PaymentSheetResult.Failed -> {
            print("Error: ${paymentSheetResult.error}")
        }
        is PaymentSheetResult.Completed -> {
            // Display for example, an order confirmation screen
            print("Completed")
        }
    }
}