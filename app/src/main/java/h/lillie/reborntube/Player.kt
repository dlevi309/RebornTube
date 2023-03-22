package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.Activity
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.widget.TextView
import android.view.View
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
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
    private var overlayVisible = 0

    private lateinit var playerController: MediaController
    private lateinit var playerHandler: Handler
    private lateinit var playerSlider: Slider

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        playerHandler = Handler(Looper.getMainLooper())
        playerSlider = findViewById(R.id.playerSlider)
        getDeviceInfo()
        val sessionToken = SessionToken(this, ComponentName(this, PlayerService::class.java))
        val controllerFuture = MediaController.Builder(this, sessionToken).buildAsync()
        controllerFuture.addListener(
            {
                playerController = controllerFuture.get()
                createPlayer()
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
            Configuration.ORIENTATION_PORTRAIT -> getDeviceInfo()
            Configuration.ORIENTATION_LANDSCAPE -> getDeviceInfo()
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        val videoOverlay: RelativeLayout = findViewById(R.id.videoOverlay)
        val videoSlider: RelativeLayout = findViewById(R.id.videoSlider)
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        if (isInPictureInPictureMode) {
            videoOverlay.visibility = View.GONE
            videoSlider.visibility = View.GONE
            videoInfo.visibility = View.GONE
        } else {
            videoOverlay.visibility = View.VISIBLE
            videoSlider.visibility = View.VISIBLE
            videoInfo.visibility = View.VISIBLE
        }
    }

    @SuppressLint("SwitchIntDef")
    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        when (resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
                createUI(0)
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
                createUI(1)
            }
        }
    }

    private fun createUI(orientation: Int) {
        // Player
        val videoPlayer: RelativeLayout = findViewById(R.id.videoPlayer)
        videoPlayer.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Overlay
        val rewindButton: Button = findViewById(R.id.rewindButton)
        rewindButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rewindButton.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition - TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playButton: Button = findViewById(R.id.playButton)
        playButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        playButton.x = deviceWidth / 3.toFloat()
        playButton.setOnClickListener {
            changeOverlay(orientation)
        }

        val forwardButton: Button = findViewById(R.id.forwardButton)
        forwardButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        forwardButton.x = (deviceWidth / 3) * 2.toFloat()
        forwardButton.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition + TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        playPauseRestartButton.layoutParams = RelativeLayout.LayoutParams(108, 108)
        playPauseRestartButton.x = (deviceWidth / 2) - 54.toFloat()
        if (orientation == 0) {
            playPauseRestartButton.y = ((deviceWidth * 9 / 16) / 2) - 54.toFloat()
        } else if (orientation == 1) {
            playPauseRestartButton.y = (deviceHeight / 2) - 54.toFloat()
        }
        playPauseRestartButton.setOnClickListener {
            if (playerController.playWhenReady) {
                playerController.pause()
            } else if (!playerController.playWhenReady) {
                playerController.play()
            }
        }

        // Slider
        playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth + 64, 0)
        if (orientation == 0) {
            playerSlider.y = (deviceWidth * 9 / 16) - 64.toFloat()
            playerSlider.visibility = View.VISIBLE
        } else if (orientation == 1) {
            playerSlider.y = deviceHeight - 256.toFloat()
            if (overlayVisible == 0) {
                playerSlider.visibility = View.GONE
            } else if (overlayVisible == 1) {
                playerSlider.visibility = View.VISIBLE
            }
        }
        playerSlider.addOnChangeListener { _, value, fromUser ->
            val duration = playerController.duration.toFloat()
            val position = playerController.currentPosition.toFloat()
            if (fromUser && duration >= 0 && position >= 0) {
                playerController.seekTo(value.toLong())
            }
        }

        // Title
        val videoTitle: TextView = findViewById(R.id.videoTitle)
        val title = Application.getTitle()
        videoTitle.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 50)
        if (orientation == 0) {
            videoTitle.y = (deviceWidth * 9 / 16) + 64.toFloat()
            videoTitle.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoTitle.y = 50.toFloat()
            if (overlayVisible == 0) {
                videoTitle.visibility = View.GONE
            } else if (overlayVisible == 1) {
                videoTitle.visibility = View.VISIBLE
            }
        }
        videoTitle.text = title

        // Info
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        if (orientation == 0) {
            videoInfo.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoInfo.visibility = View.GONE
        }

        val videoCountLikesDislikes: TextView = findViewById(R.id.videoCountLikesDislikes)
        videoCountLikesDislikes.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
        videoCountLikesDislikes.y = (deviceWidth * 9 / 16) + 144.toFloat()
        val viewCount = Application.getViewCount().toDouble()
        val likes = Application.getLikes().toDouble()
        val dislikes = Application.getDislikes().toDouble()
        val info = "View Count: %,.0f\nLikes: %,.0f\nDislikes: %,.0f".format(viewCount, likes, dislikes)
        videoCountLikesDislikes.text = info
    }

    private fun changeOverlay(orientation: Int) {
        val rewindButton: Button = findViewById(R.id.rewindButton)
        val playButton: Button = findViewById(R.id.playButton)
        val forwardButton: Button = findViewById(R.id.forwardButton)
        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        val videoTitle: TextView = findViewById(R.id.videoTitle)

        val rewindButtonDrawable: Drawable = rewindButton.background
        val rewindButtonColorDrawable: ColorDrawable = rewindButtonDrawable as ColorDrawable
        val playButtonDrawable: Drawable = playButton.background
        val playButtonColorDrawable: ColorDrawable = playButtonDrawable as ColorDrawable
        val forwardButtonDrawable: Drawable = forwardButton.background
        val forwardButtonColorDrawable: ColorDrawable = forwardButtonDrawable as ColorDrawable

        val blackDimmed = applicationContext.getColor(R.color.blackdimmed)

        if (rewindButtonColorDrawable.color == blackDimmed && playButtonColorDrawable.color == blackDimmed && forwardButtonColorDrawable.color == blackDimmed) {
            overlayVisible = 0
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
            if (orientation == 0) {
                videoTitle.visibility = View.VISIBLE
                playerSlider.visibility = View.VISIBLE
            } else if (orientation == 1) {
                videoTitle.visibility = View.GONE
                playerSlider.visibility = View.GONE
            }
            playerSlider.trackActiveTintList = playerSliderActiveColourList
            playerSlider.trackInactiveTintList = playerSliderInactiveColourList
            playerSlider.thumbRadius = 0
            playerSlider.haloRadius = 0
        } else {
            overlayVisible = 1
            rewindButton.setBackgroundColor(blackDimmed)
            playButton.setBackgroundColor(blackDimmed)
            forwardButton.setBackgroundColor(blackDimmed)
            playPauseRestartButton.visibility = View.VISIBLE
            val playerSliderActiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.red))
            )
            val playerSliderInactiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            videoTitle.visibility = View.VISIBLE
            playerSlider.visibility = View.VISIBLE
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
        playerHandler.post(playerTask)
    }

    private val playerTask = object : Runnable {
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
            playerHandler.postDelayed(this, 1000)
        }
    }
}