package skip.project

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

@Composable
fun DirectView(name: String, onComplete: (String) -> Unit) {
    Column {
        Text("Customer ID: $name")
        Button(onClick = { onComplete("John") }) {
            Text("Continue")
        }
    }
}