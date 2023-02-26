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
                        showPopup(url)
                    }
                }
            }
        })
    }

    private fun showPopup(videoUrl: String) {
        val playerPopup = AlertDialog.Builder(this).create()
        playerPopup.setTitle("Player")
        playerPopup.setButton(AlertDialog.BUTTON_POSITIVE, "Exo Player (Recommended)") { dialog, which ->
            val intent = Intent(this@Main, Player::class.java)
            intent.putExtra("url", videoUrl)
            startActivity(intent)
        }
        playerPopup.setButton(AlertDialog.BUTTON_NEGATIVE, "VLC Player (Experimental)") { dialog, which ->
            val intent = Intent(this@Main, VLCPlayer::class.java)
            intent.putExtra("url", videoUrl)
            startActivity(intent)
        }
        playerPopup.show()

        val positiveButton = playerPopup.getButton(AlertDialog.BUTTON_POSITIVE)
        val negativeButton = playerPopup.getButton(AlertDialog.BUTTON_NEGATIVE)
        val layoutParams = positiveButton.layoutParams as LinearLayout.LayoutParams
        layoutParams.weight = 10f
        positiveButton.layoutParams = layoutParams
        negativeButton.layoutParams = layoutParams
    }
}