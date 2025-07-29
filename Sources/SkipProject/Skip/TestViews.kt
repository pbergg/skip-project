package skip.project

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text

@Composable
fun MyComposableWithName(name: String) {
    Text("Hello, $name from Kotlin!")
}