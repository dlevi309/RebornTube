package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.util.DisplayMetrics
import android.widget.RelativeLayout
import android.widget.Button
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.MediaItem.*
import com.google.android.exoplayer2.source.*
import com.google.android.exoplayer2.Player.*
import com.google.android.exoplayer2.upstream.*
import com.google.android.exoplayer2.ui.StyledPlayerView

class Player : AppCompatActivity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var exoPlayer: ExoPlayer
    private lateinit var playerView: StyledPlayerView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        getDeviceInfo()
        setupUI()
    }

    override fun onStart() {
        super.onStart()
        createPlayer()
    }

    override fun onStop() {
        super.onStop()
        exoPlayer.release()
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
        playerView = findViewById(R.id.playerView)
        playerView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Left Overlay
        var rewindButton: Button = findViewById(R.id.rewindButton)
        // rewindButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rewindButton.setOnClickListener {
            exoPlayer.seekBack()
        }

        // Middle Overlay
        var playButton: Button = findViewById(R.id.playButton)
        // playButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        // playButton.x = deviceWidth / 3.toFloat()
        playButton.setOnClickListener {
            val playbackState = exoPlayer.getPlayWhenReady()
            if (playbackState) {
                exoPlayer.pause()
            } else if (!playbackState) {
                exoPlayer.play()
            }
        }

        // Right Overlay
        var forwardButton: Button = findViewById(R.id.forwardButton)
        // forwardButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        // forwardButton.x = (deviceWidth / 3) * 2.toFloat()
        forwardButton.setOnClickListener {
            exoPlayer.seekForward()
        }
    }

    private fun createPlayer() {
        exoPlayer = ExoPlayer.Builder(this).build()
        playerView.visibility = View.VISIBLE
        // playerView.useController = false
        playerView.player = exoPlayer

        val videoUrl = intent.getStringExtra("videoUrl").toString()
        val audioUrl = intent.getStringExtra("audioUrl").toString()
        val videoUri: Uri = Uri.parse(videoUrl)
        val audioUri: Uri = Uri.parse(audioUrl)
        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
        val videoSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(videoUri))
        val audioSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(audioUri))
        val mergeSource: MediaSource = MergingMediaSource(videoSource, audioSource)

        exoPlayer.repeatMode = REPEAT_MODE_ONE
        exoPlayer.addMediaSource(mergeSource)
        exoPlayer.prepare()
        exoPlayer.playWhenReady = true
    }
}