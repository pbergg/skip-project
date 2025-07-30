package skip.project

import androidx.compose.foundation.layout.Column
import androidx.compose.material.Text
import androidx.compose.runtime.Composable

@Composable
fun StripeCheckoutView(
    customerId: String,
    ephemeralKey: String,
    paymentIntentSecret: String,
    publishableKey: String
) {
    Column {
        Text("Customer ID: $customerId")
        Text("Ephemeral Key: $ephemeralKey")
        Text("PaymentIntent Secret: $paymentIntentSecret")
        Text("Publishable Key: $publishableKey")
    }
}