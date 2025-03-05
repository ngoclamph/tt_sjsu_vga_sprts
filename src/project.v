`default_nettype none

module tt_um_sprts(
    input wire clk,           // Clock signal
    input wire rst_n,         // Reset signal (active low)
    output wire hsync,        // Horizontal sync signal
    output wire vsync,        // Vertical sync signal
    output wire [2:0] rgb     // RGB color signals
);

    wire [9:0] x;             // Current x position
    wire [9:0] y;             // Current y position
    wire video_active;        // Video active signal

    // VGA timing parameters for 640x480 at 60Hz
    localparam H_ACTIVE = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH = 48;
    localparam H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    localparam V_ACTIVE = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH = 33;
    localparam V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count < H_TOTAL - 1)
                h_count <= h_count + 1;
            else begin
                h_count <= 0;
                if (v_count < V_TOTAL - 1)
                    v_count <= v_count + 1;
                else
                    v_count <= 0;
            end
        end
    end

    assign hsync = (h_count >= H_ACTIVE + H_FRONT_PORCH) && (h_count < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE);
    assign vsync = (v_count >= V_ACTIVE + V_FRONT_PORCH) && (v_count < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE);
    assign video_active = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

    assign x = h_count;
    assign y = v_count;

    // Generate RGB signals
    reg [2:0] rgb_reg;
    assign rgb = video_active ? rgb_reg : 3'b000;

    always @(*) begin
        rgb_reg = 3'b000;

        // Draw sun (a yellow circle at the top right corner)
        if ((x - 550)*(x - 550) + (y - 100)*(y - 100) <= 1600) begin
            rgb_reg = 3'b110; // Yellow
        end
        // Draw grass (a green rectangle at the bottom)
        else if (y >= 380) begin
            rgb_reg = 3'b010; // Green
        end
        // Draw tree trunk (a brown rectangle at the center bottom)
        else if ((x >= 300 && x < 340) && (y >= 300 && y < 380)) begin
            rgb_reg = 3'b100; // Brown (Red + Green)
        end
        // Draw tree leaves (a green circle above the trunk)
        else if ((x - 320)*(x - 320) + (y - 250)*(y - 250) <= 2500) begin
            rgb_reg = 3'b010; // Green
        end
        // Draw sky (a blue background)
        else begin
            rgb_reg = 3'b001; // Blue
        end
    end
endmodule
