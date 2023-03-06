package h.lillie.reborntube

import android.content.Intent
import android.os.Bundle
import android.content.Context
import android.content.ClipboardManager
import androidx.appcompat.app.AppCompatActivity
import android.app.AlertDialog
import android.os.StrictMode

class Main : AppCompatActivity() {

    private var hasRan = 0
    private var hasCreated = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
        val policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        hasCreated = 1
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && hasRan == 0 && hasCreated == 1) {
            hasRan = 1
            getClipboardInfo()
        }
    }

    private fun getClipboardInfo() {
        val clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clipboardInfo = clipboardManager.primaryClip?.getItemAt(0)?.text.toString()
        val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
        val check = youtubeRegex.containsMatchIn(clipboardInfo)
        if (check) {
            val result = youtubeRegex.findAll(clipboardInfo).map { it.groupValues[1] }.joinToString()

            val extractor = Extractor()
            val playerRequest = extractor.playerRequest(result)
            val sponsorBlockRequest = extractor.sponsorBlockRequest(result)

            val loader = Loader()
            val loaderInfo = loader.init(playerRequest)

            showPopup(loaderInfo[0], loaderInfo[1], sponsorBlockRequest)
        } else {
            val errorPopup = AlertDialog.Builder(this)
            errorPopup.setTitle("Error")
            errorPopup.setMessage("No YouTube video url found in clipboard, please close the app and copy a youtube video url to your clipboard before opening")
            errorPopup.setCancelable(false)
            errorPopup.show()
        }
    }

    private fun showPopup(videoUrl: String, audioUrl: String, sponsorBlock: String) {
        val playerPopup = AlertDialog.Builder(this).create()
        playerPopup.setTitle("Player")
        playerPopup.setButton(AlertDialog.BUTTON_NEUTRAL, "Exo Player") { dialog, which ->
            val intent = Intent(this@Main, Player::class.java)
            intent.putExtra("videoUrl", videoUrl)
            intent.putExtra("audioUrl", audioUrl)
            intent.putExtra("sponsorBlock", sponsorBlock)
            startActivity(intent)
        }
        playerPopup.setButton(AlertDialog.BUTTON_POSITIVE, "VLC Player") { dialog, which ->
            val intent = Intent(this@Main, VLCPlayer::class.java)
            intent.putExtra("videoUrl", videoUrl)
            intent.putExtra("audioUrl", audioUrl)
            intent.putExtra("sponsorBlock", sponsorBlock)
            startActivity(intent)
        }
        playerPopup.show()
    }
}