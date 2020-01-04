module alucont(aluop1,aluop0,f3,f2,f1,f0,gout,in);//Figure 4.12 //I added in
input [5:0] in,aluop1,aluop0,f3,f2,f1,f0;//I added in
output [2:0] gout;
reg [2:0] gout;
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=3'b010;//for lw/sw
if(aluop0)//(aluop2)
begin
	gout=3'b110;//(sub) for branch
	if(~in[5]& (~in[4])&in[3]&(~in[2])&(~in[1])&(~in[0]))gout=3'b010 ;//I added(addi) control=010 (add)
	if(~in[5]& (~in[4])&in[3]&in[2]&(~in[1])&(~in[0]))gout=3'b000 ;//I added(andi) control=000
	if(~in[5]& (~in[4])&in[3]&in[2]&(~in[1])&in[0]) gout=3'b001;//I added (ori) control=001
end
if(aluop1)//R-type (aluop1)
begin
	if (~(f3|f2|f1|f0))gout=3'b010; 	//function code=0000,ALU control=010 (add)
	if (f1&f3)gout=3'b111;			//function code=1x1x,ALU control=111 (set on less than)
	if (f1&~(f3))gout=3'b110;		//function code=0x10,ALU control=110 (sub)
	if (f2&f0)gout=3'b001;			//function code=x1x1,ALU control=001 (or)
	if (f2&~(f0))gout=3'b000;		//function code=x1x0,ALU control=000 (and)
	if(~(f3)&f2&f1&f0)gout=3'b100;	//function code=0111,ALU control=100 (nor)
end
end
endmodule
