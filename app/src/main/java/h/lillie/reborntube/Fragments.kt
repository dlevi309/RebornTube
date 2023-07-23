package h.lillie.reborntube

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

class Fragments(private val tab: Int) : Fragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        if (tab == 1) {
            return inflater.inflate(R.layout.subscriptions, container, false)
        }
        if (tab == 2) {
            return inflater.inflate(R.layout.history, container, false)
        }
        if (tab == 3) {
            return inflater.inflate(R.layout.playlists, container, false)
        }
        if (tab == 4) {
            return inflater.inflate(R.layout.downloads, container, false)
        }
        return null
    }
}