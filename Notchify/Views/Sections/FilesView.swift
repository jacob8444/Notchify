//
//  FilesView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI

struct FilesView: View {
    let appDelegate: AppDelegate?
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted = false
    
    var body: some View {
        HStack {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if droppedFiles.isEmpty {
                            Spacer()
                            Text("Drop files here")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                            Spacer()
                        } else {
                            ForEach(droppedFiles, id: \.self) { url in
                                FileItemView(url: url) { file in
                                    if let index = droppedFiles.firstIndex(of: file) {
                                        droppedFiles.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .frame(height: 70)
                .cornerRadius(10)
                .padding(.bottom, 10)
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 22)
        .padding(.bottom, 10)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            let dispatchGroup = DispatchGroup()
            var loadedFiles: [URL] = []
            
            for provider in providers {
                if provider.canLoadObject(ofClass: URL.self) {
                    dispatchGroup.enter()
                    _ = provider.loadObject(ofClass: URL.self) { url, error in
                        if let url = url {
                            loadedFiles.append(url)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                droppedFiles.append(contentsOf: loadedFiles)
            }
            
            return true
        }
    }
}

struct FileItemView: View {
    let url: URL
    let onRemove: (URL) -> Void
    @State private var isDragging = false
    @State private var isHovered = false
    @State private var fileIcon: NSImage?
    
    var body: some View {
        VStack(spacing: 4) {
            Group {
                if let icon = fileIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "doc.fill")
                }
            }
            .font(.system(size: 24))
            .frame(width: 32, height: 32)
            Text(url.lastPathComponent)
                .lineLimit(1)
                .font(.system(size: 10))
                .frame(width: 60)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.1))
                .opacity(isHovered || isDragging ? 1 : 0)
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .opacity(isDragging ? 0.5 : 1.0)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .onDrag {
            isDragging = true
            return NSItemProvider(object: url as NSURL)
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            isDragging = false
            onRemove(url)
            return true
        }
        .onAppear {
            fileIcon = NSWorkspace.shared.icon(forFile: url.path)
        }
    }
}

#Preview {
    NotchView()
        .environmentObject(AppDelegate())
}
