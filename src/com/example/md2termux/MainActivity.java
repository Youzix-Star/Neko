package com.example.md2termux;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {

    private int counter = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 获取视图引用
        TextView titleText = findViewById(R.id.titleText);
        TextView counterText = findViewById(R.id.counterText);
        Button incrementButton = findViewById(R.id.incrementButton);
        Button resetButton = findViewById(R.id.resetButton);

        // 设置标题
        titleText.setText("Material Design 2 测试");

        // 增加按钮点击事件
        incrementButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter++;
                counterText.setText("计数器: " + counter);
                Toast.makeText(MainActivity.this, "计数器增加到: " + counter, Toast.LENGTH_SHORT).show();
            }
        });

        // 重置按钮点击事件
        resetButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter = 0;
                counterText.setText("计数器: " + counter);
                Toast.makeText(MainActivity.this, "计数器已重置", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
