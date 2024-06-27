#!/usr/bin/perl

use Data::Dumper qw(Dumper);

#######################################
#       DEFINE GLOBAL VARIABLES       #
#######################################

# File path
$benchmark_file_path = "../src/build/ofm.txt";
$test_file_path = "../src/build/conv_acc_out.txt";

# Arrays to store each element of files
@benchmark_array;
@test_array;

#############################
#       START OF MAIN       #
#############################

# Read each line into arrays
@benchmark_array = read_file2array($benchmark_file_path);
@test_array = read_file2array($test_file_path);

=pod Check to see if number of elements in both arrays are equal
$size_benchmark = scalar @benchmark_array;
$size_test = scalar @test_array;
print "Benchmark = $size_benchmark, Test = $size_test\n";
=cut

$mean_percentage_error = get_mpe(\@benchmark_array, \@test_array);

printf("Mean Percentage Error: %.4f%\n", $mean_percentage_error);
#print Dumper \@benchmark_array;
#print Dumper \@test_array;

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

    # Split lines in to elements
    my @split_array;
    if ($filename eq $benchmark_file_path) {
        foreach my $line (@array) {
            my @elements = split(/,/, $line);
            push @split_array, @elements;
        }
    } else {
        foreach my $line (@array) {
            my @elements = split(/\s+/, $line);
            push @split_array, @elements;
        }
    }

    # Remove empty strings in the array
    @split_array = grep { $_ ne '' } @split_array;
    @split_array = grep { $_ !~ /\s/ } @split_array;
    @split_array = grep { $_ !~ /,/ } @split_array;

    return @split_array;
}

sub get_mpe { # Calculate the mean percentage error for the results
    my ($benchmark_ref, $test_ref) = @_;

    my $size_benchmark = scalar @$benchmark_ref;
    my $size_test = scalar @$test_ref;

    if ($size_benchmark != $size_test) {
        die "-E-: Benchmark and Test number of elements are not equal.\nBenchmark = $size_benchmark, Test = $size_test\n";
    } else {
        my $counter = 0;
        my $percentage_error = 0;
        my $sum_percentage_error = 0;
        my $mean_percentage_error = 0;

        foreach my $num (@$benchmark_ref) {
            # mean percentage error = (|benchmark - test| / benchmark) x 100%
            if ($$benchmark_ref[$counter] == 0) {
                $percentage_error = 0;
            } elsif ($$benchmark_ref[$counter] == $$test_ref[$counter]) {
                $percentage_error = 0;
            } elsif ($$benchmark_ref[$counter] > $$test_ref[$counter]) {
                $percentage_error = ($$benchmark_ref[$counter] - $$test_ref[$counter]) * 100 / $$benchmark_ref[$counter];
            } else {
                $percentage_error = ($$test_ref[$counter] - $$benchmark_ref[$counter]) * 100 / $$benchmark_ref[$counter];
            }

            $sum_percentage_error = $sum_percentage_error + $percentage_error;
            $counter++;
        }

        # Divide by number of elements
        $mean_percentage_error = $sum_percentage_error / $size_benchmark;
        
        return $mean_percentage_error;
    }
}
