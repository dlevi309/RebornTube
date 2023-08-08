package h.lillie.reborntube.player

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.content.pm.PackageManager
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import android.view.View
import android.view.ViewGroup
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import androidx.media3.common.Player
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.ui.PlayerView
import java.util.concurrent.TimeUnit
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.MoreExecutors
import com.google.android.material.slider.Slider
import com.google.gson.Gson
import com.pedromassango.doubleclick.DoubleClick
import com.pedromassango.doubleclick.DoubleClickListener
import h.lillie.reborntube.Application
import h.lillie.reborntube.Converter
import h.lillie.reborntube.R
import h.lillie.reborntube.VideoData
import java.io.IOException

class Player : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0
    private var overlayVisible = 0
    private var onStopCalled: Boolean = false

    private lateinit var playerControllerFuture: ListenableFuture<MediaController>
    private lateinit var playerController: MediaController
    private lateinit var playerHandler: Handler
    private lateinit var playerSlider: Slider

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        playerHandler = Handler(Looper.getMainLooper())
        playerSlider = findViewById(R.id.playerSlider)
        getDeviceInfo()
        if (deviceType) {
            val playerLayout: RelativeLayout = findViewById(R.id.playerLayout)
            val params = playerLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            playerLayout.layoutParams = params
        }
        val sessionToken = SessionToken(this@Player, ComponentName(this@Player, PlayerService::class.java))
        playerControllerFuture = MediaController.Builder(this@Player, sessionToken).buildAsync()
        playerControllerFuture.addListener(
            {
                playerController = playerControllerFuture.get()
                createPlayer()
            },
            MoreExecutors.directExecutor()
        )
    }

    override fun onResume() {
        super.onResume()
        val preferences = getSharedPreferences("RTSettings", Context.MODE_PRIVATE)
        val backgroundMode: Int = preferences.getInt("RTBackgroundMode", 0)
        if (backgroundMode == 0 && onStopCalled) {
            playerController.play()
        }
        onStopCalled = false
    }

    override fun onStop() {
        super.onStop()
        onStopCalled = true
        if (deviceType) {
            finish()
        }
        val preferences = getSharedPreferences("RTSettings", Context.MODE_PRIVATE)
        val backgroundMode: Int = preferences.getInt("RTBackgroundMode", 0)
        if (backgroundMode == 0 && onStopCalled) {
            playerController.stop()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Application.setVideoData("")
        val playerView: PlayerView = findViewById(R.id.playerView)
        playerView.keepScreenOn = false
        playerView.player = null
        playerHandler.removeCallbacks(playerTask)
        playerHandler.removeCallbacksAndMessages(null)
        playerController.stop()
        playerController.release()
        MediaController.releaseFuture(playerControllerFuture)
        stopService(Intent(this@Player, PlayerService::class.java))
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
        val videoTitleLayout: RelativeLayout = findViewById(R.id.videoTitleLayout)
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        if (isInPictureInPictureMode) {
            videoOverlay.alpha = 0f
            videoSlider.alpha = 0f
            videoTitleLayout.alpha = 0f
            videoInfo.alpha = 0f
        } else {
            videoOverlay.alpha = 1f
            videoSlider.alpha = 1f
            videoTitleLayout.alpha = 1f
            videoInfo.alpha = 1f
            if (onStopCalled) {
                finish()
            }
        }
    }

    @SuppressLint("SwitchIntDef")
    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
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
        // Info
        val gson = Gson()
        val converter = Converter()
        val videoData = gson.fromJson(Application.getVideoData(), VideoData::class.java)

        // Player
        val videoPlayer: RelativeLayout = findViewById(R.id.videoPlayer)
        videoPlayer.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Overlay
        val leftView: View = findViewById(R.id.leftView)
        leftView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        leftView.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition - TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val middleView: View = findViewById(R.id.middleView)
        middleView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        middleView.x = deviceWidth / 3f
        middleView.setOnClickListener {
            changeOverlay(orientation)
        }

        val rightView: View = findViewById(R.id.rightView)
        rightView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rightView.x = (deviceWidth / 3) * 2f
        rightView.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                playerController.seekTo(playerController.currentPosition + TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        playPauseRestartButton.layoutParams = RelativeLayout.LayoutParams(108, 108)
        playPauseRestartButton.x = (deviceWidth / 2) - 54f
        if (orientation == 0) {
            playPauseRestartButton.y = ((deviceWidth * 9 / 16) / 2) - 54f
        } else if (orientation == 1) {
            playPauseRestartButton.y = (deviceHeight / 2) - 54f
        }
        playPauseRestartButton.setOnClickListener {
            if (playerController.isPlaying) {
                playerController.pause()
            } else if (!playerController.isPlaying) {
                playerController.play()
            }
        }

        // Slider
        if (orientation == 0) {
            playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 0)
            playerSlider.x = 0f
            playerSlider.y = (deviceWidth * 9 / 16).toFloat() - converter.dpToPx(this@Player,24f)
            playerSlider.visibility = View.VISIBLE
        } else if (orientation == 1) {
            playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth - 256, 0)
            playerSlider.x = 32f
            playerSlider.y = deviceHeight - 192f
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
        videoTitle.layoutParams = RelativeLayout.LayoutParams(deviceWidth - converter.dpToPx(this@Player, 32f).toInt(), converter.dpToPx(this@Player,50f).toInt())
        if (orientation == 0) {
            videoTitle.x = converter.dpToPx(this@Player, 16f)
            videoTitle.y = (deviceWidth * 9 / 16) + converter.dpToPx(this@Player,32f)
            videoTitle.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoTitle.x = converter.dpToPx(this@Player, 32f)
            videoTitle.y = 50f
            if (overlayVisible == 0) {
                videoTitle.visibility = View.GONE
            } else if (overlayVisible == 1) {
                videoTitle.visibility = View.VISIBLE
            }
        }
        videoTitle.text = videoData.title

        // Info
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        videoInfo.y = (deviceWidth * 9 / 16) + converter.dpToPx(this@Player,84f)
        if (orientation == 0) {
            videoInfo.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoInfo.visibility = View.GONE
        }

        val videoCountLikesDislikes: TextView = findViewById(R.id.videoCountLikesDislikes)
        videoCountLikesDislikes.text = String.format("View Count: %,.0f\nLikes: %,.0f\nDislikes: %,.0f", videoData.viewCount.toDouble(), videoData.likes.toDouble(), videoData.dislikes.toDouble())

        val videoLoop: Button = findViewById(R.id.videoLoop)
        videoLoop.setOnClickListener {
            if (playerController.repeatMode == Player.REPEAT_MODE_OFF) {
                playerController.repeatMode = Player.REPEAT_MODE_ONE
                Toast.makeText(this@Player, "Loop Enabled", Toast.LENGTH_SHORT).show()
            } else if (playerController.repeatMode == Player.REPEAT_MODE_ONE) {
                playerController.repeatMode = Player.REPEAT_MODE_OFF
                Toast.makeText(this@Player, "Loop Disabled", Toast.LENGTH_SHORT).show()
            }
        }

        val videoShare: Button = findViewById(R.id.videoShare)
        videoShare.setOnClickListener {
            val videoID = videoData.videoID
            val shareIntent: Intent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, "https://youtu.be/$videoID")
                type = "text/plain"
            }
            startActivity(Intent.createChooser(shareIntent, null))
        }
    }

    private fun changeOverlay(orientation: Int) {
        val leftView: View = findViewById(R.id.leftView)
        val middleView: View = findViewById(R.id.middleView)
        val rightView: View = findViewById(R.id.rightView)
        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        val videoTitle: TextView = findViewById(R.id.videoTitle)

        val leftViewDrawable: Drawable = leftView.background
        val leftViewColorDrawable: ColorDrawable = leftViewDrawable as ColorDrawable
        val middleViewDrawable: Drawable = middleView.background
        val middleViewColorDrawable: ColorDrawable = middleViewDrawable as ColorDrawable
        val rightViewDrawable: Drawable = rightView.background
        val rightViewColorDrawable: ColorDrawable = rightViewDrawable as ColorDrawable

        val blackDimmed = applicationContext.getColor(R.color.blackdimmed)

        if (leftViewColorDrawable.color == blackDimmed && middleViewColorDrawable.color == blackDimmed && rightViewColorDrawable.color == blackDimmed) {
            overlayVisible = 0
            leftView.setBackgroundColor(0x00000000)
            middleView.setBackgroundColor(0x00000000)
            rightView.setBackgroundColor(0x00000000)
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
            leftView.setBackgroundColor(blackDimmed)
            middleView.setBackgroundColor(blackDimmed)
            rightView.setBackgroundColor(blackDimmed)
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
        playerView.keepScreenOn = true
        playerView.player = playerController

        val preferences = getSharedPreferences("RTSettings", Context.MODE_PRIVATE)
        val backgroundMode: Int = preferences.getInt("RTBackgroundMode", 0)
        if (android.os.Build.VERSION.SDK_INT >= 31 && backgroundMode == 2) {
            setPictureInPictureParams(
                PictureInPictureParams.Builder()
                    .setAutoEnterEnabled(true)
                    .setSeamlessResizeEnabled(true)
                    .build()
            )
        }
        playerHandler.post(playerTask)
    }

    private val playerTask = object : Runnable {
        override fun run() {
            try {
                val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
                if (playerController.isPlaying) {
                    playPauseRestartButton.setImageResource(R.drawable.pause)
                } else if (!playerController.isPlaying) {
                    if (playerController.playbackState == Player.STATE_ENDED) {
                        playPauseRestartButton.setImageResource(R.drawable.restart)
                    } else {
                        playPauseRestartButton.setImageResource(R.drawable.play)
                    }
                }

                val duration = playerController.duration.toFloat()
                val position = playerController.currentPosition.toFloat()
                if (duration >= 0 && position >= 0 && position <= duration) {
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