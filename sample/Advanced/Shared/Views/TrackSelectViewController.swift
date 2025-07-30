import SwiftUI
import DoveRunnerFairPlay

// MARK: - Utility Functions
struct FormatUtils {
    /// Format file size
    static func formatFileSize(_ size: String) -> String {
        // Return as is if the unit is already included
        if size.lowercased().contains("kb") || size.lowercased().contains("mb") ||
           size.lowercased().contains("gb") || size.lowercased().contains("b") {
            return size
        }
        
        // Convert to appropriate unit if only number is provided
        if let sizeBytes = Double(size) {
            if sizeBytes >= 1_000_000_000 {
                return String(format: "%.2f GB", sizeBytes / 1_000_000_000)
            } else if sizeBytes >= 1_000_000 {
                return String(format: "%.2f MB", sizeBytes / 1_000_000)
            } else if sizeBytes >= 1_000 {
                return String(format: "%.2f KB", sizeBytes / 1_000)
            } else {
                return "\(Int(sizeBytes)) B"
            }
        }
        
        return size
    }
    
    /// Format bitrate
    static func formatBitrate(_ bitrate: String) -> String {
        // Return as is if the unit is already included
        if bitrate.lowercased().contains("kbps") || bitrate.lowercased().contains("mbps") ||
           bitrate.lowercased().contains("bps") {
            return bitrate
        }
        
        // Convert to appropriate unit if only number is provided
        if let bitrateValue = Double(bitrate) {
            if bitrateValue >= 1_000_000 {
                return String(format: "%.2f Mbps", bitrateValue / 1_000_000)
            } else if bitrateValue >= 1_000 {
                return String(format: "%.2f Kbps", bitrateValue / 1_000)
            } else {
                return "\(Int(bitrateValue)) bps"
            }
        }
        
        return bitrate
    }
    
    /// Format duration
    static func formatDuration(_ duration: String) -> String {
        // Convert seconds to HH:MM:SS format
        // If duration is already in "01:30:45" format, use it as is and add total seconds
        if duration.contains(":") {
            // Calculate total seconds from HH:MM:SS format
            let components = duration.split(separator: ":")
            if components.count == 3,
               let hours = Int(components[0]),
               let minutes = Int(components[1]),
               let seconds = Int(components[2]) {
                let totalSeconds = hours * 3600 + minutes * 60 + seconds
                return "\(duration) (\(totalSeconds) sec)"
            }
            return duration
        } else if let durationSeconds = Double(duration) {
            // Convert number of seconds to HH:MM:SS format
            let hours = Int(durationSeconds) / 3600
            let minutes = (Int(durationSeconds) % 3600) / 60
            let seconds = Int(durationSeconds) % 60
            
            let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            return "\(formattedTime) (\(Int(durationSeconds)) sec)"
        }
        return duration
    }
    
    /// Format network bandwidth
    static func formatBandwidth(_ bandwidth: Int) -> String {
        if bandwidth >= 1_000_000 {
            return String(format: "%.2f Mbps", Double(bandwidth) / 1_000_000.0)
        } else {
            return String(format: "%.2f Kbps", Double(bandwidth) / 1_000.0)
        }
    }
}

// MARK: - Track View Components
struct VideoTrackView: View {
    let track: HLSPlaylistParser.ContentPackInfo.VideoTrack
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Track \(index + 1):")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("Size: \(FormatUtils.formatFileSize(track.size))")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Resolution: \(track.resolution)")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Bitrate: \(FormatUtils.formatBitrate(track.bitrate))")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.leading, 8)
        .padding(.bottom, 4)
    }
}

struct AudioTrackView: View {
    let track: HLSPlaylistParser.ContentPackInfo.AudioTrack
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Track \(index + 1):")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("Language: \(track.language)")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Size: \(FormatUtils.formatFileSize(track.size))")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.leading, 8)
        .padding(.bottom, 4)
    }
}

struct TextTrackView: View {
    let track: HLSPlaylistParser.ContentPackInfo.TextTrack
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Track \(index + 1):")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("Language: \(track.language)")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Size: \(FormatUtils.formatFileSize(track.size))")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.leading, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Content Pack Info View
struct ContentPackInfoView: View {
    let packInfo: HLSPlaylistParser.ContentPackInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration: \(FormatUtils.formatDuration(packInfo.duration))")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Output Format: \(packInfo.outputFormat)")
                .font(.caption)
                .foregroundColor(.primary)
            Text("Version: \(packInfo.version)")
                .font(.caption)
                .foregroundColor(.primary)
            
            // Video Tracks information
            if let videoTracks = packInfo.tracks.video, !videoTracks.isEmpty {
                tracksSection(title: "Video", tracks: videoTracks) { track, index in
                    VideoTrackView(track: track, index: index)
                }
            }
            
            // Audio Tracks information
            if let audioTracks = packInfo.tracks.audio, !audioTracks.isEmpty {
                tracksSection(title: "Audio", tracks: audioTracks) { track, index in
                    AudioTrackView(track: track, index: index)
                }
            }
            
            // Text Tracks information
            if let textTracks = packInfo.tracks.text, !textTracks.isEmpty {
                tracksSection(title: "Text", tracks: textTracks) { track, index in
                    TextTrackView(track: track, index: index)
                }
            }
        }
    }
    
    private func tracksSection<T>(
        title: String,
        tracks: [T],
        @ViewBuilder content: @escaping (T, Int) -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title) Tracks:")
                .fontWeight(.medium)
                .foregroundColor(.primary)
            ForEach(0..<tracks.count, id: \.self) { index in
                content(tracks[index], index)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Radio Button Component
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
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Main HLS Download Track Select View
struct HLSTrackSelectView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    let manifest: HLSPlaylistParser.HLSManifest
    let fpsContent: FPSContent
    
    // State variable to manage selection
    @State private var selectedVideoIndex: Int = 0
    
    init(isPresented: Binding<Bool>, manifest: HLSPlaylistParser.HLSManifest, fpsContent: FPSContent) {
        _isPresented = isPresented
        self.manifest = manifest
        self.fpsContent = fpsContent
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Videos section (Radio Buttons)
                if !manifest.videos.isEmpty {
                    videosSection
                }
                
                if !manifest.audios.isEmpty {
                    audiosSection
                }
                
                // Subtitles section
                if !manifest.subtitles.isEmpty {
                    subtitlesSection
                }
                
                // Content Pack Info section
                if let packInfo = manifest.packInfo {
                    contentPackSection(packInfo)
                }
                
                buttonsSection
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    // MARK: - Section Views
    
    private var videosSection: some View {
        VStack(alignment: .leading) {
            Text("Videos")
                .bold()
                .foregroundColor(.primary)
            
            ForEach(Array(manifest.videos.enumerated()), id: \.element.resolution) { index, video in
                RadioButton(
                    selected: selectedVideoIndex == index,
                    title: "Resolution: \(video.resolution)",
                    subtitle: "Bandwidth: \(FormatUtils.formatBandwidth(video.bandwidth))"
                ) {
                    selectedVideoIndex = index
                }
                .padding(.vertical, 5)
            }
            Divider()
        }
    }
    
    private var audiosSection: some View {
        VStack(alignment: .leading) {
            Text("Audios")
                .bold()
                .foregroundColor(.primary)
            
            ForEach(manifest.audios, id: \.uri) { audio in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(audio.name) (\(audio.language ?? "N/A"))")
                        .font(.body)
                        .foregroundColor(.primary)
                    Text("Channels: \(audio.channels ?? "N/A")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
            Divider()
        }
    }
    
    private var subtitlesSection: some View {
        VStack(alignment: .leading) {
            Text("Subtitles")
                .bold()
                .foregroundColor(.primary)
            
            ForEach(manifest.subtitles, id: \.uri) { subtitle in
                Text("\(subtitle.name) (\(subtitle.language))")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.vertical, 5)
            }
            Divider()
        }
    }
    
    private func contentPackSection(_ packInfo: HLSPlaylistParser.ContentPackInfo) -> some View {
        VStack(alignment: .leading) {
            Text("Content Pack Info")
                .bold()
                .foregroundColor(.primary)
            
            ContentPackInfoView(packInfo: packInfo)
        }
    }
    
    private var buttonsSection: some View {
        HStack(spacing: 16) {
            Button("Download") {
                handleDownload()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            
            Button("Close") {
                DispatchQueue.main.async {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .foregroundColor(.blue)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .padding()
    }
    
    // MARK: - Action Handlers
    
    private func handleDownload() {
        // Print selected information
        print("Selected Video: ")
        let selectedVideo = manifest.videos[selectedVideoIndex]
        print("- Resolution: \(selectedVideo.resolution)")
        print("- Bandwidth: \(FormatUtils.formatBandwidth(selectedVideo.bandwidth))")
        print("- Codecs: \(selectedVideo.codecs)")
        
        SDKManager.sharedManager.downloadStream(for: fpsContent, minimumBitrate: String(selectedVideo.bandwidth))
        DispatchQueue.main.async {
            isPresented = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
