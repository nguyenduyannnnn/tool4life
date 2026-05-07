package annd11.mobile.changmeeting

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.media.app.NotificationCompat.MediaStyle
import java.util.*
import kotlin.concurrent.timer

class RecordingNotificationService : Service() {
    
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "changmeeting_recording_channel"
        
        // Service state
        var isServiceRunning = false
        private var instance: RecordingNotificationService? = null
        
        fun getInstance(): RecordingNotificationService? = instance
    }
    
    private lateinit var mediaSession: MediaSessionCompat
    private var notificationManager: NotificationManager? = null
    private var updateTimer: Timer? = null
    private var recordingStartTime: Long = 0
    private var currentDuration: Int = 0
    private val mainHandler = Handler(Looper.getMainLooper())
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        isServiceRunning = true
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        setupMediaSession()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        android.util.Log.d("RecordingService", "onStartCommand called")
        
        android.util.Log.d("RecordingService", "Starting recording service")
        recordingStartTime = System.currentTimeMillis()
        startForeground(NOTIFICATION_ID, createNotification(0))
        startTimer()
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
        isServiceRunning = false
        
        updateTimer?.cancel()
        updateTimer = null
        
        if (::mediaSession.isInitialized) {
            mediaSession.release()
        }
        
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
                "Recording",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifications for recording status"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager?.createNotificationChannel(channel)
        }
    }
    
    private fun setupMediaSession() {
        mediaSession = MediaSessionCompat(this, "ChangMeetingRecording").apply {
            setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS or MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS)
            
            // Set initial playback state
            setPlaybackState(
                PlaybackStateCompat.Builder()
                    .setActions(PlaybackStateCompat.ACTION_STOP)
                    .setState(PlaybackStateCompat.STATE_PLAYING, 0, 1.0f)
                    .build()
            )
            
            // Set metadata
            setMetadata(
                MediaMetadataCompat.Builder()
                    .putString(MediaMetadataCompat.METADATA_KEY_TITLE, "Chang Meeting đang ghi âm")
                    .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, -1) // Unknown duration
                    .build()
            )
            
            // Set callback for media buttons
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onStop() {
                    // Do nothing - user must stop from app
                }
            })
            
            isActive = true
        }
    }
    
    private fun createNotification(durationSeconds: Int): Notification {
        val timeText = formatDuration(durationSeconds)
        
        // Intent for notification tap (open app)
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val openAppPendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Chang Meeting đang ghi âm")
            .setContentText(timeText)
            .setLargeIcon(BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher))
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setSilent(true)
            .setContentIntent(openAppPendingIntent)
            .setStyle(
                MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    .setShowActionsInCompactView()
            )
            .setColor(0xFFFF6F20.toInt())
            .build()
    }
    
    private fun startTimer() {
        updateTimer?.cancel()
        updateTimer = timer(period = 1000) {
            currentDuration = ((System.currentTimeMillis() - recordingStartTime) / 1000).toInt()
            
            // Update notification on main thread
            mainHandler.post {
                val notification = createNotification(currentDuration)
                notificationManager?.notify(NOTIFICATION_ID, notification)
                
                // Update media session metadata
                mediaSession.setMetadata(
                    MediaMetadataCompat.Builder()
                        .putString(MediaMetadataCompat.METADATA_KEY_TITLE, "Chang Meeting đang ghi âm")
                        .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE, formatDuration(currentDuration))
                        .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, -1)
                        .build()
                )
            }
        }
    }
    
    private fun formatDuration(seconds: Int): String {
        val minutes = seconds / 60
        val remainingSeconds = seconds % 60
        return String.format("%02d:%02d", minutes, remainingSeconds)
    }
    
    fun updateDuration(duration: Int) {
        currentDuration = duration
        val notification = createNotification(duration)
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }
}