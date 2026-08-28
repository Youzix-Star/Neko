#!/bin/bash

echo "🔨 开始构建 MD2 Termux 应用..."
echo "================================"

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

# 生成 R.java 文件
echo "📝 生成 R.java 文件..."
$AAPT package -f -m -J build/gen -M AndroidManifest.xml -S res -I /data/data/com.termux/files/usr/share/android.jar 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 生成 R.java 失败"
    echo "尝试使用内置 android.jar..."
    # 如果没有 android.jar，创建一个简单的 R.java
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

# 编译 Java 文件
echo "☕ 编译 Java 文件..."
javac -source 1.8 -target 1.8 -bootclasspath /data/data/com.termux/files/usr/share/android.jar \
    -d build/classes \
    -classpath build/gen \
    src/com/example/md2termux/MainActivity.java 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 转换为 DEX 文件
echo "📦 转换为 DEX 文件..."
dx --dex --output=build/apk/classes.dex build/classes/ 2>&1
if [ $? -ne 0 ]; then
    echo "❌ DEX 转换失败"
    exit 1
fi

# 打包资源文件
echo "📱 打包资源文件..."
$AAPT package -f -M AndroidManifest.xml -S res -I /data/data/com.termux/files/usr/share/android.jar -F build/apk/resources.apk 2>&1
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
    keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US" 2>&1
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore build/apk/aligned.apk androiddebugkey -storepass android -keypass android 2>&1
fi

# 最终 APK
cp build/apk/aligned.apk md2-termux-app.apk

echo ""
echo "✅ 构建完成！"
echo "📱 APK 文件：md2-termux-app.apk"
echo ""
echo "🚀 安装到设备："
echo "   $ADB install -r md2-termux-app.apk"
echo ""
echo "📋 或者手动安装："
echo "   1. 将 md2-termux-app.apk 传输到手机"
echo "   2. 在文件管理器中点击安装"
echo "   3. 允许安装未知来源应用"
