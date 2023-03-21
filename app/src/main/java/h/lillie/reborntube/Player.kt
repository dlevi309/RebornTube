package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.view.View
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.ui.PlayerView
import com.google.android.material.slider.LabelFormatter
import java.util.concurrent.TimeUnit
import com.google.common.util.concurrent.MoreExecutors
import com.google.android.material.slider.Slider
import com.pedromassango.doubleclick.DoubleClick
import com.pedromassango.doubleclick.DoubleClickListener
import java.io.IOException

class Player : AppCompatActivity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var playerView: PlayerView
    private lateinit var playerController: MediaController
    private lateinit var playerSlider: Slider
    private lateinit var playerSliderHandler: Handler

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        playerSliderHandler = Handler(Looper.getMainLooper())
        getDeviceInfo()
        setupUI()
        val sessionToken = SessionToken(this, ComponentName(this, PlayerService::class.java))
        val controllerFuture = MediaController.Builder(this, sessionToken).buildAsync()
        controllerFuture.addListener(
            {
                playerController = controllerFuture.get()
                createPlayer()
                createPlayerSlider()
            },
            MoreExecutors.directExecutor()
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(Intent(this, PlayerService::class.java))
    }

    @SuppressLint("SwitchIntDef")
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        when (newConfig.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                getDeviceInfo()
                setupUI()
                playerSlider.visibility = View.VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                getDeviceInfo()
                setupUI()
                playerSlider.visibility = View.GONE
            }
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            val videoOverlay: RelativeLayout = findViewById(R.id.videoOverlay)
            videoOverlay.visibility = View.GONE
        } else {
            val videoOverlay: RelativeLayout = findViewById(R.id.videoOverlay)
            videoOverlay.visibility = View.VISIBLE
        }
    }

    @SuppressLint("SwitchIntDef")
    private fun getDeviceInfo() {
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        when (resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
            }
        }
    }

    private fun setupUI() {
        // Player
        val videoRelativeLayout: RelativeLayout = findViewById(R.id.videoRelativeLayout)
        videoRelativeLayout.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Overlay
        val rewindButton: Button = findViewById(R.id.rewindButton)
        rewindButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rewindButton.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay()
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition - TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playButton: Button = findViewById(R.id.playButton)
        playButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        playButton.x = deviceWidth / 3.toFloat()
        playButton.setOnClickListener {
            changeOverlay()
        }

        val forwardButton: Button = findViewById(R.id.forwardButton)
        forwardButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        forwardButton.x = (deviceWidth / 3) * 2.toFloat()
        forwardButton.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay()
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition + TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        playPauseRestartButton.layoutParams = RelativeLayout.LayoutParams(96, 96)
        playPauseRestartButton.x = (deviceWidth / 2) - 48.toFloat()
        playPauseRestartButton.y = ((deviceWidth * 9 / 16) / 2) - 48.toFloat()
        playPauseRestartButton.setOnClickListener {
            if (playerController.playWhenReady) {
                playerController.pause()
            } else if (!playerController.playWhenReady) {
                playerController.play()
            }
        }
    }

    private fun changeOverlay() {
        val rewindButton: Button = findViewById(R.id.rewindButton)
        val playButton: Button = findViewById(R.id.playButton)
        val forwardButton: Button = findViewById(R.id.forwardButton)
        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)

        val rewindButtonDrawable: Drawable = rewindButton.background
        val rewindButtonColorDrawable: ColorDrawable = rewindButtonDrawable as ColorDrawable
        val playButtonDrawable: Drawable = playButton.background
        val playButtonColorDrawable: ColorDrawable = playButtonDrawable as ColorDrawable
        val forwardButtonDrawable: Drawable = forwardButton.background
        val forwardButtonColorDrawable: ColorDrawable = forwardButtonDrawable as ColorDrawable

        if (rewindButtonColorDrawable.color.toString() == "1073741824" && playButtonColorDrawable.color.toString() == "1073741824" && forwardButtonColorDrawable.color.toString() == "1073741824") {
            rewindButton.setBackgroundColor(0x00000000)
            playButton.setBackgroundColor(0x00000000)
            forwardButton.setBackgroundColor(0x00000000)
            playPauseRestartButton.visibility = View.GONE
        } else {
            rewindButton.setBackgroundColor(0x40000000)
            playButton.setBackgroundColor(0x40000000)
            forwardButton.setBackgroundColor(0x40000000)
            playPauseRestartButton.visibility = View.VISIBLE
        }
    }

    private fun createPlayer() {
        playerView = findViewById(R.id.playerView)
        playerView.visibility = View.VISIBLE
        playerView.useController = false
        playerView.player = playerController
        setPictureInPictureParams(
            PictureInPictureParams.Builder()
                .setAutoEnterEnabled(true)
                .setSeamlessResizeEnabled(true)
                .build()
        )
    }

    private fun createPlayerSlider() {
        playerSlider = findViewById(R.id.playerSlider)
        playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 0)
        playerSlider.y = deviceWidth * 9 / 16.toFloat()
        playerSlider.labelBehavior = LabelFormatter.LABEL_GONE
        playerSlider.valueFrom = 0.toFloat()
        playerSlider.addOnChangeListener { _, value, fromUser ->
            val duration = playerController.duration.toFloat()
            val position = playerController.currentPosition.toFloat()
            if (fromUser && duration >= 0 && position >= 0) {
                playerController.seekTo(value.toLong())
            }
        }
        playerSliderHandler.post(playerSliderTask)
    }

    private val playerSliderTask = object : Runnable {
        override fun run() {
            try {
                val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
                if (playerController.playWhenReady) {
                    playPauseRestartButton.setImageResource(R.drawable.pause)
                } else if (!playerController.playWhenReady) {
                    playPauseRestartButton.setImageResource(R.drawable.play)
                }

                val duration = playerController.duration.toFloat()
                val position = playerController.currentPosition.toFloat()
                if (duration >= 0 && position >= 0) {
                    playerSlider.valueTo = duration
                    playerSlider.value = position
                }
            } catch (e: IOException) {
                Log.e("IOException", e.toString())
            }
            playerSliderHandler.postDelayed(this, 1000)
        }
    }
}