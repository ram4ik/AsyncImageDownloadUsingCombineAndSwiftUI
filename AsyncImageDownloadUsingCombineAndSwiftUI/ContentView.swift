//
//  ContentView.swift
//  AsyncImageDownloadUsingCombineAndSwiftUI
//
//  Created by Ramill Ibragimov on 11.12.2020.
//

import SwiftUI
import Combine

struct ContentView: View {
    let urls = [
        "https://www.citroen.ee/files/1003533.jpg",
        "https://www.citroen.ee/files/1003427.jpg",
        "https://www.citroen.ee/files/1003422.jpg",
    ]
    
    var body: some View {
        ScrollView {
            ForEach(urls, id: \.self) { url in
                AsyncImageView(url: URL(string: url)!)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

struct AsyncImageView: View {
    @ObservedObject private var downloader: ImageDownloader
    
    private var image: some View {
        Group {
            if downloader.image != nil {
                Image(uiImage: downloader.image!).resizable()
            } else {
                ProgressView()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    init(url: URL) {
        downloader = ImageDownloader(url: url)
    }
    
    var body: some View {
        image
            .onAppear() {
                downloader.start()
            }
            .onDisappear() {
                downloader.stop()
            }
    }
}

class ImageDownloader: ObservableObject {
    @Published private(set) var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    
    init(url: URL) {
        self.url = url
    }
    
    func start() {
        cancellable = URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .map { UIImage(data:  $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func stop() {
        cancellable?.cancel()
    }
    
    deinit {
        cancellable?.cancel()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
