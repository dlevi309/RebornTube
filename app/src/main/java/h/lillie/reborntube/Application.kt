package h.lillie.reborntube

import android.app.Application

class Application : Application() {
    companion object {
        // Video URL
        private var videoURL = String()
        fun getVideoURL() : String {
            return videoURL
        }
        fun setVideoURL(url: String) {
            videoURL = url
        }

        // Audio URL
        private var audioURL = String()
        fun getAudioURL() : String {
            return audioURL
        }
        fun setAudioURL(url: String) {
            audioURL = url
        }

        // SponsorBlock Info
        private var sponsorBlockInfo = String()
        fun getSponsorBlockInfo() : String {
            return sponsorBlockInfo
        }
        fun setSponsorBlockInfo(info: String) {
            sponsorBlockInfo = info
        }
    }
}