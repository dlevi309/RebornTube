package h.lillie.reborntube

import org.json.JSONObject

class Loader {
    fun playerInit(json: String) : Array<Any> {
        val jsonObject = JSONObject(json)

        val artworkArray = jsonObject.getJSONObject("videoDetails").getJSONObject("thumbnail").getJSONArray("thumbnails")
        val artworkUrl = artworkArray.getJSONObject((artworkArray.length() - 1)).optString("url")
        val videoID = jsonObject.getJSONObject("videoDetails").optString("videoId")
        val title = jsonObject.getJSONObject("videoDetails").optString("title")
        val author = jsonObject.getJSONObject("videoDetails").optString("author")
        val viewCount = jsonObject.getJSONObject("videoDetails").optString("viewCount")
        val isLive = jsonObject.getJSONObject("videoDetails").optBoolean("isLive")
        val hlsUrl = jsonObject.getJSONObject("streamingData").optString("hlsManifestUrl")
        if (isLive) {
            return arrayOf(videoID, hlsUrl, artworkUrl, title, author, viewCount, true)
        } else {
            return arrayOf(videoID, hlsUrl, artworkUrl, title, author, viewCount, false)
        }
    }

    fun dislikesInit(json: String) : Array<Any> {
        val jsonObject = JSONObject(json)

        val likes = jsonObject.optInt("likes")
        val dislikes = jsonObject.optInt("dislikes")

        return arrayOf(likes, dislikes)
    }
}