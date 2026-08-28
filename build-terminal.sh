#!/bin/bash

echo "🔨 开始构建 MD2 Termux 应用（终端版）..."
echo "=========================================="

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build

# 创建目录
mkdir -p build/gen build/classes build/apk

# 创建简单的 R.java 文件
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

# 创建 Android 桩类
echo "📝 创建 Android 桩类..."
mkdir -p build/stubs/android/app build/stubs/android/os build/stubs/android/view build/stubs/android/widget build/stubs/android/content

cat > build/stubs/android/app/Activity.java << 'EOF'
package android.app;
public class Activity {
    protected void onCreate(android.os.Bundle savedInstanceState) {}
    public void setContentView(int layoutResID) {}
    public <T extends android.view.View> T findViewById(int id) { return null; }
}
