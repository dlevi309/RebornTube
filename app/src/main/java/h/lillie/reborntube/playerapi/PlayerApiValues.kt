package h.lillie.reborntube.playerapi

data class PlayerApiValues (
    val streamingData: HlsManifestUrl
)

data class HlsManifestUrl (
    val hlsManifestUrl: String
)