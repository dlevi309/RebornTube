package h.lillie.reborntube

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.content.Context
import android.content.ClipboardManager
import androidx.appcompat.app.AppCompatActivity
import android.app.AlertDialog
import android.widget.LinearLayout
import okhttp3.*
import okhttp3.RequestBody.Companion.toRequestBody
import kotlinx.coroutines.*
import java.io.IOException
import org.json.JSONObject

class Main : AppCompatActivity() {

    private var hasRan = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && hasRan == 0) {
            hasRan = 1
            getClipboardInfo()
        }
    }

    private fun getClipboardInfo() {
        val clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clipboardInfo = clipboardManager.primaryClip?.getItemAt(0)?.text.toString()
        Log.d("Clipboard", clipboardInfo)
        val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
        val check = youtubeRegex.containsMatchIn(clipboardInfo)
        if (check) {
            val result = youtubeRegex.findAll(clipboardInfo).map { it.groupValues[1] }.joinToString()
            Log.d("YouTube ID", result)
            getVideoInfo(result)
        } else {
            val errorPopup = AlertDialog.Builder(this)
            errorPopup.setTitle("Error")
            errorPopup.setMessage("No YouTube video url found in clipboard, please close the app and copy a youtube video url to your clipboard before opening")
            errorPopup.setCancelable(false)
            errorPopup.show()
        }
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
            "videoId": "$clipboardInfo"}"""

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

                var videoUrl = ""
                var audioUrl = ""

                var q2160p = ""
                var q1440p = ""
                var q1080p = ""
                var q720p = ""
                var q480p = ""
                var q360p = ""
                var q240p = ""
                var audioHigh = ""
                var audioMedium = ""
                var audioLow = ""
                val jsonObject = JSONObject(responseBody)
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

                if (q2160p != "") {
                    videoUrl = q2160p
                } else if (q1440p != "") {
                    videoUrl = q1440p
                } else if (q1080p != "") {
                    videoUrl = q1080p
                } else if (q720p != "") {
                    videoUrl = q720p
                } else if (q480p != "") {
                    videoUrl = q480p
                } else if (q360p != "") {
                    videoUrl = q360p
                } else if (q240p != "") {
                    videoUrl = q240p
                }

                if (audioHigh != "") {
                    audioUrl = audioHigh
                } else if (audioMedium != "") {
                    audioUrl = audioMedium
                } else if (audioLow != "") {
                    audioUrl = audioLow
                }

                GlobalScope.launch(Dispatchers.IO) {
                    withContext(Dispatchers.Main) {
                        val intent = Intent(this@Main, Player::class.java)
                        intent.putExtra("videoUrl", videoUrl)
                        intent.putExtra("audioUrl", audioUrl)
                        startActivity(intent)
                    }
                }
            }
        })
    }
}