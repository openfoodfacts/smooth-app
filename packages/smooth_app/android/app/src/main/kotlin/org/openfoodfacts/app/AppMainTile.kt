package org.openfoodfacts.app

import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import org.openfoodfacts.scanner.MainActivity

@RequiresApi(Build.VERSION_CODES.N)
class AppMainTile : TileService() {

    override fun onStartListening() {
        super.onStartListening()

        qsTile.state = Tile.STATE_INACTIVE
        qsTile.updateTile()
    }

    override fun onClick() {
        super.onClick()

        val intent = Intent(this, MainActivity::class.java).apply {
            flags += Intent.FLAG_ACTIVITY_NEW_TASK
        }

        startActivityAndCollapse(intent)
    }

}