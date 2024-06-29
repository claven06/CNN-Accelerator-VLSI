#!/usr/bin/perl

use Data::Dumper qw(Dumper);

#######################################
#       DEFINE GLOBAL VARIABLES       #
#######################################

# Report file path
$input_file = "accuracy_report.txt";

# Array to store input data
@array;

# Hash to store report files
%data_hash;

# Output file
$output_file = "accuracy_report.txt.tmp";

#############################
#       START OF MAIN       #
#############################

my ($i, $type, $fh) = @_;

# Read the input file
@array = read_file2array($input_file);

foreach my $num (0 .. $#array) {
    if ($array[$num] =~ m/.*(Dataset.*\d+).*/) {
        $set = $1;
    } else {
        ($array[$num] =~ m/.*Approx_Bits:\s+(\d+),.*(Mean.*Error:\s+\S+)\s*/);
        ($approx, $error) = ($1, $2);
        push @{$data_hash{$approx}}, "$set, $error";
    }
}

open (my $fh, '>', $output_file) or die "-E-: Could not open $output_file ($!)\n";

foreach my $approx (sort { $a <=> $b } keys %data_hash) {
    print $fh "Approx_Bits: $approx\n";
    foreach my $data (@{$data_hash{$approx}}) {
        print $fh "  $data\n";
    }
}

close $fh;

###########################
#       END OF MAIN       #
###########################

sub read_file2array {
    # Get filename from subroutine input and instantiate array
    my $filename = shift;
    my @array;

    # Open file to read, removing trailing newline and push into array
    open (my $fh, '<:encoding(UTF-8)', $filename) or die "-E-: Could not open $filename ($!)\n";

    while (my $line = <$fh>) {
        chomp $line;
        push @array, $line;
    }

    # Close filehandle and return the array
    close $fh;
    return @array;
}
