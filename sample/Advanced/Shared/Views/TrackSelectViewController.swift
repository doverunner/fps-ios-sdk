//
//  TrackSelectViewController.swift
//  PallyConFPSAdvanced
//
//  Created by yhpark on 1/6/25.
//  Copyright © 2025 PallyCon. All rights reserved.
//

import SwiftUI
import PallyConFPSSDK

struct PopupView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    let manifest: HLSTracksPlaylistParser.HLSManifest
    let fpsContent: FPSContent  // FPSContent 추가
    
    // 선택된 상태를 관리하기 위한 State 변수들
    @State private var selectedVideoIndex: Int = 0
    
    init(isPresented: Binding<Bool>, manifest: HLSTracksPlaylistParser.HLSManifest, fpsContent: FPSContent) {
        _isPresented = isPresented
        self.manifest = manifest
        self.fpsContent = fpsContent
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Videos 섹션 (Radio Buttons)
                if !manifest.videos.isEmpty {
                    Section(header: Text("Videos").bold()) {
                        ForEach(Array(manifest.videos.enumerated()), id: \.element.resolution) { index, video in
                            RadioButton(
                                selected: selectedVideoIndex == index,
                                title: "Resolution: \(video.resolution)",
                                subtitle: "Bandwidth: \(formatBandwidth(video.bandwidth))"
                            ) {
                                selectedVideoIndex = index
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    Divider()
                }
                
                if !manifest.audios.isEmpty {
                    Section(header: Text("Audios").bold()) {
                        ForEach(manifest.audios, id: \.uri) { audio in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(audio.name) (\(audio.language ?? "N/A"))")
                                    .font(.body)
                                Text("Channels: \(audio.channels ?? "N/A")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    Divider()
                }
                
                // Subtitles 섹션
                if !manifest.subtitles.isEmpty {
                    Section(header: Text("Subtitles").bold()) {
                        ForEach(manifest.subtitles, id: \.uri) { subtitle in
                            Text("\(subtitle.name) (\(subtitle.language))")
                                .font(.body)
                                .padding(.vertical, 5)
                        }
                    }
                    Divider()
                }
                
                // PallyCon Info 섹션
                if let pallyConInfo = manifest.pallyConInfo {
                    Section(header: Text("PallyCon Info").bold()) {
                        Text("Duration: \(pallyConInfo.duration) seconds")
                        Text("Output Format: \(pallyConInfo.outputFormat)")
                        Text("Version: \(pallyConInfo.version)")
                    }
                }
                
                HStack(spacing: 16) {
                    Button("Download") {
                        // 선택된 정보 출력
                        print("Selected Video: ")
                        let selectedVideo = manifest.videos[selectedVideoIndex]
                        print("- Resolution: \(selectedVideo.resolution)")
                        print("- Bandwidth: \(formatBandwidth(selectedVideo.bandwidth))")
                        print("- Codecs: \(selectedVideo.codecs)")
                        
                        PallyConSDKManager.sharedManager.downloadStream(for: fpsContent, minimumBitrate: String(selectedVideo.bandwidth))
                        isPresented = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                    Button("Close") {
                        isPresented = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
                .padding()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    private func formatBandwidth(_ bandwidth: Int) -> String {
        if bandwidth >= 1_000_000 {
            return String(format: "%.2f Mbps", Double(bandwidth) / 1_000_000.0)
        } else {
            return String(format: "%.2f Kbps", Double(bandwidth) / 1_000.0)
        }
    }
}

// 라디오 버튼 컴포넌트
struct RadioButton: View {
    let selected: Bool
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selected ? .blue : .gray)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.body)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
