# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }

# Keep your app's main classes
-keep class com.example.poortak.** { *; }

# Keep model classes (if you have any)
-keep class * extends java.io.Serializable { *; }

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep R class
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Google Play Core rules
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep all classes that might be referenced by reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Fix for java.util.concurrent warnings
-keep class j$.util.concurrent.ConcurrentHashMap$TreeBin { int lockState; }
-keep class j$.util.concurrent.ConcurrentHashMap { int sizeCtl; int transferIndex; long baseCount; int cellsBusy; }
-keep class j$.util.concurrent.ConcurrentHashMap$CounterCell { long value; }
-keep class j$.util.IntSummaryStatistics { long count; long sum; int min; int max; }
-keep class j$.util.LongSummaryStatistics { long count; long sum; long min; long max; }
-keep class j$.util.DoubleSummaryStatistics { long count; double sum; double min; double max; }

# Prevent warnings about the above rules
-dontwarn j$.util.concurrent.**
-dontwarn j$.util.**
