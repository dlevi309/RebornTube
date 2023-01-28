package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.widget.VideoView
import android.widget.MediaController
import androidx.appcompat.app.AppCompatActivity
import h.lillie.reborntube.playerapi.PlayerApiRequest
import retrofit2.Retrofit
import retrofit2.awaitResponse
import retrofit2.converter.scalars.ScalarsConverterFactory
import retrofit2.converter.gson.GsonConverterFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class Main : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
        getInfo()
    }

    private fun getInfo(){
        val retrofit = Retrofit.Builder()
            .baseUrl("https://www.youtube.com")
            .addConverterFactory(ScalarsConverterFactory.create())
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(PlayerApiRequest::class.java)

        GlobalScope.launch(Dispatchers.IO) {
            var body = """{
                "context": {
                    "client": {
                        "hl": "en",
                        "gl": "US",
                        "clientName": "IOS",
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
                "videoId": "ytWz0qVvBZ0"
            }""".trimIndent()
            val response = retrofit.getPlayerApiValues(body).awaitResponse()
            if (response.isSuccessful) {
                val data = response.body()!!
                withContext(Dispatchers.Main) {
                    createPlayer(data.streamingData.hlsManifestUrl)
                }
            }
        }
    }

    private fun createPlayer(videoUrl: String) {
        val videoView: VideoView = findViewById(R.id.videoView)
        val uri: Uri = Uri.parse(videoUrl)
        videoView.setVideoURI(uri)

        val mediaController = MediaController(this)
        mediaController.setAnchorView(videoView)
        mediaController.setMediaPlayer(videoView)

        videoView.setMediaController(mediaController)
        videoView.requestFocus()
        videoView.start()
    }
}