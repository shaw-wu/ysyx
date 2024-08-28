module decode(x, en, y);
	input [3:0] x;
	input en;
	output reg [6:0] y;

	always @(x or en) begin
		if(en) begin
			case(x)
				4'b0000 : y = 7'b1000000;
				4'b0001 : y = 7'b1111001;
				4'b0010 : y = 7'b0100100;
				4'b0011 : y = 7'b0110000;
				4'b0100 : y = 7'b0011001;
				4'b0101 : y = 7'b0010010;
				4'b0110 : y = 7'b0000010;
				4'b0111 : y = 7'b1111000;
				4'b1000 : y = 7'b0000000;
				4'b1001 : y = 7'b0010000;
				4'b1010 : y = 7'b0001000;
				4'b1011 : y = 7'b0000011;
				4'b1100 : y = 7'b1000110;
				4'b1101 : y = 7'b0100001;
				4'b1110 : y = 7'b0000110;
				4'b1111 : y = 7'b0001110;
				default : y = 7'b1111111;
			endcase
		end
		else y = 7'b1111111;
	end
endmodule;

module kbd7seg(data, hex0, hex1, hex2, hex3);
	input [7:0] data;
	output reg [6:0] hex0,hex1,hex2,hex3;
  
		wire [6:0] zer,one,two,thr,fou,fin,six,sev,eig,nin,a,b,c,d,e,f;
    decode i0  (4'b0000,1,zer);
    decode i1  (4'b0001,1,one);
    decode i2  (4'b0010,1,two);
    decode i3  (4'b0011,1,thr);
    decode i4  (4'b0100,1,fou);
    decode i5  (4'b0101,1,fin);
    decode i6  (4'b0110,1,six);
    decode i7  (4'b0111,1,sev);
    decode i8  (4'b1000,1,eig);
    decode i9  (4'b1001,1,nin);
    decode i10 (4'b1010,1,a);
    decode i11 (4'b1011,1,b);
    decode i12 (4'b1100,1,c);
    decode i13 (4'b1101,1,d);
    decode i14 (4'b1110,1,e);
    decode i15 (4'b1111,1,f);

	
	always @(*) begin
		hex0 = 7'b1111111 ; hex1 = 7'b1111111; hex2 = 7'b1111111; hex3 = 7'b1111111;
		case(data)
			8'b00010101 : begin hex0 = sev; hex1 = one; hex2 = one; hex3 = fin; end//q 71 15
			8'b00011101 : begin hex0 = sev; hex1 = sev; hex2 = one; hex3 = d  ; end//w 77 1d
			8'b00100100 : begin hex0 = six; hex1 = fin; hex2 = two; hex3 = fou; end//e	65 24
			8'b00101101 : begin hex0 = sev; hex1 = two; hex2 = two; hex3 = d  ; end//r 72 2d
			8'b00101100 : begin hex0 = sev; hex1 = fou; hex2 = two; hex3 = c  ; end//t 74 2c
			8'b00110101 : begin hex0 = sev; hex1 = nin; hex2 = thr; hex3 = fin; end//y 79 35
			8'b00111100 : begin hex0 = sev; hex1 = fin; hex2 = thr; hex3 = c  ; end//u 75 3c
			8'b01000011 : begin hex0 = six; hex1 = nin; hex2 = fou; hex3 = thr; end//i 69 43
			8'b01000100 : begin hex0 = six; hex1 = f  ; hex2 = fou; hex3 = fou; end//o 6f 44
			8'b01001101 : begin hex0 = sev; hex1 = zer; hex2 = fou; hex3 = d  ; end//p 70 4d
			8'b00011100 : begin hex0 = six; hex1 = one; hex2 = one; hex3 = c  ; end//a 61 1c
			8'b00011011 : begin hex0 = sev; hex1 = thr; hex2 = one; hex3 = b  ; end//s 73 1b
			8'b00100011 : begin hex0 = six; hex1 = fou; hex2 = two; hex3 = thr; end//d 64 23
			8'b00101011 : begin hex0 = six; hex1 = six; hex2 = two; hex3 = b  ; end//f 66 2b
			8'b00110100 : begin hex0 = six; hex1 = sev; hex2 = thr; hex3 = fou; end//g 67 34
			8'b00110011 : begin hex0 = six; hex1 = eig; hex2 = thr; hex3 = thr; end//h 68 33
			8'b00111011 : begin hex0 = six; hex1 = a  ; hex2 = thr; hex3 = b  ; end//j 6a 3b
			8'b01000010 : begin hex0 = six; hex1 = b  ; hex2 = fou; hex3 = two; end//k 6b 42
			8'b01001011 : begin hex0 = six; hex1 = c  ; hex2 = fou; hex3 = b  ; end//l 6c 4b
			8'b00011010 : begin hex0 = sev; hex1 = a  ; hex2 = one; hex3 = a  ; end//z 7a 1a
			8'b00100010 : begin hex0 = sev; hex1 = eig; hex2 = two; hex3 = two; end//x 78 22
			8'b00100001 : begin hex0 = six; hex1 = thr; hex2 = two; hex3 = one; end//c 63 21
			8'b00101010 : begin hex0 = sev; hex1 = six; hex2 = two; hex3 = a  ; end//v 76 2a
			8'b00110010 : begin hex0 = six; hex1 = two; hex2 = thr; hex3 = two; end//b 62 32
			8'b00110001 : begin hex0 = six; hex1 = e  ; hex2 = thr; hex3 = one; end//n 6e 31
			8'b00111010 : begin hex0 = six; hex1 = d  ; hex2 = thr; hex3 = a  ; end//m 6d 3a
			8'b00010110 : begin hex0 = thr; hex1 = one; hex2 = one; hex3 = six; end//1 31 16
			8'b00011110 : begin hex0 = thr; hex1 = two; hex2 = one; hex3 = e  ; end//2 32 1e
			8'b00100110 : begin hex0 = thr; hex1 = thr; hex2 = two; hex3 = six; end//3 33 26
			8'b00100101 : begin hex0 = thr; hex1 = fou; hex2 = two; hex3 = fin; end//4 34 25
			8'b00101110 : begin hex0 = thr; hex1 = fin; hex2 = two; hex3 = e  ; end//5 35 2e
			8'b00110110 : begin hex0 = thr; hex1 = six; hex2 = thr; hex3 = six; end//6 36 36
			8'b00111101 : begin hex0 = thr; hex1 = sev; hex2 = thr; hex3 = d  ; end//7 37 3d
			8'b00111110 : begin hex0 = thr; hex1 = eig; hex2 = thr; hex3 = e  ; end//8 38 3e
			8'b01000110 : begin hex0 = thr; hex1 = nin; hex2 = fou; hex3 = six; end//9 39 46
			8'b01000101 : begin hex0 = thr; hex1 = zer; hex2 = fou; hex3 = fin; end//0 30 45
			default : begin  hex0 = 7'b1111111 ; hex1 = 7'b1111111; hex2 = 7'b1111111; hex3 = 7'b1111111; end
		endcase
	end
endmodule
