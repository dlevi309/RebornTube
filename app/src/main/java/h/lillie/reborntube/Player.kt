package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.app.AlertDialog
import android.content.res.Configuration
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.ui.StyledPlayerView
import org.videolan.libvlc.*
import org.videolan.libvlc.util.VLCVideoLayout

class Player : AppCompatActivity() {

    private var hasRan = 0
    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var exoPlayer: ExoPlayer
    private lateinit var playerView: StyledPlayerView

    private lateinit var libVlc: LibVLC
    private lateinit var mediaPlayer: MediaPlayer
    private lateinit var videoLayout: VLCVideoLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasRan == 0) {
            hasRan = 1
            getDeviceInfo()
            setupUI()
            val url = intent.getStringExtra("url").toString()
            Log.d("Url", url)
            showPopup(url)
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        when (newConfig.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                Log.d("Orientation", "Portrait")
                getDeviceInfo()
                setupUI()
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                Log.d("Orientation", "Landscape")
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
                Log.d("Orientation", "Portrait")
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                Log.d("Orientation", "Landscape")
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
            }
        }
    }

    private fun setupUI() {
        playerView = findViewById(R.id.playerView)
        playerView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        videoLayout = findViewById(R.id.videoLayout)
        videoLayout.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)
    }

    private fun showPopup(videoUrl: String) {
        val playerPopup = AlertDialog.Builder(this).create()
        playerPopup.setTitle("Player")
        playerPopup.setButton(AlertDialog.BUTTON_POSITIVE, "Exo Player (Recommended)") { dialog, which ->
            createExoPlayer(videoUrl)
        }
        playerPopup.setButton(AlertDialog.BUTTON_NEGATIVE, "VLC Player (Experimental)") { dialog, which ->
            createVlcPlayer(videoUrl)
        }
        playerPopup.show()

        val positiveButton = playerPopup.getButton(AlertDialog.BUTTON_POSITIVE)
        val negativeButton = playerPopup.getButton(AlertDialog.BUTTON_NEGATIVE)
        val layoutParams = positiveButton.layoutParams as LinearLayout.LayoutParams
        layoutParams.weight = 10f
        positiveButton.layoutParams = layoutParams
        negativeButton.layoutParams = layoutParams
    }

    private fun createExoPlayer(videoUrl: String) {
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

    private fun createVlcPlayer(videoUrl: String) {
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