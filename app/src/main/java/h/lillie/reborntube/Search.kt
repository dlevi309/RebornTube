package h.lillie.reborntube

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.RelativeLayout
import android.widget.LinearLayout
import android.widget.Space
import android.view.View
import android.view.ViewGroup
import android.view.Gravity
import com.google.gson.Gson
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
        if (deviceType == true) {
            val searchLayout: RelativeLayout = findViewById(R.id.searchLayout)
            val params = searchLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            searchLayout.layoutParams = params
        }

        val searchScrollView: LinearLayout = findViewById(R.id.searchScrollLayout)

        val searchBar: EditText = findViewById(R.id.searchBar)
        val searchBarButton: Button = findViewById(R.id.searchBarButton)
        searchBarButton.setOnClickListener {
            searchScrollView.removeAllViews()
            val extractor = Extractor()

            val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/|shorts\\/|live\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
            if (youtubeRegex.containsMatchIn(searchBar.text)) {
                val result = youtubeRegex.findAll(searchBar.text).map { it.groupValues[1] }.joinToString()
                val playerRequest = extractor.playerRequest(applicationContext, result)
                val jsonObject = JSONObject(playerRequest)

                val searchRelativeView = RelativeLayout(applicationContext)
                searchRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 156)
                searchRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

                val videoID: String = jsonObject.getJSONObject("videoDetails").optString("videoId").toString()
                val videoTitle: String = jsonObject.getJSONObject("videoDetails").optString("title").toString()

                val videoTitleTextView = TextView(applicationContext)
                videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth, 156)
                videoTitleTextView.text = videoTitle
                videoTitleTextView.gravity = Gravity.CENTER_VERTICAL
                videoTitleTextView.setTextColor(applicationContext.getColor(R.color.white))

                val videoButton = View(applicationContext)
                videoButton.layoutParams = LinearLayout.LayoutParams(deviceWidth, 156)
                videoButton.setOnClickListener {
                    val dislikesRequest = extractor.returnYouTubeDislikesRequest(videoID)
                    val sponsorBlockRequest = extractor.sponsorBlockRequest(videoID)

                    val loader = Loader()
                    val loaderPlayerInfo = loader.playerInit(playerRequest)
                    val loaderDislikesInfo = loader.dislikesInit(dislikesRequest)

                    val gson = Gson()
                    Application.setVideoData(gson.toJson(Data(
                        loaderPlayerInfo[0].toString(),
                        loaderPlayerInfo[1].toString(),
                        sponsorBlockRequest,
                        loaderPlayerInfo[2].toString(),
                        loaderPlayerInfo[3].toString(),
                        loaderPlayerInfo[4].toString(),
                        loaderPlayerInfo[5].toString(),
                        loaderPlayerInfo[6].toString().toBoolean(),
                        loaderDislikesInfo[0].toString(),
                        loaderDislikesInfo[1].toString()
                    )))

                    val intent = Intent(this@Search, Player::class.java)
                    startActivity(intent)
                }
                searchRelativeView.addView(videoTitleTextView)
                searchRelativeView.addView(videoButton)

                val spaceView = Space(applicationContext)
                spaceView.minimumHeight = 4
                searchScrollView.addView(spaceView)
                searchScrollView.addView(searchRelativeView)
            } else {
                val searchRequest = extractor.searchRequest(applicationContext, searchBar.text.toString())
                val jsonObject = JSONObject(searchRequest)

                val searchContents: JSONArray = jsonObject.getJSONObject("contents").getJSONObject("twoColumnSearchResultsRenderer").getJSONObject("primaryContents").getJSONObject("sectionListRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("itemSectionRenderer").getJSONArray("contents")

                var x = 0
                for (i in 0 until searchContents.length()) {
                    try {
                        val searchRelativeView = RelativeLayout(applicationContext)
                        searchRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 156)
                        searchRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

                        val videoID: String = searchContents.getJSONObject(x).getJSONObject("videoRenderer").optString("videoId").toString()
                        val videoTitle: String = searchContents.getJSONObject(x).getJSONObject("videoRenderer").getJSONObject("title").getJSONArray("runs").getJSONObject(0).optString("text").toString()

                        val videoTitleTextView = TextView(applicationContext)
                        videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth, 156)
                        videoTitleTextView.text = videoTitle
                        videoTitleTextView.gravity = Gravity.CENTER_VERTICAL
                        videoTitleTextView.setTextColor(applicationContext.getColor(R.color.white))

                        val videoButton = View(applicationContext)
                        videoButton.layoutParams = LinearLayout.LayoutParams(deviceWidth, 156)
                        videoButton.setOnClickListener {
                            val playerRequest = extractor.playerRequest(applicationContext, videoID)
                            val dislikesRequest = extractor.returnYouTubeDislikesRequest(videoID)
                            val sponsorBlockRequest = extractor.sponsorBlockRequest(videoID)

                            val loader = Loader()
                            val loaderPlayerInfo = loader.playerInit(playerRequest)
                            val loaderDislikesInfo = loader.dislikesInit(dislikesRequest)

                            val gson = Gson()
                            Application.setVideoData(gson.toJson(Data(
                                loaderPlayerInfo[0].toString(),
                                loaderPlayerInfo[1].toString(),
                                sponsorBlockRequest,
                                loaderPlayerInfo[2].toString(),
                                loaderPlayerInfo[3].toString(),
                                loaderPlayerInfo[4].toString(),
                                loaderPlayerInfo[5].toString(),
                                loaderPlayerInfo[6].toString().toBoolean(),
                                loaderDislikesInfo[0].toString(),
                                loaderDislikesInfo[1].toString()
                            )))

                            val intent = Intent(this@Search, Player::class.java)
                            startActivity(intent)
                        }
                        searchRelativeView.addView(videoTitleTextView)
                        searchRelativeView.addView(videoButton)

                        val spaceView = Space(applicationContext)
                        spaceView.minimumHeight = 4
                        searchScrollView.addView(spaceView)
                        searchScrollView.addView(searchRelativeView)
                    } catch (e: IOException) {
                        Log.e("IOException", e.toString())
                    } catch (e: JSONException) {
                        Log.e("JSONException", e.toString())
                    }
                    x += 1
                }
            }
        }
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}