package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.Activity
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import android.view.View
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.ui.PlayerView
import java.util.concurrent.TimeUnit
import com.google.common.util.concurrent.MoreExecutors
import com.google.android.material.slider.Slider
import com.google.android.material.switchmaterial.SwitchMaterial
import com.pedromassango.doubleclick.DoubleClick
import com.pedromassango.doubleclick.DoubleClickListener
import com.squareup.picasso.Picasso
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
        val videoTitleLayout: RelativeLayout = findViewById(R.id.videoTitleLayout)
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        if (isInPictureInPictureMode) {
            videoOverlay.alpha = 0.toFloat()
            videoSlider.alpha = 0.toFloat()
            videoTitleLayout.alpha = 0.toFloat()
            videoInfo.alpha = 0.toFloat()
        } else {
            videoOverlay.alpha = 1.toFloat()
            videoSlider.alpha = 1.toFloat()
            videoTitleLayout.alpha = 1.toFloat()
            videoInfo.alpha = 1.toFloat()
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
        middleView.x = deviceWidth / 3.toFloat()
        middleView.setOnClickListener {
            changeOverlay(orientation)
        }

        val rightView: View = findViewById(R.id.rightView)
        rightView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rightView.x = (deviceWidth / 3) * 2.toFloat()
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

        val videoSwitch: SwitchMaterial = findViewById(R.id.videoSwitch)
        videoSwitch.layoutParams = RelativeLayout.LayoutParams(200, 108)
        videoSwitch.x = deviceWidth - 200.toFloat()
        videoSwitch.y = 50.toFloat()
        videoSwitch.setOnCheckedChangeListener { _, isChecked ->
            val playerView: PlayerView = findViewById(R.id.playerView)
            val playerImageView: ImageView = findViewById(R.id.playerImageView)
            if (!isChecked) {
                playerView.visibility = View.VISIBLE
                playerImageView.visibility = View.GONE
            } else if (isChecked) {
                playerView.visibility = View.GONE
                playerImageView.visibility = View.VISIBLE
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

        val videoLoop: Button = findViewById(R.id.videoLoop)
        videoLoop.layoutParams = RelativeLayout.LayoutParams(200, 100)
        videoLoop.y = (deviceWidth * 9 / 16) + 304.toFloat()
        videoLoop.setOnClickListener {
            val loop = Application.getLoop()
            if (!loop) {
                Application.setLoop(true)
                Toast.makeText(this@Player, "Loop Enabled", Toast.LENGTH_SHORT).show()
            } else if (loop) {
                Application.setLoop(false)
                Toast.makeText(this@Player, "Loop Disabled", Toast.LENGTH_SHORT).show()
            }
        }

        val videoShare: Button = findViewById(R.id.videoShare)
        videoShare.layoutParams = RelativeLayout.LayoutParams(200, 100)
        videoShare.x = 200.toFloat()
        videoShare.y = (deviceWidth * 9 / 16) + 304.toFloat()
        videoShare.setOnClickListener {
            val videoID = Application.getVideoID()
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
        val videoSwitch: SwitchMaterial = findViewById(R.id.videoSwitch)

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
            videoSwitch.visibility = View.GONE
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
            videoSwitch.visibility = View.VISIBLE
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
        val playerImageView: ImageView = findViewById(R.id.playerImageView)
        val artworkUrl = Application.getArtworkURL()
        val artworkUri: Uri = Uri.parse(artworkUrl)
        Picasso.get().load(artworkUri).into(playerImageView)

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