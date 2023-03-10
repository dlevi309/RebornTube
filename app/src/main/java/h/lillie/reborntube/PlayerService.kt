package h.lillie.reborntube

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.source.MergingMediaSource
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.common.MediaItem.fromUri
import androidx.media3.common.Player
import androidx.media3.session.MediaSessionService
import androidx.media3.session.MediaSession
import org.json.JSONArray
import org.json.JSONException
import java.io.IOException

class PlayerService : MediaSessionService() {

    private lateinit var player: ExoPlayer
    private lateinit var playerHandler: Handler
    private lateinit var playerSession: MediaSession

    private var sponsorBlockInfo = String()

    override fun onCreate() {
        super.onCreate()
        sponsorBlockInfo = Application.getSponsorBlockInfo()
        playerHandler = Handler(Looper.getMainLooper())
        createPlayer()
        createPlayerSession()
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession = playerSession

    override fun onDestroy() {
        super.onDestroy()
        playerSession.run {
            player.release()
            playerSession.release()
            release()
        }
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun createPlayer() {
        player = ExoPlayer.Builder(this).build()

        val videoUrl = Application.getVideoURL()
        val audioUrl = Application.getAudioURL()
        val videoUri: Uri = Uri.parse(videoUrl)
        val audioUri: Uri = Uri.parse(audioUrl)
        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
        val videoSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(videoUri))
        val audioSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(audioUri))
        val mergeSource: MediaSource = MergingMediaSource(videoSource, audioSource)

        player.repeatMode = Player.REPEAT_MODE_ONE
        player.setMediaSource(mergeSource)
        player.playWhenReady = true
        player.prepare()
        playerHandler.post(playerTask)
    }

    private fun createPlayerSession() {
        playerSession = MediaSession.Builder(this, player).build()
    }

    private val playerTask = object : Runnable {
        override fun run() {
            try {
                val jsonArray = JSONArray(sponsorBlockInfo)
                for (i in 0 until jsonArray.length()) {
                    val category = jsonArray.getJSONObject(i).optString("category")
                    val segment = jsonArray.getJSONObject(i).getJSONArray("segment")
                    val segment0 = String.format("%.3f", segment[0].toString().toDouble()).replace(".", "").toFloat()
                    val segment1 = String.format("%.3f", segment[1].toString().toDouble()).replace(".", "").toFloat()
                    if (category.contains("sponsor") && player.currentPosition.toString().toFloat() >= segment0 && player.currentPosition.toString().toFloat() <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                    } else if (category.contains("interaction") && player.currentPosition.toString().toFloat() >= segment0 && player.currentPosition.toString().toFloat() <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                    }
                }
                playerHandler.postDelayed(this, 1000)
            } catch (e: IOException) {
                Log.e("IOException", e.toString())
                playerHandler.postDelayed(this, 1000)
            } catch (e: JSONException) {
                Log.e("JSONException", e.toString())
            }
        }
    }
}