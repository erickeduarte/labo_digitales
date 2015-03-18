########################################################################
########## Libraries needed
use GetOpt::Long;
use strict;
use warnings;
########################################################################
########## Variables needed
my $def_dh;
my $code_dh;
my $def_file;
my $code_file;
my $inst_counter;
########################################################################
########## Terminal 

my $opt_options (
	"code=s"	=> $code_file;
);
 
open ($definitions_file, ">", "$code_file");

my %instructions = (
	"NOP"	=>	{"args" => 0},
	"LED"	=>	{"args" => 2},
	"BLE"	=>	{"args" => 3},
	"STO"	=>	{"args" => 2},
	"ADD"	=>	{"args" => 3},
	"SUB"	=>	{"args" => 3}, 	
);  
 
while ($inline = <$code_dh>) {
	# Chomp spaces at the begining and end of line
	$inline =~ s/$\s*//;
	$inline =~ s/\s*^//;
	
	# Now lets check the input
	my $tmp_hash;
	foreach $tmp_hash(keys(%instructions)) {
		if ($inline =~ /# Definitions/) {
			while ($inline = <$code_dh>){
					
			}
		}
	}
	
}
