package h.lillie.reborntube

import android.content.Context
import com.google.gson.Gson
import org.json.JSONObject

class Loader {
    fun playerInit(context: Context, urlID: String?) {
        val extractor = Extractor()
        val playerRequest = extractor.playerRequest(context, urlID)
        val dislikesRequest = extractor.returnYouTubeDislikesRequest(urlID)
        val sponsorBlockRequest = extractor.sponsorBlockRequest(urlID)

        val playerObject = JSONObject(playerRequest)
        val dislikesObject = JSONObject(dislikesRequest)

        val artworkArray = playerObject.getJSONObject("videoDetails").getJSONObject("thumbnail").getJSONArray("thumbnails")
        val artworkUrl = artworkArray.getJSONObject((artworkArray.length() - 1)).optString("url").toString()
        val videoID = playerObject.getJSONObject("videoDetails").optString("videoId").toString()
        val title = playerObject.getJSONObject("videoDetails").optString("title").toString()
        val author = playerObject.getJSONObject("videoDetails").optString("author").toString()
        val viewCount = playerObject.getJSONObject("videoDetails").optString("viewCount").toString()
        val isLive = playerObject.getJSONObject("videoDetails").optBoolean("isLive")
        val hlsUrl = playerObject.getJSONObject("streamingData").optString("hlsManifestUrl").toString()

        val likes = dislikesObject.optInt("likes")
        val dislikes = dislikesObject.optInt("dislikes")

        var live: Boolean = false
        if (isLive) {
            live = true
        }

        val gson = Gson()
        Application.setVideoData(gson.toJson(VideoData(
            videoID,
            hlsUrl,
            sponsorBlockRequest,
            artworkUrl,
            title,
            author,
            viewCount,
            live.toString().toBoolean(),
            likes.toString(),
            dislikes.toString()
        )))
    }
}