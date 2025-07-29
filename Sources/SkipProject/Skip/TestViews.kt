package skip.project

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text

@Composable
fun MyComposableWithData(data: ByteArray) {
    Text("Received data: ${data.size} bytes")
}