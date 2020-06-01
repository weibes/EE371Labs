/*
 * Black-and-white VGA Framebuffer
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *            _______________              ________
 * __________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 *
 * Inputs:
 *   clk50          - should be connected to a 50 MHz clock
 *   reset          - resets the module
 *   x              - x coordinate of the pixel
 *   y              - y coordinate of the pixel
 *   pixel_color    - color of the pixel, black or white
 *   pixel_write    - write to the pixel or not
 *
 * Outputs:
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 		    - Blue data of the VGA connection
 *   VGA_CLK        - VGA's clock signal
 *   VGA_HS         - Horizontal Sync of the VGA connection
 *   VGA_VS         - Vertical Sync of the VGA connection
 *   VGA_BLANK_n    - Blanking interval of the VGA connection
 *   VGA_SYNC_n     - Enable signal for the sync of the VGA connection
 */
module VGA_framebuffer(clk50, reset, x, y, pixel_color, pixel_write, 
    VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);
    
    parameter   HACTIVE      = 11'd 1280,
                HFRONT_PORCH = 11'd 32,
                HSYNC        = 11'd 192,
                HBACK_PORCH  = 11'd 96,   
                HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; //1600

    parameter   VACTIVE      = 10'd 480,
                VFRONT_PORCH = 10'd 10,
                VSYNC        = 10'd 2,
                VBACK_PORCH  = 10'd 33,
                VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; //525
    
    input logic clk50, reset;
    input logic [10:0] x, y; // Pixel coordinates
    input logic pixel_color, pixel_write;		       
    output logic [7:0] VGA_R, VGA_G, VGA_B;
    output logic VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n;

    logic [10:0] hcount; // Horizontal counter
    logic endOfLine;
    logic [9:0] vcount; // Vertical counter
    logic endOfField;
    logic blank;
    logic framebuffer [307199:0]; // Framebuffer memory: 640 x 480 = 307200 bits
    logic [18:0] read_address, write_address;
    logic pixel_read;

    always_ff @(posedge clk50 or posedge reset)
        if (reset)          hcount <= 0;
        else if (endOfLine) hcount <= 0;
        else  	         hcount <= hcount + 11'd 1;

    assign endOfLine = hcount == HTOTAL - 1;

    always_ff @(posedge clk50 or posedge reset)
        if (reset)              vcount <= 0;
        else if (endOfLine)
            if (endOfField)     vcount <= 0;
            else                vcount <= vcount + 10'd 1;

    assign endOfField = vcount == VTOTAL - 1;

    // Horizontal sync: from 0x520 to 0x57F
    // 101 0010 0000 to 101 0111 1111
    assign VGA_HS = !( (hcount[10:7] == 4'b1010) & (hcount[6] | hcount[5]));
    assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);
    assign VGA_SYNC_n = 1; // For adding sync to video signals; not used for VGA

    // Horizontal active: 0 to 1279     Vertical active: 0 to 479
    // 101 0000 0000  1280	       01 1110 0000  480	       
    // 110 0011 1111  1599	       10 0000 1100  524
    assign blank = ( hcount[10] & (hcount[9] | hcount[8]) ) | ( vcount[9] | (vcount[8:5] == 4'b1111) );
    assign write_address = x + (y << 9) + (y << 7) ; // x + y * 640
    assign read_address = (hcount >> 1) + (vcount << 9) + (vcount << 7);

    always_ff @(posedge clk50) 
    begin
        if (pixel_write) 
            framebuffer[write_address] <= pixel_color;
        if (hcount[0]) 
        begin
            pixel_read <= framebuffer[read_address];
            VGA_BLANK_n <= ~blank; // Keep blank in sync with pixel data
        end //if (hcount[0])
    end //always_ff @(posedge clk50) 

    assign VGA_CLK = hcount[0]; // 25 MHz clock: pixel latched on rising edge
    assign {VGA_R, VGA_G, VGA_B} = pixel_read ? 24'hFF_FF_FF : 24'h0;

endmodule //VGA_framebuffer
