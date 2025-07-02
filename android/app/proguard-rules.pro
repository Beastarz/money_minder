# Rules for flutter_local_notifications plugin
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ForegroundService { *; }
# The SharedPreferencesPlugin rule might not be strictly necessary for Flutter SDK 3.22+
# but including it doesn't hurt.
-keep class io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin { *; }