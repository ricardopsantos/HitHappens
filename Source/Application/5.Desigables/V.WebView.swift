//
//  WebView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 08/09/2024.
//

import Foundation
import UIKit
import SwiftUI
import WebKit
//
import DesignSystem
import Common

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

public struct WebViewModel: Equatable, Hashable, Sendable {
    fileprivate let title: String
    fileprivate let url: String
    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

struct WebView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let model: WebViewModel
    public init(model: WebViewModel) {
        self.model = model
    }

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .na,
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
            background: .defaultBackground,
            loadingModel: nil,
            alertModel: nil,
            networkStatus: nil
        ) {
            content
        }.onAppear {
            // viewModel.send(action: .didAppear)
        }.onDisappear {
            // viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            Header(text: model.title, hasCloseButton: true, onBackOrCloseClick: {
                dismiss()
            }).paddingHorizontal(SizeNames.defaultMargin)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if let url = URL(string: model.url) {
                WebViewRepresentable(url: url)
            }
        }
    }
}
