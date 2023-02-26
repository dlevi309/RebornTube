package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.widget.RelativeLayout
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import org.videolan.libvlc.*
import org.videolan.libvlc.util.VLCVideoLayout

class VLCPlayer : AppCompatActivity() {

    private var hasRan = 0
    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var libVlc: LibVLC
    private lateinit var mediaPlayer: MediaPlayer
    private lateinit var videoLayout: VLCVideoLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.vlcplayer)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasRan == 0) {
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
        videoLayout = findViewById(R.id.videoLayout)
        videoLayout.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)
    }

    private fun createPlayer(videoUrl: String) {
        libVlc = LibVLC(this)
        mediaPlayer = MediaPlayer(libVlc)
        videoLayout = findViewById(R.id.videoLayout)
        val uri: Uri = Uri.parse(videoUrl)

        mediaPlayer.attachViews(videoLayout, null, false, false)

        val media = Media(libVlc, uri)
        mediaPlayer.media = media
        media.release()
        videoLayout.visibility = View.VISIBLE
        mediaPlayer.play()
    }
}