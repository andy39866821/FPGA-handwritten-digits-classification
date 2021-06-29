module pixel_gen(
   input rst,
   input valid,
   input in_canvas,
   input enable_mouse_display,
   input [11:0] mouse_pixel,
   input canvas_pixel,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue
);
   


    always@(*) begin
        if(!valid) begin
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
        end 
        else if(enable_mouse_display) begin
            {vgaRed, vgaGreen, vgaBlue} = mouse_pixel;
        end 
        else if(in_canvas)begin
            {vgaRed, vgaGreen, vgaBlue} = (canvas_pixel ? 12'h000:12'hfff);
        end
        else begin
            {vgaRed, vgaGreen, vgaBlue} = 12'habc;
        end
    end


endmodule
