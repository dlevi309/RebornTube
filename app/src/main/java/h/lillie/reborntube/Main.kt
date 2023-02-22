package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.widget.MediaController
import android.widget.VideoView
import android.widget.RelativeLayout
import android.content.Context
import android.content.ClipboardManager
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import okhttp3.*
import okhttp3.RequestBody.Companion.toRequestBody
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import org.json.JSONObject

class Main : AppCompatActivity() {

    private var hasRan = 0

    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasRan == 0) {
            hasRan = 1
            getDeviceInfo()
            setupUI()
            getClipboardInfo()
            // Toast.makeText(this, "test", Toast.LENGTH_SHORT).show()
        }
    }

    private fun getDeviceInfo() {
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        deviceHeight = displayMetrics.heightPixels
        deviceWidth = displayMetrics.widthPixels
    }

    private fun setupUI() {
        var videoView: VideoView = findViewById(R.id.videoView)
        videoView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)
    }

    private fun getClipboardInfo() {
        val clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clipboardInfo = clipboardManager.primaryClip?.getItemAt(0)?.text.toString()
        Log.d("Clipboard", clipboardInfo)
        val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
        val result = youtubeRegex.findAll(clipboardInfo).map { it.groupValues[1] }.joinToString()
        Log.d("YouTube ID", result)
        getVideoInfo(result)
    }

    private fun getVideoInfo(clipboardInfo: String) {
        val body = """{
            "context": {
                "client": {
                    "hl": "en",
                    "gl": "US",
                    "clientName": "ANDROID",
                    "clientVersion": "16.20",
                    "playbackContext": {
                        "contentPlaybackContext": {
                            "signatureTimestamp": "sts",
                            "html5Preference": "HTML5_PREF_WANTS"
                        }
                    }
                }
            },
            "contentCheckOk": true,
            "racyCheckOk": true,
            "videoId":
        """" + clipboardInfo + """"}"""

        val requestBody = body.trimIndent().toRequestBody()

        val client: OkHttpClient = OkHttpClient.Builder()
            .build()

        val request = Request.Builder()
            .method("POST", requestBody)
            .url("https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                Log.d("Failure", e.toString())
            }

            override fun onResponse(call: Call, response: Response) {
                val responseBody = response.body.string()
                response.body.close()
                response.close()

                var url = ""

                var q720p = ""
                var q480p = ""
                var q360p = ""
                var q240p = ""
                val jsonObject = JSONObject(responseBody)
                val jsonArray = jsonObject.getJSONObject("streamingData").getJSONArray("formats")
                for (i in 0 until jsonArray.length()) {
                    val mimeType = jsonArray.getJSONObject(i).getString("mimeType")
                    val height = jsonArray.getJSONObject(i).getString("height")
                    val quality = jsonArray.getJSONObject(i).getString("quality")
                    if (mimeType.contains("video/mp4") && height.contains("720") || mimeType.contains("video/mp4") && quality.contains("hd720")) {
                        q720p = jsonArray.getJSONObject(i).getString("url")
                    } else if (mimeType.contains("video/mp4") && height.contains("480") || mimeType.contains("video/mp4") && quality.contains("480p")) {
                        q480p = jsonArray.getJSONObject(i).getString("url")
                    } else if (mimeType.contains("video/mp4") && height.contains("360") || mimeType.contains("video/mp4") && quality.contains("360p")) {
                        q360p = jsonArray.getJSONObject(i).getString("url")
                    } else if (mimeType.contains("video/mp4") && height.contains("240") || mimeType.contains("video/mp4") && quality.contains("240p")) {
                        q240p = jsonArray.getJSONObject(i).getString("url")
                    }
                }

                if (q720p != null) {
                    url = q720p
                } else if (q480p != null) {
                    url = q480p
                } else if (q360p != null) {
                    url = q360p
                } else if (q240p != null) {
                    url = q240p
                }

                GlobalScope.launch(Dispatchers.IO) {
                    withContext(Dispatchers.Main) {
                        createPlayer(url)
                    }
                }
            }
        })
    }

    private fun createPlayer(videoUrl: String) {
        val videoView: VideoView = findViewById(R.id.videoView)
        val uri: Uri = Uri.parse(videoUrl)
        videoView.setVideoURI(uri)

        val mediaController = MediaController(this)
        mediaController.setAnchorView(videoView)
        mediaController.setMediaPlayer(videoView)

        videoView.setMediaController(mediaController)
        videoView.visibility = View.VISIBLE
        videoView.start()
    }
}