package com.example.md2termux;

public class SimpleApp {
    private int counter = 0;
    
    public void increment() {
        counter++;
        System.out.println("计数器增加到: " + counter);
    }
    
    public void reset() {
        counter = 0;
        System.out.println("计数器已重置");
    }
    
    public int getCounter() {
        return counter;
    }
    
    public static void main(String[] args) {
        SimpleApp app = new SimpleApp();
        
        System.out.println("Material Design 2 测试应用");
        System.out.println("========================");
        System.out.println("这是一个在Termux中构建的简单应用");
        System.out.println("");
        
        // 模拟用户交互
        System.out.println("1. 增加计数器");
        app.increment();
        
        System.out.println("2. 再次增加计数器");
        app.increment();
        
        System.out.println("3. 增加计数器");
        app.increment();
        
        System.out.println("4. 重置计数器");
        app.reset();
        
        System.out.println("");
        System.out.println("当前计数: " + app.getCounter());
        System.out.println("");
        System.out.println("✅ 应用运行成功！");
    }
}
