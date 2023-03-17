package h.lillie.reborntube

import org.json.JSONObject

class Loader {
    fun init(json: String) : Array<Any> {
        val jsonObject = JSONObject(json)

        val artworkArray = jsonObject.getJSONObject("videoDetails").getJSONObject("thumbnail").getJSONArray("thumbnails")
        val artworkUrl = artworkArray.getJSONObject((artworkArray.length() - 1)).optString("url")
        val title = jsonObject.getJSONObject("videoDetails").optString("title")
        val author = jsonObject.getJSONObject("videoDetails").optString("author")
        val isLive = jsonObject.getJSONObject("videoDetails").optBoolean("isLive")
        if (isLive) {
            val dashUrl = jsonObject.getJSONObject("streamingData").optString("hlsManifestUrl")
            return arrayOf(dashUrl, "", artworkUrl, title, author, true)
        } else {
            var q2160p = String()
            var q1440p = String()
            var q1080p = String()
            var q720p = String()
            var q480p = String()
            var q360p = String()
            var q240p = String()
            var audioHigh = String()
            var audioMedium = String()
            var audioLow = String()
            val jsonArray = jsonObject.getJSONObject("streamingData").getJSONArray("adaptiveFormats")
            for (i in 0 until jsonArray.length()) {
                val mimeType = jsonArray.getJSONObject(i).optString("mimeType")
                val height = jsonArray.getJSONObject(i).optString("height")
                val quality = jsonArray.getJSONObject(i).optString("quality")
                val audioQuality = jsonArray.getJSONObject(i).optString("audioQuality")
                if (mimeType.contains("video/mp4") && height.contains("2160") || mimeType.contains("video/mp4") && quality.contains("hd2160")) {
                    q2160p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("1440") || mimeType.contains("video/mp4") && quality.contains("hd1440")) {
                    q1440p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("1080") || mimeType.contains("video/mp4") && quality.contains("hd1080")) {
                    q1080p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("720") || mimeType.contains("video/mp4") && quality.contains("hd720")) {
                    q720p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("480") || mimeType.contains("video/mp4") && quality.contains("480p")) {
                    q480p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("360") || mimeType.contains("video/mp4") && quality.contains("360p")) {
                    q360p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("video/mp4") && height.contains("240") || mimeType.contains("video/mp4") && quality.contains("240p")) {
                    q240p = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("audio/mp4") && audioQuality.contains("AUDIO_QUALITY_HIGH")) {
                    audioHigh = jsonArray.getJSONObject(i).optString("url")
                } else if (mimeType.contains("audio/mp4") && audioQuality.contains("AUDIO_QUALITY_MEDIUM")) {
                    audioMedium = jsonArray.getJSONObject(i).getString("url")
                } else if (mimeType.contains("audio/mp4") && audioQuality.contains("AUDIO_QUALITY_LOW")) {
                    audioLow = jsonArray.getJSONObject(i).optString("url")
                }
            }

            var videoUrl = String()
            if (q2160p != String()) {
                videoUrl = q2160p
            } else if (q1440p != String()) {
                videoUrl = q1440p
            } else if (q1080p != String()) {
                videoUrl = q1080p
            } else if (q720p != String()) {
                videoUrl = q720p
            } else if (q480p != String()) {
                videoUrl = q480p
            } else if (q360p != String()) {
                videoUrl = q360p
            } else if (q240p != String()) {
                videoUrl = q240p
            }

            var audioUrl = String()
            if (audioHigh != String()) {
                audioUrl = audioHigh
            } else if (audioMedium != String()) {
                audioUrl = audioMedium
            } else if (audioLow != String()) {
                audioUrl = audioLow
            }

            return arrayOf(videoUrl, audioUrl, artworkUrl, title, author, false)
        }
    }
}