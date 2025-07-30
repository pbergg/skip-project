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

    LaunchedEffect(customerId, ephemeralKey, paymentIntentSecret, publishableKey) {
        PaymentConfiguration.init(context, publishableKey)
        clientSecret = paymentIntentSecret
        customerConfig = PaymentSheet.CustomerConfiguration(
            id = customerId,
            ephemeralKeySecret = ephemeralKey
        )
    }

    Button(onClick = {
        val config = customerConfig
        val secret = clientSecret
        if (config != null && secret != null) {
            paymentSheet.presentWithPaymentIntent(
                secret,
                PaymentSheet.Configuration.Builder("My merchant name")
                    .customer(config)
                    .allowsDelayedPaymentMethods(true)
                    .build()
            )
        }
    }) {
        Text("Checkout")
    }
}

private fun onPaymentSheetResult(paymentSheetResult: PaymentSheetResult) {
    when (paymentSheetResult) {
        is PaymentSheetResult.Canceled -> println("Canceled")
        is PaymentSheetResult.Failed -> println("Error: ${paymentSheetResult.error}")
        is PaymentSheetResult.Completed -> println("Completed")
    }
}