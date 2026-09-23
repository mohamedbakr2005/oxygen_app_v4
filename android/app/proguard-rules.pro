# SLF4J Fix
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign In / Play Services Auth
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.android.gms.auth.**


# Facebook SDK
-dontwarn com.facebook.**
-keep class com.facebook.** { *; }

# OkHttp / Networking
-dontwarn okhttp3.**
-dontwarn okio.**
