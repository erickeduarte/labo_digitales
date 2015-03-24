wire[2:0] wCarry[2:0];
genvar CurrentRow, CurrentCol;
generate
for ( CurrentCol = 0; CurrentCol < `MAX_COLS; CurrentCol = CurrentCol + 1)
	begin : MUL_ROW
		for ( CurrentRow = CurrentCol; CurrentRow < `MAX_ROWS; CurrentRow = CurrentCol + 1)

			begin:
				////////////////////////////////////////////////////////
				// Case for the first row 
				if(CurrentRow == 0)
					begin 
						// First element of row
						if(CurrentRow == CurrentCol)
							begin
							end
						// Case for the last element of row
						else if (CurrentRow == `MAX_ROWS -	1)
							begin
							end
						// Case for all the other elements in row
						else 
							begin
							end
					end
				////////////////////////////////////////////////////////
				// Case for the last row
				else if (CurrentRow == `MAX_ROWS -1)
					begin
					end
				////////////////////////////////////////////////////////
				// Case for the rest
				else 
					begin
					end
				////////////////////////////////////////////////////////
			end
	end
endgenerate


A( (A[CurrentRow] & B[CurrentCol])
