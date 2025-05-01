module direct_mapped_cache (
    input clk,
    input rst,

    input        read_en,
    input        write_en,
    input [3:0]  addr,
    input [7:0]  write_data,
    output reg [7:0] read_data,
    output reg       hit
);

    // Параметры
    localparam NUM_LINES = 4;        // Кол-во строк в кэше
    localparam INDEX_BITS = 2;       // log2(NUM_LINES)
    localparam TAG_BITS = 2;

    // Внутренние структуры
    reg [7:0] data_array [0:NUM_LINES-1];          // данные
    reg [TAG_BITS-1:0] tag_array [0:NUM_LINES-1];  // теги
    reg valid_array [0:NUM_LINES-1];               // valid-бит

    // Выделим индекс и тег из адреса
    wire [INDEX_BITS-1:0] index;
    wire [TAG_BITS-1:0] tag;

    assign index = addr[INDEX_BITS-1:0];   // младшие биты = index
    assign tag   = addr[3:INDEX_BITS];     // старшие биты = tag

    always @* begin
        if (read_en) begin
            if (valid_array[index] && (tag_array[index] == tag)) begin
                read_data = data_array[index];  // читаем данные
                hit = 1;                        // нашли = hit
            end else begin
                read_data = 8'b0;               // нет данных (по желанию)
                hit = 0;                        // промах
            end
        end else begin
            read_data = 8'b0;                   // если чтения нет
            hit = 0;
        end
    end

endmodule
