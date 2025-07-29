package skip.project

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text

import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize

import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.platform.LocalContext

@Composable
fun MyComposableWithData(data: ByteArray) {
    Text("Received data: ${data.size} bytes")
}

@Composable
fun PdfViewerFromBytes(data: ByteArray) {
    AndroidView(
        modifier = Modifier.fillMaxSize(), // internal layout control
        factory = { ctx ->
            com.github.barteksc.pdfviewer.PDFView(ctx, null).apply {
                fromBytes(data)
                    .enableSwipe(true)
                    .enableDoubletap(true)
                    .spacing(10)
                    .load()
            }
        }
    )
}