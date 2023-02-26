package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.widget.RelativeLayout
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.ui.StyledPlayerView

class Player : AppCompatActivity() {

    private var hasRan = 0
    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var exoPlayer: ExoPlayer
    private lateinit var playerView: StyledPlayerView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && hasRan == 0) {
            hasRan = 1
            getDeviceInfo()
            setupUI()
            val url = intent.getStringExtra("url").toString()
            createPlayer(url)
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        when (newConfig.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                getDeviceInfo()
                setupUI()
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                getDeviceInfo()
                setupUI()
            }
        }
    }

    private fun getDeviceInfo() {
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        deviceHeight = displayMetrics.heightPixels
        deviceWidth = displayMetrics.widthPixels
        val orientation = getResources().getConfiguration().orientation
        when (orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
            }
        }
    }

    private fun setupUI() {
        playerView = findViewById(R.id.playerView)
        playerView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)
    }

    private fun createPlayer(videoUrl: String) {
        exoPlayer = ExoPlayer.Builder(this).build()
        playerView = findViewById(R.id.playerView)
        playerView.visibility = View.VISIBLE
        val uri: Uri = Uri.parse(videoUrl)

        val mediaItem: MediaItem = MediaItem.fromUri(uri)
        exoPlayer.setMediaItem(mediaItem)
        playerView.player = exoPlayer

        exoPlayer.prepare()
        exoPlayer.playWhenReady = true
    }
}