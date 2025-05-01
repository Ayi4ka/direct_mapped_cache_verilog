// ----------------------------
// Прямоассоциативный кэш (Direct-Mapped Cache)
// Блок на Verilog для симуляции простейшего кэша с 4 строками
// ----------------------------

module direct_mapped_cache (
    input clk,                   // Тактовый сигнал
    input rst,                   // Сброс (синхронный)

    input        read_en,        // Разрешение чтения
    input        write_en,       // Разрешение записи
    input [3:0]  addr,           // 4-битный адрес (разбит на tag + index)
    input [7:0]  write_data,     // Данные для записи
    output reg [7:0] read_data,  // Данные на чтение
    output reg       hit         // Флаг cache hit (1 - нашли; 0 - промах)
);

    // Параметры кэша
    localparam NUM_LINES   = 4;       // Количество строк кэша
    localparam INDEX_BITS  = 2;       // Число бит для индекса (log2(4) = 2)
    localparam TAG_BITS    = 2;       // Остальные биты адреса - тег

    // Основные массивы для хранения данных и служебной информации
    reg [7:0] data_array [0:NUM_LINES-1];          // Основное хранилище данных
    reg [TAG_BITS-1:0] tag_array [0:NUM_LINES-1];  // Массив тегов
    reg valid_array [0:NUM_LINES-1];               // Массив валид-битов (1 = строка содержит валидные данные)

    // Декодирование адреса: выделяем индекс и тег
    wire [INDEX_BITS-1:0] index;  // Индекс (указывает на строку кэша)
    wire [TAG_BITS-1:0] tag;      // Тег (идентифицирует "содержимое")

    assign index = addr[INDEX_BITS-1:0];   // Младшие 2 бита адреса - индекс строки
    assign tag   = addr[3:INDEX_BITS];     // Старшие 2 бита адреса - тег

    // Чтение из кэша (комбинаторная логика)
    always @* begin
        read_data = 8'b0;  // По умолчанию обнуляем выход
        hit = 0;           // По умолчанию - промах

        if (read_en) begin
            // Проверяем: есть ли валидные данные и совпадает ли тег
            if (valid_array[index] && (tag_array[index] == tag)) begin
                read_data = data_array[index];  // Отдаём данные из кэша
                hit = 1;                        // Успех (cache hit)
            end
            // Иначе остаётся read_data = 0 и hit = 0
        end
    end

    // Запись в кэш + обработка сброса (синхронная логика)
    integer i;  // Переменная для цикла сброса

    always @(posedge clk) begin
        if (rst) begin
            // Сброс всех строк кэша (valid=0, data=0, tag=0)
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                valid_array[i] <= 0;
                data_array[i] <= 0;
                tag_array[i] <= 0;
            end
        end else if (write_en) begin
            // Запись новых данных в кэш
            data_array[index] <= write_data;      // Обновляем данные по адресу
            tag_array[index]  <= tag;             // Обновляем тег для строки
            valid_array[index] <= 1;              // Строка теперь валидна
            // hit тут не трогаем, он важен только для чтения
        end
    end

endmodule
