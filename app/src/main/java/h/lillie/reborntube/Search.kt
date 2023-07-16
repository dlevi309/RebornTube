package h.lillie.reborntube

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.RelativeLayout
import android.view.View
import android.view.ViewGroup
import com.google.gson.Gson
import org.json.JSONObject

class Search : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.search)
        getDeviceInfo()
        val searchLayout: RelativeLayout = findViewById(R.id.searchLayout)
        if (deviceType == true) {
            val params = searchLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            searchLayout.layoutParams = params
        }

        val searchBar: EditText = findViewById(R.id.searchBar)
        val searchBarButton: Button = findViewById(R.id.searchBarButton)
        searchBarButton.setOnClickListener {
            val extractor = Extractor()
            val searchRequest = extractor.searchRequest(applicationContext, searchBar.text.toString())
            val jsonObject = JSONObject(searchRequest)

            val videoID: String = jsonObject.getJSONObject("contents").getJSONObject("twoColumnSearchResultsRenderer").getJSONObject("primaryContents").getJSONObject("sectionListRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoRenderer").optString("videoId").toString()
            val videoTitle: String = jsonObject.getJSONObject("contents").getJSONObject("twoColumnSearchResultsRenderer").getJSONObject("primaryContents").getJSONObject("sectionListRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoRenderer").getJSONObject("title").getJSONArray("runs").getJSONObject(0).optString("text").toString()

            val videoView = View(applicationContext)
            videoView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 156)
            videoView.y = 160f
            videoView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

            val videoTitleTextView = TextView(applicationContext)
            videoTitleTextView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 156)
            videoTitleTextView.y = 160f
            videoTitleTextView.text = videoTitle

            val videoButton = View(applicationContext)
            videoButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 156)
            videoButton.y = 160f
            videoButton.isFocusable = true
            videoButton.isFocusableInTouchMode = true
            videoButton.requestFocus()
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

            searchLayout.addView(videoView)
            searchLayout.addView(videoTitleTextView)
            searchLayout.addView(videoButton)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        finish()
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}