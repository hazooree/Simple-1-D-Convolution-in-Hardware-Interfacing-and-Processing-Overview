`timescale 1ns / 1ps
module XilinxAssignment3(clk, Reset_in, Test, Test_Result,valid, invalid, finish, packet_Done,reset,ready,Y,HS_out,count,count1,avrg);
input clk, Test, Reset_in;
output Test_Result,
valid, invalid, finish, packet_Done,reset,ready;
output [15:0]Y,HS_out;
output [8:0]count;
output [3:0]count1;
output [15:0]avrg;
wire clk_DAQ;
wire [15:0] Data_in, Data;
wire Valid, Invalid, Finish, Packet_Done;
wire Reset,Ready;
assign valid=Valid;
assign invalid=Invalid;
assign finish=Finish;
assign packet_Done=Packet_Done;
assign reset=Reset;
assign ready=Ready;
assign Y=Data;
DAQ DataAcquisition(
.Ready(Ready),
.Packet_Done(Packet_Done),
.clk(clk),
.Valid(Valid),
.clk_DAQ(clk_DAQ),
.Data_in(Data_in));
IPU InterfacingProcessing(
.Reset(Reset),
.clk_in(clk),
.Valid(Valid), .Test(Test), .X(Data_in),
.Invalid(Invalid),
.Test_Result(Test_Result), .Finish(Finish),
.Ready(Ready), .Packet_Done(Packet_Done), .Y(Data),
.count(count),.count1(count1),.avrg(avrg));
HS HostSystem(.Reset_in(Reset_in),
.Packet_Done(Packet_Done),
.clk_DAQ(clk), .Invalid(Invalid),
.Finish(Finish), .Data(Data), .Reset(Reset),
.out(HS_out));
endmodule

module DAQ(
input Ready,
input Packet_Done,
input clk,
output reg Valid,
output clk_DAQ,
output reg [15:0] Data_in);
       reg [15:0]memoryx[0:383];
       reg [8:0]counter;
initial
       begin
              $readmemb("ExtraFiles/memoryx.list",memoryx);
       end
         assign clk_DAQ  = clk;
always @(posedge clk or posedge Ready)
       begin
       if(Ready)
              begin
                  Valid = 1;
               Data_in=memoryx[counter];
                  if(counter==384)
                begin
              counter<=0;
                  end
                  else
              counter<=counter+1;
               end
       else
                begin
              counter<=0;
				  Valid = 0;
                  end
       end
endmodule
module IPU(
input Reset,
input clk_in,
input Valid, Test,
input [15:0]X,
output reg Invalid,
output reg Test_Result,
output reg Finish,
output reg Ready,
output reg Packet_Done,
output [15:0]Y,
output [8:0]count,
output [3:0]count1,
output [15:0]avrg
);
assign avrg = avg;
parameter Reset_Waiting_state=2'b00,
             processing_state=2'b01,
             Freeze_state=2'b10,
             Finish_state=2'b11;
reg [15:0]avg;
reg [8:0]counter;
reg [3:0]counter1;
reg [2:0] next_state;
reg [2:0] present_state;
assign count=counter;
assign count1=counter1;
always @(posedge clk_in or posedge Reset)
   begin
      if(Reset)
        begin
         present_state <= Reset_Waiting_state;
         counter<=1;
         counter1<=1;
      end
      else
        begin
         present_state<=next_state;
         if(Valid)
            begin
           if(counter==384)
              counter<=1;
           else
              counter<=counter+1;

           if(counter1==12)
              counter1<=1;
           else
              counter1<=counter1+1;
         end
         else
            begin
            counter1<=counter1;
            counter<=counter;
         end
      end
   end
always@(present_state,Valid,Reset,counter,counter1,Finish,avg)
   begin
     case(present_state)

          Reset_Waiting_state:
          begin
          if(Valid)
                next_state=processing_state;
             else
                next_state=Reset_Waiting_state;
          end
          processing_state:
          begin
             if(Reset)
                next_state=Reset_Waiting_state;
             else begin
                 if(!Valid)
                next_state=Freeze_state;
             else
                 next_state=processing_state;
                 if(counter==384)
                next_state=Finish_state;  
                end
          end
         
             Freeze_state:
          begin
             if(Reset)
                next_state=Reset_Waiting_state;
             else
                 begin
                if(!Valid)
                   next_state=Freeze_state;
                else
                   next_state=processing_state;
                end
          end
             Finish_state:
          begin
                 if(Reset)
                next_state=Reset_Waiting_state;
                 else
                 next_state=Finish_state;
                 end
             default:
          begin
             next_state=Reset_Waiting_state;
          end
      endcase
   end
FIR #(16,16,16,6)FinitImpulse(X,clk_in,Reset,Y,Valid);
always @(present_state,Y,avg,Finish,counter1,Test)
   begin
      case(present_state)
          Reset_Waiting_state:
        begin
             avg=0;
           Packet_Done= 0;
           Invalid = 1;
           Finish = 0;
           Ready = 1;
              Test_Result=0;
        end
          processing_state:
        begin
        if(Valid) begin
          Invalid=!Valid;
          avg=(Y+avg)>>1;
              if(counter1==12)
              Packet_Done=1;
           else
              Packet_Done=0;
              if(Test==0)
              Test_Result=0;
           else
              Test_Result=Test&(Y>avg);
              Ready = 1;
        end
          else begin
          Invalid=Valid;
          end
          end
          Freeze_state:
        begin
           Invalid=!Valid;
           if(Valid) begin
              Ready=1;
                  end
           else begin
              Ready=0;
                  end
        end
          Finish_state:
        begin
           Finish = 1;
           Ready = 0;
        end
    endcase
   end
endmodule
module FIR #(parameter IPL=16,parameter CEL=16,parameter OPL=16,parameter IPD=6)(X,clk,Reset,Y,Valid);
input [(IPL-1):0]X;
input clk,Reset,Valid;
output [(OPL-1):0]Y;
reg [CEL-1:0]memoryh[0:IPD-1];
initial begin
$readmemb("ExtraFiles/memoryh.list",memoryh);
end
integer k,j;
reg [(IPL-1):0]Xn[0:(IPD-1)];
reg [31:0]Temp;
assign Y=Temp[23:8];
always @(posedge clk)
begin 
   Temp=memoryh[0]*Xn[0];
    for (k=1; k <= IPD-1; k = k + 1)
      Temp= Temp + memoryh[k]*Xn[k];
end
always @(posedge clk or posedge Reset) begin
if(Reset) begin
for (j=(IPD-1); j>=0; j = j - 1)
Xn[j] <= 0;
end
else begin
if(Valid) begin
for (j=(IPD-1); j>=1; j = j - 1)
Xn[j] <= Xn[j-1];
Xn[0] <= X;
end
end end
endmodule



module HS(
input Reset_in,
input Packet_Done,
input clk_DAQ,
input Invalid,
input Finish,
input [15:0]Data,out,
output Reset);
assign Reset = Reset_in;
assign out=Data;
integer file,k;
always @(posedge clk_DAQ or posedge Reset_in)
begin
     if(Reset_in) begin
      file = $fopen("ExtraFiles/memoryy.list","w");
     end else
       begin
        if(!Invalid)
          begin
          if(Finish)
              $fclose(file);
          else begin
              $fwrite(file,"%b\n",Data);
        end
          end
    end
end
endmodule