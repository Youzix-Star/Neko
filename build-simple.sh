#!/bin/bash

echo "🔨 开始构建 MD2 Termux 应用（简化版）..."
echo "=========================================="

# 设置工具路径
AAPT="/data/data/com.termux/files/usr/bin/aapt"
ZIPALIGN="/data/data/com.termux/files/usr/bin/zipalign"
ADB="/data/data/com.termux/files/usr/bin/adb"

# 检查工具是否存在
if [ ! -f "$AAPT" ]; then
    echo "❌ 错误：找不到 aapt 工具"
    echo "请安装：pkg install aapt"
    exit 1
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build/gen build/classes build/apk

# 创建目录
mkdir -p build/gen build/classes build/apk

# 创建简单的 R.java 文件（手动）
echo "📝 创建 R.java 文件..."
mkdir -p build/gen/com/example/md2termux
cat > build/gen/com/example/md2termux/R.java << 'R_EOF'
package com.example.md2termux;

public final class R {
    public static final class layout {
        public static final int activity_main=0x7f040001;
    }
    public static final class id {
        public static final int titleText=0x7f080001;
        public static final int counterText=0x7f080002;
        public static final int incrementButton=0x7f080003;
        public static final int resetButton=0x7f080004;
    }
    public static final class string {
        public static final int app_name=0x7f050001;
    }
    public static final class color {
        public static final int colorPrimary=0x7f060001;
    }
    public static final class style {
        public static final int Theme_MD2Termux=0x7f070001;
    }
}
R_EOF

# 编译 Java 文件（使用 Android 类路径）
echo "☕ 编译 Java 文件..."
# 创建一个简单的 Android 类用于编译
mkdir -p build/android-classes/android/app
cat > build/android-classes/android/app/Activity.java << 'ACTIVITY_EOF'
package android.app;

public class Activity {
    protected void onCreate(android.os.Bundle savedInstanceState) {}
    public void setContentView(int layoutResID) {}
    public <T extends View> T findViewById(int id) { return null; }
}
ACTIVITY_EOF

cat > build/android-classes/android/os/Bundle.java << 'BUNDLE_EOF'
package android.os;

public class Bundle {
}
BUNDLE_EOF

cat > build/android-classes/android/view/View.java << 'VIEW_EOF'
package android.view;

public class View {
    public void setOnClickListener(OnClickListener listener) {}
    
    public interface OnClickListener {
        void onClick(View v);
    }
}
VIEW_EOF

cat > build/android-classes/android/widget/TextView.java << 'TEXTVIEW_EOF'
package android.widget;

public class TextView extends android.view.View {
    public void setText(CharSequence text) {}
    public void setText(int resid) {}
}
TEXTVIEW_EOF

cat > build/android-classes/android/widget/Button.java << 'BUTTON_EOF'
package android.widget;

public class Button extends TextView {
}
BUTTON_EOF

cat > build/android-classes/android/widget/Toast.java << 'TOAST_EOF'
package android.widget;

public class Toast {
    public static final int LENGTH_SHORT = 0;
    public static final int LENGTH_LONG = 1;
    
    public static Toast makeText(android.content.Context context, CharSequence text, int duration) {
        return new Toast();
    }
    
    public void show() {}
}
TOAST_EOF

cat > build/android-classes/android/content/Context.java << 'CONTEXT_EOF'
package android.content;

public class Context {
}
CONTEXT_EOF

# 编译 Android 类
javac -source 1.8 -target 1.8 -d build/android-compiled \
    build/android-classes/android/app/Activity.java \
    build/android-classes/android/os/Bundle.java \
    build/android-classes/android/view/View.java \
    build/android-classes/android/widget/TextView.java \
    build/android-classes/android/widget/Button.java \
    build/android-classes/android/widget/Toast.java \
    build/android-classes/android/content/Context.java 2>&1

# 编译应用代码
javac -source 1.8 -target 1.8 -bootclasspath build/android-compiled \
    -d build/classes \
    -classpath build/gen:build/android-compiled \
    src/com/example/md2termux/MainActivity.java 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 转换为 DEX 文件
echo "📦 转换为 DEX 文件..."
dx --dex --output=build/apk/classes.dex build/classes/ build/android-compiled/ 2>&1
if [ $? -ne 0 ]; then
    echo "❌ DEX 转换失败"
    exit 1
fi

# 打包资源文件
echo "📱 打包资源文件..."
$AAPT package -f -M AndroidManifest.xml -S res -F build/apk/resources.apk 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 资源打包失败"
    exit 1
fi

# 添加 DEX 到 APK
echo "📦 添加 DEX 到 APK..."
cd build/apk
zip -u resources.apk classes.dex 2>&1
cd ../..

# 重命名并对齐
echo "🔧 对齐 APK..."
mv build/apk/resources.apk build/apk/unsigned.apk
$ZIPALIGN -f 4 build/apk/unsigned.apk build/apk/aligned.apk 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  ZIPALIGN 失败，使用未对齐版本"
    cp build/apk/unsigned.apk build/apk/aligned.apk
fi

# 签名 APK（使用调试密钥）
echo "🔑 签名 APK..."
if [ -f ~/.android/debug.keystore ]; then
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore build/apk/aligned.apk androiddebugkey -storepass android -keypass android 2>&1
else
    echo "⚠️  没有调试密钥，创建一个新的..."
    mkdir -p ~/.android
    keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US" 2>&1
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore build/apk/aligned.apk androiddebugkey -storepass android -keypass android 2>&1
fi

# 最终 APK
cp build/apk/aligned.apk md2-termux-app.apk

echo ""
echo "✅ 构建完成！"
echo "📱 APK 文件：md2-termux-app.apk"
echo "📦 文件大小：$(du -h md2-termux-app.apk | cut -f1)"
echo ""
echo "🚀 安装到设备："
echo "   $ADB install -r md2-termux-app.apk"
echo ""
echo "📋 或者手动安装："
echo "   1. 将 md2-termux-app.apk 传输到手机"
echo "   2. 在文件管理器中点击安装"
echo "   3. 允许安装未知来源应用"
echo ""
echo "🎯 应用功能："
echo "   - Material Design 2 颜色主题"
echo "   - 简单的计数器功能"
echo "   - 增加和重置按钮"
echo "   - Toast 提示"
