package org.openfoodfacts.scanner_zxing

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.util.Log
import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer


object ZXingUtils {

    fun extractBarcodeFromImage(path: String?, orientation: Int?): String? {
        if (path.isNullOrEmpty() || orientation == null) {
            return null
        }

        val matrix = Matrix().apply {
            postRotate(orientation.toFloat())
        }

        val bitmap = BitmapFactory.decodeFile(path)

        val rotatedBitmap = Bitmap.createBitmap(
            bitmap,
            0,
            0,
            bitmap.width,
            bitmap.height,
            matrix,
            true
        )

        val width = rotatedBitmap.width
        val height = rotatedBitmap.height
        val pixels = IntArray(width * height)

        bitmap.recycle()
        rotatedBitmap.getPixels(pixels, 0, width, 0, 0, width, height)
        rotatedBitmap.recycle()

        val binaryBitmap = BinaryBitmap(
            HybridBinarizer(
                RGBLuminanceSource(
                    width,
                    height,
                    pixels
                )
            )
        )

        return runCatching {
            MultiFormatReader().decode(binaryBitmap).text
        }.getOrNull()
    }

}