package annd.personal.toolforlife

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class BackgroundUploadService : Service() {
    
    companion object {
        private const val NOTIFICATION_ID = 1002
        private const val CHANNEL_ID = "changmeeting_upload_channel"
        private const val CHANNEL_NAME = "Chang Meeting Upload"
        
        // Service state
        var isServiceRunning = false
        private var instance: BackgroundUploadService? = null
        
        fun getInstance(): BackgroundUploadService? = instance
    }
    
    private var notificationManager: NotificationManager? = null
    private var currentFileName: String = ""
    private var currentProgress: Double = 0.0
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        isServiceRunning = true
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        android.util.Log.d("UploadService", "onStartCommand called")
        
        startForeground(NOTIFICATION_ID, createUploadNotification("Preparing upload...", 0.0))
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
        isServiceRunning = false
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifications for file upload progress"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager?.createNotificationChannel(channel)
        }
    }
    
    private fun createUploadNotification(fileName: String, progress: Double): Notification {
        val progressInt = (progress * 100).toInt()
        
        // Intent for notification tap (open app)
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val openAppPendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher))
            .setContentTitle("Đang tải lên file ghi âm")
            .setContentText(if (fileName.isNotEmpty()) fileName else "Preparing...")
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setSilent(true)
            .setContentIntent(openAppPendingIntent)
            .setColor(0xFFFF6F20.toInt())
        
        // Add progress bar
        if (progress > 0) {
            notificationBuilder.setProgress(100, progressInt, false)
            notificationBuilder.setSubText("$progressInt%")
        } else {
            notificationBuilder.setProgress(100, 0, true) // Indeterminate progress
        }
        
        return notificationBuilder.build()
    }
    
    fun updateProgress(fileName: String, progress: Double) {
        currentFileName = fileName
        currentProgress = progress
        
        val notification = createUploadNotification(fileName, progress)
        notificationManager?.notify(NOTIFICATION_ID, notification)
        
        android.util.Log.d("UploadService", "Progress updated: $fileName - ${(progress * 100).toInt()}%")
    }
}