package h.lillie.reborntube

data class Data(
    var videoID: String,
    var hlsURL: String,
    var sponsorBlockInfo: String,
    var artworkURL: String,
    var title: String,
    var author: String,
    var viewCount: String,
    var live: Boolean = false,
    var likes: String,
    var dislikes: String
)

data class VideoViewData(
    var videoID: String?,
    var title: String?,
    var artworkURL: String?,
    var author: String?,
    var time: String?,
    var viewCount: Double?,
    var viewCountString: String?
)