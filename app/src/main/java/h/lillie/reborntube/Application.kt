package h.lillie.reborntube

import android.app.Application

class Application : Application() {
    companion object {
        // Video Data
        private var videoData = String()
        fun getVideoData() : String {
            return videoData
        }
        fun setVideoData(info: String) {
            videoData = info
        }
    }
}