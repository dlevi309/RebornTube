package h.lillie.reborntube

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.source.MergingMediaSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.common.MediaMetadata
import androidx.media3.common.MediaItem
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
        playerSession = MediaSession.Builder(this, player).build()

        val title = Application.getTitle()
        val author = Application.getAuthor()

        val videoUrl = Application.getVideoURL()
        val audioUrl = Application.getAudioURL()
        val artworkUrl = Application.getArtworkURL()
        val artworkUri: Uri = Uri.parse(artworkUrl)

        val isLive = Application.getLive()

        val mediaMetadata: MediaMetadata = MediaMetadata.Builder()
            .setTitle(title)
            .setArtist(author)
            .setArtworkUri(artworkUri)
            .build()

        if (!isLive) {
            val videoUri: Uri = Uri.parse(videoUrl)
            val audioUri: Uri = Uri.parse(audioUrl)

            val videoMediaItem: MediaItem = MediaItem.Builder()
                .setMediaMetadata(mediaMetadata)
                .setUri(videoUri)
                .build()

            val audioMediaItem: MediaItem = MediaItem.Builder()
                .setMediaMetadata(mediaMetadata)
                .setUri(audioUri)
                .build()

            val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
            val videoSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(videoMediaItem)
            val audioSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(audioMediaItem)
            val mergeSource: MediaSource = MergingMediaSource(videoSource, audioSource)

            player.setMediaSource(mergeSource)
        } else if (isLive) {
            val videoUri: Uri = Uri.parse(videoUrl)

            val videoMediaItem: MediaItem = MediaItem.Builder()
                .setMediaMetadata(mediaMetadata)
                .setUri(videoUri)
                .build()

            val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
            val videoSource: MediaSource = HlsMediaSource.Factory(dataSourceFactory).createMediaSource(videoMediaItem)

            player.setMediaSource(videoSource)
        }
        player.repeatMode = Player.REPEAT_MODE_ONE
        player.playWhenReady = true
        player.prepare()
        if (!isLive) {
            playerHandler.post(playerTask)
        }
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
                    if (category.contains("sponsor") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                        Toast.makeText(this@PlayerService, "Sponsor Skipped", Toast.LENGTH_SHORT).show()
                    } else if (category.contains("interaction") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                        Toast.makeText(this@PlayerService, "Interaction Skipped", Toast.LENGTH_SHORT).show()
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