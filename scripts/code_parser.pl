#! /usr/bin/perl

# ---- File: code_parser.pl 
# ---- By: Fabian Melendez - fabmelb@gmail.com
# ------- 
# ------- This script parses code files and output a ROM module definition
# ------- 

########################################################################
########## Libraries needed
use Getopt::Long; # For reading command line arguments
use strict; 
use warnings;

########################################################################
########## Variables needed

my $line_counter = 0; # Counter for number of lines
my $code_dh; # File handle for code file
my $code_file; # Code file name
my $output_file; # Output file name
my $inst_counter = 0; # Counter for number of instructions
my $instructions; # String with instructions in correct format
my $definitions; # Definitions included in file
my $verbose; # Verbose flag
my $tmp_comment; # String containing comments
my $inline; # String containing parsed line
my @tmp_arguments; # Storing splited line of code

########################################################################
########## Read command line arguments

GetOptions (
	"code=s"	=> \$code_file, # File with the code
	"output=s"	=> \$output_file,
	"verbose"	=> \$verbose,
) or die "\t-E-\t No arguments given. \n"; 

# Check for correct inputs
unless ($code_file) {
	print "\t-E-\t No CODE FILE defined. Nothing more to do.\n";
	exit;
}

########################################################################
########### -- START --

# Open code file 
myprint(">> Opening code file: $code_file \t ");
open (IN_DH, "<", "$code_file") or die "\t-E-\tCould not open file for input: \t $code_file \n";

# Parse file, line per line
while ($inline = <IN_DH>) {
	# Increase line counter
	$line_counter++;
	# Chomp spaces at the begining and end of line
	$inline =~ s/^\s*//;
	$inline =~ s/\s*$//;

	$inline or next; # In case of empty lines, check next line

	# First, ignore comments. Acepted formats: '# Comment', '// Comment' (This is for lines starting with a comment)
	# Other comments accepted will be after commands and starting with '//'
	if ($inline =~ /^(#|\\\\)/) {
		$inline =~ s/^#/\\/;
		$instructions .= "$inline \n";
		next;  
	} 
	# Now for definitions within file
	elsif ($inline =~ /^(.*define)/) {
		# Add correct format to definition (increases flexibility in coding)
		$inline =~ s/^(.*define)/`define/;
		# Add definition to definitions string
		$definitions .= "$inline \n";
	} 
	# For the NOP instruction
	elsif ($inline =~ /^NOP/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;

		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `NOP ,\t24'd4000\t};";
		# Increase counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	}
	# For the LED instruction
	elsif ($inline =~ /^LED/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 2) {
			die "\t-E-\t Wrong number of arguments for LED instruction. Given: $#tmp_arguments, spected: 1\t Line: <$line_counter>\n";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `LED ,	8'b0, $tmp_arguments[1], 8'b0 };";
		# Increase counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	}
	# For the BLE instruction
	elsif ($inline =~ /^BLE/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 4) {
			die "\t-E-\t Wrong number of arguments for BLE instruction. Given $#tmp_arguments, spected: 3\t Line: <$line_counter> \n";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `BLE , $tmp_arguments[1], $tmp_arguments[2], $tmp_arguments[3]};";
		# Increase counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	} 
	# For STO instruction
	elsif ($inline =~ /^STO/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 3) {
			die "\t-E-\t Wrong number of arguments for STO instruction. Given $#tmp_arguments, spected: 2 \t Line: <$line_counter>";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `STO , $tmp_arguments[1], $tmp_arguments[2]};";
		# Increase instruction counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	} 
	# For ADD instruction
	elsif ($inline =~ /^ADD/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 4) {
			die "\t-E-\t Wrong number of arguments for ADD instruction. Given $#tmp_arguments, spected: 3 \t Line: <$line_counter>";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `ADD , $tmp_arguments[1], $tmp_arguments[2], $tmp_arguments[3]};";
		# Increase instruction counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	} 
	# For SUB instruction
	elsif ($inline =~ /^SUB/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 4) {
			die "\t-E-\t Wrong number of arguments for SUB instruction. Given $#tmp_arguments, spected: 3 \t Line: <$line_counter>";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `SUB , $tmp_arguments[1], $tmp_arguments[2], $tmp_arguments[3]};";
		# Increase instruction counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	} 
	# For JMP instruction
	elsif ($inline =~ /^JMP/) {
		# Obtain comments and  save them in tmp_comment
		$tmp_comment = $inline;
		$tmp_comment =~ s/^.*\s*\\\\// or $tmp_comment =~ s/.*//; # Added in case there is no comments
		$inline =~ s/\s*\\\\.*//;
		
		# Format different spaces to just one space 
		$inline =~ s/\s+/ /g;
		
		# Obtain arguments spliting by space
		@tmp_arguments = split(' ', $inline);
		
		# Check for correct format
		if ($#tmp_arguments+1 != 2) {
			die "\t-E-\t Wrong number of arguments for JMP instruction. Given $#tmp_arguments, spected: 1 \t Line: <$line_counter>";
		}
		
		# Include NOP code in instructions
		$instructions .= "$inst_counter: oInstruction = { `JMP , $tmp_arguments[1], 16'b0 };";
		# Increase instruction counter
		$inst_counter++;
		# Add comments
		$instructions .= ($tmp_comment) ? " \\\\ $tmp_comment \n": "\n" ;
		# Next line
		next;
	} 
}
print ">> Instructions \n\n";
print "$instructions\n";
print "\n\n>> Definitions \n\n";
print "$definitions\n";

########################################################################
######### SUBROUTINES
########################################################################

# Verbose printing subroutine
sub myprint {
	# Get string to print
	my $tmp_string = shift;
	# If verbose mode is enabled, print string
	$verbose and print "$tmp_string \n";
}


