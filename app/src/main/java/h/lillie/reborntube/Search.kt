package h.lillie.reborntube

import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.widget.EditText
import android.widget.RelativeLayout
import android.widget.LinearLayout
import android.view.View
import android.view.ViewGroup
import android.view.KeyEvent
import android.view.inputmethod.InputMethodManager
import com.google.gson.Gson
import h.lillie.reborntube.views.VideoView
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException

class Search : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.search)
        getDeviceInfo()
        if (deviceType) {
            val searchLayout: RelativeLayout = findViewById(R.id.searchLayout)
            val params = searchLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            searchLayout.layoutParams = params
        }

        val searchScrollView: LinearLayout = findViewById(R.id.searchScrollLayout)

        val searchBar: EditText = findViewById(R.id.searchBar)
        searchBar.setOnKeyListener(View.OnKeyListener { _, keyCode, _ ->
            if (keyCode == KeyEvent.KEYCODE_ENTER) {
                val inputMethodManager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputMethodManager.hideSoftInputFromWindow(searchBar.windowToken, 0)
                searchScrollView.removeAllViews()
                val extractor = Extractor()

                val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/|shorts\\/|live\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
                if (youtubeRegex.containsMatchIn(searchBar.text)) {
                    val result = youtubeRegex.findAll(searchBar.text).map { it.groupValues[1] }.joinToString()
                    val playerRequest = extractor.playerRequest(applicationContext, result)
                    val jsonObject = JSONObject(playerRequest)

                    val videoID: String = jsonObject.getJSONObject("videoDetails").optString("videoId").toString()
                    val videoTitle: String = jsonObject.getJSONObject("videoDetails").optString("title").toString()
                    val videoArtworkArray = jsonObject.getJSONObject("videoDetails").getJSONObject("thumbnail").getJSONArray("thumbnails")
                    val videoArtworkUrl: String = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url")
                    val videoAuthor: String = jsonObject.getJSONObject("videoDetails").optString("author").toString()
                    val videoTimeLength: Int = jsonObject.getJSONObject("videoDetails").optString("lengthSeconds").toString().toInt()
                    val videoTime: String = String.format("%02d:%02d:%02d", videoTimeLength / 3600, (videoTimeLength % 3600) / 60, videoTimeLength % 60)
                    val videoViewCount: Double = jsonObject.getJSONObject("videoDetails").optString("viewCount").toString().toDouble()

                    val gson = Gson()
                    val videoViewInfo: String = gson.toJson(VideoViewData(
                        videoID,
                        videoTitle,
                        videoArtworkUrl,
                        videoAuthor,
                        videoTime,
                        videoViewCount,
                        null
                    ))
                    val videoView = VideoView()
                    videoView.addView(this@Search, applicationContext, videoViewInfo, searchScrollView, deviceType, deviceWidth)
                } else {
                    val searchRequest = extractor.searchRequest(applicationContext, searchBar.text.toString())
                    val jsonObject = JSONObject(searchRequest)

                    val searchContents: JSONArray = jsonObject.getJSONObject("contents").getJSONObject("twoColumnSearchResultsRenderer").getJSONObject("primaryContents").getJSONObject("sectionListRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("itemSectionRenderer").getJSONArray("contents")

                    for (i in 0 until searchContents.length()) {
                        try {
                            val videoID: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").optString("videoId").toString()
                            val videoTitle: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("title").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                            val videoArtworkArray = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("thumbnail").getJSONArray("thumbnails")
                            val videoArtworkUrl: String = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url").toString()
                            val videoAuthor: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("longBylineText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                            val videoTime: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("lengthText").optString("simpleText").toString()
                            var videoViewCount = String()
                            if (searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").optString("simpleText").toString() != null) {
                                videoViewCount = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").optString("simpleText").toString()
                            } else if (searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").length() >= 1) {
                                videoViewCount = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").getJSONObject(0).optString("text").toString() + searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").getJSONObject(1).optString("text").toString()
                            }

                            val gson = Gson()
                            val videoViewInfo: String = gson.toJson(VideoViewData(
                                videoID,
                                videoTitle,
                                videoArtworkUrl,
                                videoAuthor,
                                videoTime,
                                null,
                                videoViewCount
                            ))
                            val videoView = VideoView()
                            videoView.addView(this@Search, applicationContext, videoViewInfo, searchScrollView, deviceType, deviceWidth)
                        } catch (e: IOException) {
                            Log.e("IOException", e.toString())
                        } catch (e: JSONException) {
                            Log.e("JSONException", e.toString())
                        }
                    }
                }
                return@OnKeyListener true
            }
            return@OnKeyListener false
        })
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}