# SLF4J Fix
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Facebook SDK
-dontwarn com.facebook.**
-keep class com.facebook.** { *; }

# OkHttp / Networking
-dontwarn okhttp3.**
-dontwarn okio.**
