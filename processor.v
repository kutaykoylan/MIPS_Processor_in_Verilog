module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
sjump,//output of shift left 2 unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,//Output of shift left 2 unit
out5,// Output of mux with jump control-mul5
out8;// Output of mux with jr control-mul8

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
outbgtez; // out for bgtez mux

wire [31:0] jump32bit; //wireforjump

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [25:0] inst25_0;	//25-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,branchNotEqual,jump,jumpAndLink,
branchGreaterThanZero,branchLessThanZero,branchLessThanEqualToZero,branchGreaterThanEqualToZero,jumpRegister,jrsrc,sign;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst25_0=instruc[25:0];


// registers
assign dataa=registerfile[inst25_21];//Read register 1
assign datab=outbgtez;//Read register 2//I changed it because of bgez instruction
always @(posedge clk)
 registerfile[out1]= regwrite ? out3:registerfile[out1];//Write data to register//
always @(posedge clk)
 registerfile[31]=jumpAndLink?adder1out:registerfile[31];//Write data to register for jal Instruction

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};
//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux for branchGreaterThanEqualToZero
mult2_to_1_5  mult9(outbgtez, registerfile[inst20_16] ,5'b0000,branchGreaterThanEqualToZero);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//mux for jump instruction//I ADDED!!
mult2_to_1_32 mult5(out5, out4,jump32bit,jump);

//mux for jr instruction pc//I ADDED!!
mult2_to_1_32 mult8(out8, out5,dataa,jrsrc);

// load pc
always @(posedge clk)
pc=out8;//first I changed ıt to out5(j/jal) then out8(jr) , firstly it was out4.

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,branchNotEqual,jump,jumpAndLink,branchGreaterThanZero,branchLessThanZero,
branchLessThanEqualToZero,branchGreaterThanEqualToZero);

//Sign extend unit
signext sext(instruc[15:0],extad);

//Second sign extend unit for jump//I ADDED this one
shift shift2_2(sjump,inst25_0);

//ALU control unit
//alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout,instruc[31:26]);//I added instruc

//Shift-left 2 unit
shift shift2(sextad,extad);

//I added for jump ınstruction's wire concatination operation
wire [3:0] tempJump;
assign jump32bit= {pc[31:28],sjump};
assign jumpRegister = regdest;// I did this because of the limit of the number of ports of the component
assign sign = sum[31];
//AND gate for pcsrc (branch Instructions) and jrsrc (jr instruction)
assign pcsrc=(branch && zout)|(branchNotEqual && (~zout))|(branchGreaterThanZero&&(~zout)&&(~sign))|(branchLessThanEqualToZero&&(zout|sign))|(branchLessThanZero&&(~zout)&&sign&&(~instruc[16]))|(branchGreaterThanEqualToZero&&(zout|(~sign))&&instruc[16]); 
assign jrsrc = jumpRegister && ((~instruc[5])&&(~instruc[4])&&instruc[3]&&(~instruc[2])&&(~instruc[1])&&(~instruc[0])) ;//bitwise ile full farkı
//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

