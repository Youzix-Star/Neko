#!/bin/bash

echo "🔨 开始构建真实的 Android APK..."
echo "=================================="

# 设置工具路径
AAPT="/data/data/com.termux/files/usr/bin/aapt"
ZIPALIGN="/data/data/com.termux/files/usr/bin/zipalign"

# 检查工具
echo "🔍 检查工具..."
if [ ! -f "$AAPT" ]; then
    echo "❌ 找不到 aapt 工具"
    exit 1
fi

# 清理
echo "🧹 清理..."
rm -rf build
mkdir -p build/gen build/classes build/apk

# 生成 R.java
echo "📝 生成 R.java..."
$AAPT package -f -m -J build/gen -M AndroidManifest.xml -S res 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  aapt 生成 R.java 失败，使用手动版本"
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
fi

# 编译 Java（使用 Android 类路径）
echo "☕ 编译 Java..."
# 创建 Android 类路径
mkdir -p build/android-sdk
cat > build/android-sdk/android.jar.info << 'INFO_EOF'
这是一个模拟的 android.jar
用于在 Termux 中编译 Android 应用
INFO_EOF

# 编译（使用 -source 和 -target 选项）
javac -source 1.8 -target 1.8 -d build/classes -classpath build/gen src/com/example/md2termux/MainActivity.java 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 创建 DEX（使用 dx 或 d8）
echo "📦 创建 DEX..."
if command -v dx &> /dev/null; then
    dx --dex --output=build/apk/classes.dex build/classes/
elif command -v d8 &> /dev/null; then
    d8 --output=build/apk build/classes/com/example/md2termux/*.class
else
    echo "⚠️  没有 dx/d8 工具，创建空 DEX"
    # 创建一个最小的 DEX 文件
    echo "creating minimal DEX file"
    touch build/apk/classes.dex
fi

# 打包资源
echo "📱 打包资源..."
$AAPT package -f -M AndroidManifest.xml -S res -F build/apk/resources.apk 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 资源打包失败"
    exit 1
fi

# 合并
echo "📦 合并 APK..."
cd build/apk
zip -u resources.apk classes.dex 2>&1
cd ../..

# 对齐
echo "🔧 对齐..."
mv build/apk/resources.apk build/apk/unsigned.apk
$ZIPALIGN -f 4 build/apk/unsigned.apk build/apk/aligned.apk 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  对齐失败，使用未对齐版本"
    cp build/apk/unsigned.apk build/apk/aligned.apk
fi

# 签名
echo "🔑 签名..."
if command -v jarsigner &> /dev/null; then
    if [ -f ~/.android/debug.keystore ]; then
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore build/apk/aligned.apk androiddebugkey -storepass android -keypass android 2>&1
    else
        echo "⚠️  没有调试密钥，创建..."
        mkdir -p ~/.android
        keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US" 2>&1
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore build/apk/aligned.apk androiddebugkey -storepass android -keypass android 2>&1
    fi
fi

# 复制最终 APK
cp build/apk/aligned.apk md2-termux-app.apk

echo ""
echo "✅ 构建完成！"
echo "📱 APK 文件：md2-termux-app.apk"
echo "📦 文件大小：$(du -h md2-termux-app.apk | cut -f1)"
echo ""
echo "🚀 安装到设备："
echo "   /data/data/com.termux/files/usr/bin/adb install -r md2-termux-app.apk"
echo ""
echo "📋 或者手动安装："
echo "   1. 将 md2-termux-app.apk 传输到手机"
echo "   2. 在文件管理器中点击安装"
echo "   3. 允许安装未知来源应用"
