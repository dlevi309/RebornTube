package h.lillie.reborntube

import android.content.Intent
import android.os.Bundle
import android.content.Context
import android.content.ClipboardManager
import android.app.Activity
import android.app.AlertDialog
import android.os.StrictMode

class Main : Activity() {

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
        val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/|shorts\\/|live\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
        val check = youtubeRegex.containsMatchIn(clipboardInfo)
        if (check) {
            val result = youtubeRegex.findAll(clipboardInfo).map { it.groupValues[1] }.joinToString()

            val extractor = Extractor()
            val playerRequest = extractor.playerRequest(applicationContext, "ANDROID", "16.20", result)
            val dislikesRequest = extractor.returnYouTubeDislikesRequest(result)
            val sponsorBlockRequest = extractor.sponsorBlockRequest(result)

            val loader = Loader()
            val loaderPlayerInfo = loader.playerInit(playerRequest)
            val loaderDislikesInfo = loader.dislikesInit(dislikesRequest)

            Application.setVideoID(result)
            Application.setVideoURL(loaderPlayerInfo[0].toString())
            Application.setAudioURL(loaderPlayerInfo[1].toString())
            Application.setSponsorBlockInfo(sponsorBlockRequest)
            Application.setArtworkURL(loaderPlayerInfo[2].toString())
            Application.setTitle(loaderPlayerInfo[3].toString())
            Application.setAuthor(loaderPlayerInfo[4].toString())
            Application.setLive(loaderPlayerInfo[5].toString().toBoolean())
            Application.setViewCount(loaderDislikesInfo[0].toString())
            Application.setLikes(loaderDislikesInfo[1].toString())
            Application.setDislikes(loaderDislikesInfo[2].toString())

            val intent = Intent(this@Main, Player::class.java)
            startActivity(intent)
        } else {
            val errorPopup = AlertDialog.Builder(this)
            errorPopup.setTitle("Error")
            errorPopup.setMessage("No YouTube video url found in clipboard, please close the app and copy a youtube video url to your clipboard before opening")
            errorPopup.setCancelable(false)
            errorPopup.show()
        }
    }
}