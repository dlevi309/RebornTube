package h.lillie.reborntube

data class Data(
    var videoID: String,
    var videoURL: String,
    var audioURL: String,
    var sponsorBlockInfo: String,
    var artworkURL: String,
    var title: String,
    var author: String,
    var viewCount: String,
    var live: Boolean = false,
    var likes: String,
    var dislikes: String
)