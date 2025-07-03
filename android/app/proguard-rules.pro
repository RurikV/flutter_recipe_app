# Flutter Proguard Rules
# Since minification is disabled, we only need basic rules

# Keep Flutter-specific classes
-keep class io.flutter.** { *; }

# Keep application-specific classes
-keep class com.example.flutter_recipe_app.** { *; }

# Keep basic Android classes
-keep class android.** { *; }

# Keep basic attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
