`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:37:46 12/01/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze(
input  clk,
input [maze_width - 1:0]  starting_col, starting_row, 	// indicii punctului de start
input  maze_in, 			// ofera informa?ii despre punctul de coordonate [row, col]
output reg [maze_width - 1:0] row, col,	 		// selecteaza un rând si o coloana din labirint
output reg  maze_oe,			// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
output reg  maze_we, 			// write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
output reg	done);		 	// ie?irea din labirint a fost gasita; semnalul ramane activ 
 
 
`define up 0
`define right 1
`define down 2
`define left 3
	 
parameter maze_width = 6;
reg [1:0] direction ;
reg [maze_width - 1:0] last_col;
reg [maze_width - 1:0] last_row;

`define start 4
`define where_to_go 5
`define testing_direction 6
`define testing_right_direction 7
`define checking_right_direction 8
`define testing_up_direction 9
`define checking_up_direction 10
`define decision 11
`define final 12

reg [4:0] state = `start, state_next;


always @(posedge clk) begin
      state <= `start;
    if(!done)
        state <= state_next;
	end

always @(*) begin

	maze_oe=0;
	maze_we=0;
	done=0;
	
	case(state)
		
		`start: begin 
		
				row = starting_row; //imi marchez startul cu pozitiile mentionate
				col = starting_col;
				
				direction = `up; //aleg ca prima directie in care ma deplasez este in sus
				
				maze_we = 1;
				state_next = `where_to_go;				
		
		end
		
		`where_to_go: begin
		
		last_col = col; //salvez cele doua pozitii anterioare ca in cazul in care intalnesc un perete sa ma intoc inapoi si sa schimb directia de deplasare
		last_row = row;
		
				if( direction == 0 ) begin
					col = col + 1;
				end
				
				if( direction == 1 ) begin
					row = row + 1;
				end
				
				if( direction == 2 ) begin
					col = col - 1;
				end
				
				if( direction == 3 ) begin
					row = row - 1;
				end
				
				maze_oe = 1;
				state_next = `testing_direction;
		
		end 
		
		`testing_direction: begin
		
		if (maze_in == 0) begin //daca am in fata 0, imi continui drumul schimband directia de deplasare catre dreapta
			
			maze_we = 1;
			state_next = `testing_right_direction; 
			
		end
		
		else begin //totusi, daca am in fata un zid, ma reintorc la cele doua pozitii salvate anterior si efectuez o rotatie de 90 grade catre dreapta
		
		col = last_col;
		row = last_row;
		
		direction = direction + 1; //efectuez rotatia de 90
	
		state_next = `where_to_go; //ma reintorc in starea anterioara ca sa aleg o alta directie
      
		end
      end
			
	 `testing_right_direction: begin //efectuez deplasarea catre dreapta 
		
		last_col = col;
		last_row = row; 
		
				if( direction == 0 ) begin
					col = col + 1;
				end
				
				if( direction == 1 ) begin
					row = row + 1;
				end
				
				if( direction == 2 ) begin
					col = col - 1;
				end
				
				if( direction == 3 ) begin
					row = row - 1;
				end
				
			maze_oe=1;
			state_next =`checking_right_direction;
		
		end
		
		`checking_right_direction: begin //verific daca am perete si stabilesc ce fac in acel caz
			
			if(maze_in == 0) begin
			   
				 direction = direction + 1; //daca am gasit 0 modific directia de deplasare incat sa corespunda cu deplasarea catre dreapta 
				 maze_we = 1;
				 state_next = `decision; //verific daca am ajuns la marginea labirintului si ies
				 
			end
			else begin
			
				row = last_row;
				col = last_col;
				state_next = `testing_up_direction; //daca am zid, ma intorc si ma deplasez inainte
			
			end
		end
		
		`testing_up_direction: begin
		
		 last_col = col;
		 last_row = row;  
			  
			  if( direction == 0 ) begin
					row = row - 1;
				end
				
				if( direction == 1 ) begin
					col = col + 1;
				end
				
				if( direction == 2 ) begin
					row = row + 1;
				end
				
				if( direction == 3 ) begin
					col = col - 1;
				end
		
			maze_oe=1;
			state_next =`checking_up_direction;
		
		end 
		
		`checking_up_direction: begin
			
			if(maze_in == 0) begin
				 maze_we = 1;
			end
			else begin
			
			row = last_row;
			col = last_col;
			direction = direction + 2; //daca in directia noii deplasari gasesc un zid, ma reintorc si fac o rotatie de 180 grade
			
			end
			
			state_next = `decision;
		
		end
		

    `decision: begin
			
			if( (col == 0 || col == 63 || row == 0 || row == 63) && maze_in == 0 ) begin //verific daca ma aflu la capatul labirintului si ies
			
			maze_we = 1;
			state_next = `final;
			
			end
			
			else begin
			
			state_next = `testing_right_direction; //altfel incerc din nou, reluand pasii anteriori
			
			end
		end
	 
	  `final: begin
			
			done = 1;
	  
		end
	  

	endcase
		
end

endmodule