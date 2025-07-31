//
//  ContentTrackSizeView.swift
//  FairPlayAdvanced
//
//  Created by yhpark on 4/10/25.
//  Copyright © 2025 DoveRunner. All rights reserved.
//

import SwiftUI
import DoveRunnerFairPlay

struct ContentTrackSizePopupView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    let manifest: HLSPlaylistParser.HLSManifest
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    DispatchQueue.main.async {
                        isPresented = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            
            // 팝업 내용
            VStack {
                HStack {
                    Text("Content Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            isPresented = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // 콘텐츠
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let packInfo = manifest.packInfo {
                            // ContentPackInfoView 재사용
                            ContentPackInfoView(packInfo: packInfo)
                        } else {
                            // ContentPackInfo가 없는 경우 기본 Manifest 정보 표시
                            displayManifestInfo()
                        }
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(20)
        }
    }
    
    private func displayManifestInfo() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 비디오 트랙 정보
            if !manifest.videos.isEmpty {
                Text("Video Tracks")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(0..<manifest.videos.count, id: \.self) { index in
                    let video = manifest.videos[index]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Track \(index + 1):")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Resolution: \(video.resolution)")
                            .font(.caption)
                        Text("Bandwidth: \(FormatUtils.formatBandwidth(video.bandwidth))")
                            .font(.caption)
                        if !video.codecs.isEmpty {
                            Text("Codecs: \(video.codecs)")
                                .font(.caption)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                }
                
                Divider()
            }
            
            // 오디오 트랙 정보
            if !manifest.audios.isEmpty {
                Text("Audio Tracks")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(0..<manifest.audios.count, id: \.self) { index in
                    let audio = manifest.audios[index]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(audio.name) (\(audio.language ?? "N/A"))")
                            .font(.subheadline)
                        if let channels = audio.channels {
                            Text("Channels: \(channels)")
                                .font(.caption)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                }
                
                Divider()
            }
            
            // 자막 트랙 정보
            if !manifest.subtitles.isEmpty {
                Text("Subtitle Tracks")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(0..<manifest.subtitles.count, id: \.self) { index in
                    let subtitle = manifest.subtitles[index]
                    Text("\(subtitle.name) (\(subtitle.language))")
                        .font(.subheadline)
                        .padding(.leading, 8)
                        .padding(.bottom, 4)
                }
            }
        }
    }
}
