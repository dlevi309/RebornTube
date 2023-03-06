package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.widget.RelativeLayout
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import org.videolan.libvlc.*
import org.videolan.libvlc.util.VLCVideoLayout

class VLCPlayer : AppCompatActivity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var libVlc: LibVLC
    private lateinit var mediaPlayer: MediaPlayer
    private lateinit var videoLayout: VLCVideoLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.vlcplayer)
        getDeviceInfo()
        setupUI()
    }

    override fun onStart() {
        super.onStart()
        createPlayer()
    }

    override fun onStop() {
        super.onStop()
        mediaPlayer.release()
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
            Configuration.ORIENTATION_SQUARE -> {}
            Configuration.ORIENTATION_UNDEFINED -> {}
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        this.enterPictureInPictureMode()
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
            Configuration.ORIENTATION_SQUARE -> {}
            Configuration.ORIENTATION_UNDEFINED -> {}
        }
    }

    private fun setupUI() {
        // Video Player
        videoLayout = findViewById(R.id.videoLayout)
        videoLayout.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)
    }

    private fun createPlayer() {
        libVlc = LibVLC(this)
        mediaPlayer = MediaPlayer(libVlc)
        videoLayout.visibility = View.VISIBLE

        val videoUrl = intent.getStringExtra("videoUrl").toString()
        val audioUrl = intent.getStringExtra("audioUrl").toString()
        val videoUri: Uri = Uri.parse(videoUrl)
        val audioUri: Uri = Uri.parse(audioUrl)

        mediaPlayer.attachViews(videoLayout, null, false, false)

        val media = Media(libVlc, videoUri)
        mediaPlayer.media = media
        media.release()
        mediaPlayer.play()
    }
}