module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,branchNotEqual,jump,jumpAndLink,
	branchGreaterThanZero,branchLessThanZero,branchLessThanEqualToZero,branchGreaterThanEqualToZero);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,branchNotEqual,jump,jumpAndLink,
branchGreaterThanZero,branchLessThanZero,branchLessThanEqualToZero,branchGreaterThanEqualToZero;////I added
wire rformat,lw,sw,beq,bne,addi,andi,ori,j,jal,bgtz,blez,bltz,bgez;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign bne=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&in[0] ;//I added
assign j= ~in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&(~in[0]) ;//I added
assign addi= ~in[5]& (~in[4])&in[3]&(~in[2])&(~in[1])&(~in[0]) ;//I added
assign andi = ~in[5]& (~in[4])&in[3]&in[2]&~(in[1])&~(in[0]) ;//I added
assign ori =  ~in[5]& (~in[4])&in[3]&in[2]&(~in[1])&in[0] ;//I added
assign jal  = ~in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];//I added
assign bgtz =  ~in[5]& (~in[4])&(~in[3])&in[2]&in[1]&in[0];//I added
assign blez =  ~in[5]& (~in[4])&(~in[3])&in[2]&in[1]&(~in[0]);//I added
assign bltz =  ~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&in[0];//I added
assign bgez =  ~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&in[0];//I added
assign branchGreaterThanZero = bgtz ;//I added
assign branchLessThanEqualToZero = blez;//I added
assign branchLessThanZero = bltz;//I added
assign branchGreaterThanEqualToZero =bgez ;//I added
assign regdest=rformat;
assign alusrc=lw|sw|addi|andi|ori;//I added for addi,andi,ori
assign memtoreg=lw;
assign regwrite=rformat|lw|addi|andi|ori;//I added for addi,andi,ori
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat;
assign aluop0=beq|bne|addi|andi|ori|bgtz|blez|bltz|bgez;// I added for bne,addi,andi,ori,bgtz,bltz,bgez,blez
assign branchNotEqual=bne;//I added
assign jump=j|jal;//I added
assign jumpAndLink = jal ;//I added
endmodule
