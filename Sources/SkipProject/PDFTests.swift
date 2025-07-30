//
//  SwiftUIView.swift
//  skip-project
//
//  Created by Paul Berg on 29/07/2025.
//

import SwiftUI

let urlStr = "https://firebasestorage.googleapis.com/v0/b/docberg-b0b34.firebasestorage.app/o/pdf_files%2F2C2C97A6581D4BBDB216A998367C73ED?alt=media&token=28687ed4-2ea9-4596-be8b-02cf951f7a5d"


struct PDFSheet: View {
    let data: Data
    var body: some View {
        NavigationStack {
            VStack {
            #if !SKIP
                PDFViewer(data: data)
            #else
                let kotlinData = data.kotlin()
                ComposeView { ctx in
                    // SKIP INSERT:
                    // PdfViewerFromBytes(kotlinData)
                }
            #endif
            }
            #if !SKIP
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share", systemImage: "heart") {
                        //More to come
                    }
                }
            }
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

struct PDFTests: View {
    @State var bitCount = 0
    @State var data: Data?
    @State var openSheet = false
    
    var body: some View {
        VStack {
            Text("New Bitcount: \(bitCount)")
            
            Button("Fetch data") {
                fetchBitCount()
            }
            
            if let _ = data {
                Button("Open sheet") {
                    openSheet = true
                }
            }
        }
        
        .fullScreenCover(isPresented: $openSheet) {
            if let data {
                PDFSheet(data: data)
            }
        }
    }
    
    func fetchBitCount() {
        Task {
            do {
                let data = try await fetchPDF()
                bitCount = data.count
                self.data = data
            } catch {
                print(error)
            }
        }
    }
    
    func fetchPDF() async throws -> Data {
        guard let url = URL(string: urlStr) else {
            print("❌ Invalid URL")
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
            print("❌ Invalid URL response")
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}

#if !SKIP
import SwiftUI
import PDFKit

struct PDFViewer: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(data: data)
        view.autoScales = true
        return view
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        //Nothing to see here
    }
}
#endif
