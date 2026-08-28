package com.example.md2termux;

import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private int counter = 0;
    private TextView counterText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 获取视图引用
        counterText = findViewById(R.id.counterText);
        Button incrementButton = findViewById(R.id.incrementButton);
        Button resetButton = findViewById(R.id.resetButton);

        // 设置点击事件
        incrementButton.setOnClickListener(v -> {
            counter++;
            counterText.setText("计数器: " + counter);
            Toast.makeText(this, "计数器增加到: " + counter, Toast.LENGTH_SHORT).show();
        });

        resetButton.setOnClickListener(v -> {
            counter = 0;
            counterText.setText("计数器: " + counter);
            Toast.makeText(this, "计数器已重置", Toast.LENGTH_SHORT).show();
        });
    }
}
