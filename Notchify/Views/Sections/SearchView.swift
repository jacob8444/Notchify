import SwiftUI
import Cocoa
import QuickLookUI
import Combine

// MARK: - Search View
struct SearchView: View {
    let appDelegate: AppDelegate
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search files and apps...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Results View
            if !searchText.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(searchResults) { result in
                            SearchResultRow(result: result)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
        .frame(width: (appDelegate.preferences.windowWidth) - 24)
        .onChange(of: searchText) { _ in
            performSearch()
        }
    }
    
    private func performSearch() {
        // Implement search logic here
        // This is a placeholder implementation
        let workspace = NSWorkspace.shared
        var results: [SearchResult] = []
        
        // Search for applications
        let apps = workspace.runningApplications
            .filter { $0.activationPolicy == .regular }
            .filter { ($0.localizedName ?? "").lowercased().contains(searchText.lowercased()) }
        
        results.append(contentsOf: apps.map { app in
            SearchResult(
                id: UUID(),
                name: app.localizedName ?? "",
                path: app.bundleURL?.path ?? "",
                icon: app.icon ?? NSImage(),
                type: .application
            )
        })
        
        // Update results
        searchResults = results
    }
}

// MARK: - Search Result Model
struct SearchResult: Identifiable {
    let id: UUID
    let name: String
    let path: String
    let icon: NSImage
    let type: SearchResultType
}

enum SearchResultType {
    case application
    case file
}

// MARK: - Search Result Row View
struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        Button(action: {
            switch result.type {
            case .application:
                if let url = URL(string: result.path) {
                    NSWorkspace.shared.open(url)
                }
            case .file:
                if let url = URL(string: result.path) {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(nsImage: result.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Text(result.path)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

