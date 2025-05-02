`timescale 1ns/1ps

module tb_direct_mapped_cache;

    // Тестовые сигналы
    reg clk;
    reg rst;
    reg read_en;
    reg write_en;
    reg [3:0] addr;
    reg [7:0] write_data;
    wire [7:0] read_data;
    wire hit;

    // Инстанцируем тестируемый модуль
    direct_mapped_cache dut (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data),
        .hit(hit)
    );

    // Генерация тактового сигнала (10нс период)
    always begin
        #5 clk = ~clk;
    end

    // Тестовый сценарий
    initial begin
        $display("=== Старт теста direct_mapped_cache ===");
        clk = 0;
        rst = 1;
        read_en = 0;
        write_en = 0;
        addr = 0;
        write_data = 0;

        // --- Сброс ---
        #10;
        rst = 0;

        // === Случай 1: Чтение из пустого кэша ===
        $display("Случай 1: Чтение из пустого кэша (адрес 0b0000)");
        addr = 4'b0000;
        read_en = 1;
        #10;  // ждём такт
        if (hit == 0 && read_data == 0)
            $display("PASS: Miss ожидаемо");
        else
            $display("FAIL: Ошибка при чтении из пустого кэша");

        read_en = 0;

        // === Случай 2: Запись данных ===
        $display("Случай 2: Запись в кэш (адрес 0b0000, данные 0xAB)");
        addr = 4'b0000;
        write_data = 8'hAB;
        write_en = 1;
        #10;
        write_en = 0;

        // === Случай 3: Чтение после записи ===
        $display("Случай 3: Чтение после записи (адрес 0b0000)");
        read_en = 1;
        #10;
        if (hit == 1 && read_data == 8'hAB)
            $display("PASS: Hit и правильные данные");
        else
            $display("FAIL: Ошибка при чтении после записи");

        read_en = 0;

        // === Случай 4: Другой тег, тот же индекс ===
        $display("Случай 4: Чтение по другому тегу (адрес 0b1000)");
        addr = 4'b1000;  // тег изменился, но индекс тот же (индекс = 00)
        read_en = 1;
        #10;
        if (hit == 0)
            $display("PASS: Miss (тег не совпал)");
        else
            $display("FAIL: Ошибка, ожидался miss");

        read_en = 0;

        // === Случай 5: Проверка сброса ===
        $display("Случай 5: Сброс");
        rst = 1;
        #10;
        rst = 0;
        addr = 4'b0000;
        read_en = 1;
        #10;
        if (hit == 0)
            $display("PASS: После сброса промах ожидаем");
        else
            $display("FAIL: Ошибка, после сброса не должно быть hit");

        read_en = 0;

        $display("=== Тест завершён ===");
        $stop;
    end

endmodule
