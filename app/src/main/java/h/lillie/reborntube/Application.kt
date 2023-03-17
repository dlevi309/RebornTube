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

        // Artwork URL
        private var artworkURL = String()
        fun getArtworkURL() : String {
            return artworkURL
        }
        fun setArtworkURL(url: String) {
            artworkURL = url
        }

        // Title
        private var title = String()
        fun getTitle() : String {
            return title
        }
        fun setTitle(info: String) {
            title = info
        }

        // Author
        private var author = String()
        fun getAuthor() : String {
            return author
        }
        fun setAuthor(info: String) {
            author = info
        }

        // Live
        private var live : Boolean = false

        fun getLive() : Boolean {
            return live
        }

        fun setLive(info: Boolean) {
            live = info
        }
    }
}