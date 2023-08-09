package h.lillie.reborntube.fragments

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import android.widget.LinearLayout
import android.view.View
import android.view.ViewGroup
import android.view.LayoutInflater
import com.google.gson.Gson
import h.lillie.reborntube.Extractor
import h.lillie.reborntube.R
import h.lillie.reborntube.views.VideoView
import h.lillie.reborntube.VideoViewData
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException

class Home(private val appCompatActivity: AppCompatActivity) : Fragment() {
    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view: View = inflater.inflate(R.layout.home, container, false)

        getDeviceInfo()

        val applicationContext = activity?.applicationContext
        if (applicationContext != null) {
            val homeScrollView: LinearLayout = view.findViewById(R.id.homeScrollLayout)
            homeScrollView.removeAllViews()

            val extractor = Extractor()
            val browseRequest = extractor.browseRequest(applicationContext, "FEtrending", null)
            val jsonObject = JSONObject(browseRequest)

            val browseContents: JSONArray = jsonObject.getJSONObject("contents").getJSONObject("singleColumnBrowseResultsRenderer").getJSONArray("tabs").getJSONObject(0).getJSONObject("tabRenderer").getJSONObject("content").getJSONObject("sectionListRenderer").getJSONArray("contents")

            for (i in 0 until browseContents.length()) {
                try {
                    val videoID: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("navigationEndpoint").getJSONObject("watchEndpoint").optString("videoId").toString()
                    val videoTitle: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("headline").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoArtworkArray = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("thumbnail").getJSONArray("thumbnails")
                    val videoArtworkUrl: String = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url").toString()
                    val videoAuthor: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("shortBylineText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoTime: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("lengthText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoViewCount = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("shortViewCountText").getJSONArray("runs").getJSONObject(0).optString("text").toString()

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
                    videoView.addView(appCompatActivity, applicationContext, videoViewInfo, homeScrollView, deviceType, deviceWidth)
                } catch (e: IOException) {
                    Log.e("IOException", e.toString())
                } catch (e: JSONException) {
                    Log.e("JSONException", e.toString())
                }
            }
            if (deviceType) {
                homeScrollView.requestFocus()
            }
        }

        return view
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        val packageManager = context?.packageManager
        val windowManager = activity?.windowManager
        if (packageManager != null) {
            deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        }
        if (windowManager != null) {
            deviceHeight = windowManager.currentWindowMetrics.bounds.height()
            deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        }
    }
}