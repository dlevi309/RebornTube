package h.lillie.reborntube

import android.net.Uri
import android.os.Bundle
import android.widget.VideoView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class MainActivity : AppCompatActivity() {

    private lateinit var videoView: VideoView
    private var videoUrl = "https://rr8---sn-gvbxgn-tt1l.googlevideo.com/videoplayback?expire=1673854052&ei=BKjEY7aRNofYhgaxrJHIBg&ip=99.250.251.75&id=o-AC0CFyhgVnRUpRo8d0NS_WQmjcrdwWGLNrhXX6ux85q3&itag=22&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=254.444&lmt=1610132536736094&fexp=24007246&c=ANDROID&txp=5432432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRAIga_EIilKgBxHlhWnEC55wMExn4XcV9k0S7O3-XDYzzUACIDE7vCzJ1XwwEbjHNQa63j-flHn5iCndwMcX1jCfUm-h&redirect_counter=1&cm2rm=sn-gvbxgn-t34e7r&req_id=c478eee76059a3ee&cms_redirect=yes&cmsv=e&mh=mj&mm=29&mn=sn-gvbxgn-tt1l&ms=rdu&mt=1673832342&mv=m&mvi=8&pcm2cms=yes&pl=17&lsparams=mh,mm,mn,ms,mv,mvi,pcm2cms,pl&lsig=AG3C_xAwRgIhAM_SbG4p2g87PwD0XnEP_qHHafnjCYhA2dEPbzGkavQZAiEAuHktXwF3wIPQNYxL9ZHtNIrPK1lpzCNGzGO3c5eMr94%3D"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)

        videoView = findViewById(R.id.videoView);
        val uri: Uri = Uri.parse(videoUrl)
        videoView.setVideoURI(uri)

        /* val mediaController = MediaController(this)
        mediaController.setAnchorView(videoView)
        mediaController.setMediaPlayer(videoView) */

        videoView.start()

        // val retrofit = Retrofit.Builder().baseUrl("https://api.waifu.pics/sfw/megumin").addConverterFactory(GsonConverterFactory.create()).build()
    }
}