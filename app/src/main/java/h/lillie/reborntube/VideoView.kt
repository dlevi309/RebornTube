package h.lillie.reborntube

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.TypedValue
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.res.ResourcesCompat
import android.widget.ImageView
import android.widget.TextView
import android.widget.RelativeLayout
import android.widget.LinearLayout
import android.widget.Space
import android.view.View
import android.view.Gravity
import com.squareup.picasso.Picasso
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class VideoView {
    fun addView(activity: AppCompatActivity, applicationContext: Context, info: String, searchScrollView: LinearLayout, deviceType: Boolean, deviceWidth: Int) {
        val gson = Gson()
        val videoInfo = gson.fromJson(info, VideoViewData::class.java)

        val searchRelativeView = RelativeLayout(applicationContext)
        searchRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
        searchRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

        val videoImageView = ImageView(applicationContext)
        videoImageView.layoutParams = LinearLayout.LayoutParams(180, 160)
        videoImageView.scaleType = ImageView.ScaleType.FIT_XY
        val artworkUri: Uri = Uri.parse(videoInfo.artworkURL)
        Picasso.get().load(artworkUri).into(videoImageView)

        val videoTimeTextView = TextView(applicationContext)
        videoTimeTextView.layoutParams = LinearLayout.LayoutParams(70, 30)
        videoTimeTextView.x = 110f
        videoTimeTextView.y = 130f
        videoTimeTextView.text = videoInfo.time
        videoTimeTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
        videoTimeTextView.gravity = Gravity.CENTER
        videoTimeTextView.setTextColor(applicationContext.getColor(R.color.white))
        videoTimeTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
        videoTimeTextView.setBackgroundColor(applicationContext.getColor(R.color.blackdimmed))

        val videoTitleTextView = TextView(applicationContext)
        videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 190, 160)
        videoTitleTextView.x = 190f
        videoTitleTextView.text = videoInfo.title
        videoTitleTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
        videoTitleTextView.gravity = Gravity.CENTER_VERTICAL
        videoTitleTextView.setTextColor(applicationContext.getColor(R.color.white))

        val videoViewCountAuthorTextView = TextView(applicationContext)
        if (!deviceType) {
            videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 80, 40)
        } else if (deviceType) {
            videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth, 40)
        }
        videoViewCountAuthorTextView.y = 160f
        if (videoInfo.viewCount != null) {
            videoViewCountAuthorTextView.text = String.format("%,.0f views - %s", videoInfo.viewCount, videoInfo.author)
        }
        if (videoInfo.viewCountString != null) {
            videoViewCountAuthorTextView.text = String.format("%s - %s", videoInfo.viewCountString, videoInfo.author)
        }
        videoViewCountAuthorTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
        videoViewCountAuthorTextView.gravity = Gravity.CENTER_VERTICAL
        videoViewCountAuthorTextView.setTextColor(applicationContext.getColor(R.color.white))
        videoViewCountAuthorTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)

        val videoMenuTextView = TextView(applicationContext)
        videoMenuTextView.layoutParams = LinearLayout.LayoutParams(80, 40)
        videoMenuTextView.x = deviceWidth - 80f
        videoMenuTextView.y = 160f
        videoMenuTextView.text = "•••"
        videoMenuTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
        videoMenuTextView.gravity = Gravity.CENTER
        videoMenuTextView.setTextColor(applicationContext.getColor(R.color.white))
        videoMenuTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
        videoMenuTextView.setOnClickListener {
            val shareIntent: Intent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, String.format("https://youtu.be/%s", videoInfo.videoID))
                type = "text/plain"
            }
            activity.startActivity(Intent.createChooser(shareIntent, null))
        }

        val videoButton = View(applicationContext)
        videoButton.layoutParams = LinearLayout.LayoutParams(deviceWidth, 200)
        if (deviceType) {
            videoButton.setBackgroundResource(R.drawable.tvbutton)
        }
        videoButton.setOnClickListener {
            CoroutineScope(Dispatchers.Main).launch {
                withContext(Dispatchers.IO) {
                    val loader = Loader()
                    loader.playerInit(applicationContext, videoInfo.videoID)

                    if (!deviceType) {
                        val intent = Intent(applicationContext, Player::class.java)
                        activity.startActivity(intent)
                    } else if (deviceType) {
                        val intent = Intent(applicationContext, TVPlayer::class.java)
                        activity.startActivity(intent)
                    }
                }
            }
        }
        searchRelativeView.addView(videoImageView)
        searchRelativeView.addView(videoTimeTextView)
        searchRelativeView.addView(videoTitleTextView)
        searchRelativeView.addView(videoViewCountAuthorTextView)
        searchRelativeView.addView(videoButton)
        if (!deviceType) {
            searchRelativeView.addView(videoMenuTextView)
        }

        val spaceView = Space(applicationContext)
        spaceView.minimumHeight = 4
        searchScrollView.addView(spaceView)
        searchScrollView.addView(searchRelativeView)
    }
}