package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.content.res.ColorStateList
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.Activity
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.view.View
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import android.content.res.Configuration
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.ui.PlayerView
import java.util.concurrent.TimeUnit
import com.google.common.util.concurrent.MoreExecutors
import com.google.android.material.slider.Slider
import com.pedromassango.doubleclick.DoubleClick
import com.pedromassango.doubleclick.DoubleClickListener
import java.io.IOException

class Player : Activity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var playerController: MediaController
    private lateinit var playerSliderHandler: Handler
    private lateinit var playerSlider: Slider

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        playerSliderHandler = Handler(Looper.getMainLooper())
        playerSlider = findViewById(R.id.playerSlider)
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
                createPlayerSlider()
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                getDeviceInfo()
                setupUI()
                createPlayerSlider()
            }
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        val videoOverlay: RelativeLayout = findViewById(R.id.videoOverlay)
        val videoSlider: RelativeLayout = findViewById(R.id.videoSlider)
        if (isInPictureInPictureMode) {
            videoOverlay.visibility = View.GONE
            videoSlider.visibility = View.GONE
        } else {
            videoOverlay.visibility = View.VISIBLE
            videoSlider.visibility = View.VISIBLE
        }
    }

    @SuppressLint("SwitchIntDef")
    private fun getDeviceInfo() {
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        when (resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
                playerSlider.visibility = View.VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
                playerSlider.visibility = View.GONE
            }
        }
    }

    private fun setupUI() {
        // Player
        val videoPlayer: RelativeLayout = findViewById(R.id.videoPlayer)
        videoPlayer.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

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

        val blackdimmed = applicationContext.getColor(R.color.blackdimmed)

        if (rewindButtonColorDrawable.color == blackdimmed && playButtonColorDrawable.color == blackdimmed && forwardButtonColorDrawable.color == blackdimmed) {
            rewindButton.setBackgroundColor(0x00000000)
            playButton.setBackgroundColor(0x00000000)
            forwardButton.setBackgroundColor(0x00000000)
            playPauseRestartButton.visibility = View.GONE
            val playerSliderActiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            val playerSliderInactiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.darkgrey))
            )
            playerSlider.trackActiveTintList = playerSliderActiveColourList
            playerSlider.trackInactiveTintList = playerSliderInactiveColourList
            playerSlider.thumbRadius = 0
            playerSlider.haloRadius = 0
        } else {
            rewindButton.setBackgroundColor(blackdimmed)
            playButton.setBackgroundColor(blackdimmed)
            forwardButton.setBackgroundColor(blackdimmed)
            playPauseRestartButton.visibility = View.VISIBLE
            val playerSliderActiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.red))
            )
            val playerSliderInactiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            playerSlider.trackActiveTintList = playerSliderActiveColourList
            playerSlider.trackInactiveTintList = playerSliderInactiveColourList
            playerSlider.thumbRadius = 15
            playerSlider.haloRadius = 15
        }
    }

    private fun createPlayer() {
        val playerView: PlayerView = findViewById(R.id.playerView)
        playerView.player = playerController
        setPictureInPictureParams(
            PictureInPictureParams.Builder()
                .setAutoEnterEnabled(true)
                .setSeamlessResizeEnabled(true)
                .build()
        )
    }

    private fun createPlayerSlider() {
        playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth + 64, 0)
        playerSlider.y = (deviceWidth * 9 / 16) - 64.toFloat()
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