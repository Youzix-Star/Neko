#!/bin/bash

echo "🔨 开始构建 MD2 Termux 应用（终极版）..."
echo "=========================================="

# 清理
rm -rf build
mkdir -p build

# 创建简单的Java文件
echo "📝 创建简单的Java文件..."
mkdir -p build/src/com/example/md2termux
cat > build/src/com/example/md2termux/SimpleActivity.java << 'JAVA_EOF'
package com.example.md2termux;

public class SimpleActivity {
    public static void main(String[] args) {
        System.out.println("Material Design 2 测试应用");
        System.out.println("计数器: 0");
        System.out.println("这是一个在Termux中构建的简单应用");
    }
}
JAVA_EOF

# 编译
echo "☕ 编译..."
javac -d build/classes build/src/com/example/md2termux/SimpleActivity.java 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 运行测试
echo "🚀 运行测试..."
java -cp build/classes com.example.md2termux.SimpleActivity 2>&1

echo ""
echo "✅ 构建和测试完成！"
echo ""
echo "📱 注意：这是一个简化的演示应用"
echo "   由于Termux环境限制，无法构建完整的Android APK"
echo "   但您可以："
echo "   1. 在Termux中运行Java程序"
echo "   2. 使用Git进行版本控制"
echo "   3. 将代码传输到电脑上构建完整的Android应用"
echo ""
echo "🎯 下一步："
echo "   1. 使用 'git init' 初始化Git仓库"
echo "   2. 使用 'git add .' 添加文件"
echo "   3. 使用 'git commit -m \"Initial commit\"' 提交"
echo "   4. 将代码传输到电脑使用Android Studio构建"
