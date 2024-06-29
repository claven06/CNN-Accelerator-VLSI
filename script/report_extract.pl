#!/usr/bin/perl

use Data::Dumper qw(Dumper);

#######################################
#       DEFINE GLOBAL VARIABLES       #
#######################################

# Report file path
$report_path = "../gen_rpt";

# Hash to store report files
%file_hash;

# Array to store report types
@report_type = ('area', 'power', 'qor');

# Output file
$output_file = "synthesis_summary.txt";

#############################
#       START OF MAIN       #
#############################

# Open the report directory
opendir(DIR, $report_path) or die "-E-: Could not open $report_path ($!)\n";

# Read the directory handle
while (my $file = readdir(DIR)) {
    # Skip if the file is a directory
    next if (-d "$report_path/$file");

    if ($file =~ m/approx_(\d+)_CONV_ACC_(\w+)\.rpt/) {
        my ($approx, $type) = ($1, $2);
        push @{$file_hash{$type}{$approx}}, $file;
    }
}

# Close the report directory
closedir(DIR);

# Write an output file
open (my $fh, '>', $output_file) or die "-E-: Could not open $output_file ($!)\n";

foreach $type (@report_type) {
    # Print the type of report
    print $fh "START Type: $type\n";
    for (my $i = 0; $i <= 16; $i = $i + 2) {
        # Print the approximation bits
        print $fh "  Approx: $i\n";
        
        # Check if the type of report exists and run the read subroutine
        if (exists $file_hash{$type}{$i}) {
            my $sub_type = "read_${type}";
            &$sub_type($i, $type, $fh);
        }
    }

    # Print the end of the report
    print $fh "END Type: $type\n";
    print $fh "\n\n";
}

# Close the output file
close $fh;

###########################
#       END OF MAIN       #
###########################

sub read_area {
    my ($i, $type, $fh) = @_;

    # read the report
    open (my $ar, '<', "$report_path/approx_${i}_CONV_ACC_${type}.rpt") or die "-E-: Could not open $report_path/approx_${i}_CONV_ACC_${type}.rpt ($!)\n";
    
    my @array;

    while (my $line = <$ar>) {   
        if ($line =~ m/.*combinational\s+cells:\s+(\d+).*/) {
            push @array, $1;
        }

        if ($line =~ m/.*sequential\s+cells:\s+(\d+).*/) {
            push @array, $1;
        }

        if ($line =~ m/.*buf\/inv:\s+(\d+).*/) {
            push @array, $1;
        }

        if ($line =~ m/Combinational\s+area:\s+(\d+\.\d+).*/) {
            push @array, $1;
        }

        if ($line =~ m/Buf\/Inv\s+area:\s+(\d+\.\d+).*/) {
            push @array, $1;
        }

        if ($line =~ m/Total\s+area:\s+(\d+\.\d+).*/) {
            push @array, $1;
        }
    }

    # Close the report
    close $ar;

    print $fh "    Combi cells: $array[0], Seq cells: $array[1], Buf/Inv: $array[2], Combi area: $array[3], Buf/Inv area: $array[4], Total area: $array[5]\n";
}

sub read_power {
    my ($i, $type, $fh) = @_;

    # read the report
    open (my $ar, '<', "$report_path/approx_${i}_CONV_ACC_${type}.rpt") or die "-E-: Could not open $report_path/approx_${i}_CONV_ACC_${type}.rpt ($!)\n";
    
    my @array;

    while (my $line = <$ar>) {   
        if ($line =~ m/.*register\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\(\s+(\S+)\).*/) {
            push @array, $1;
            push @array, $2;
            push @array, $3;
            push @array, $4;
            push @array, $5;
        }

        if ($line =~ m/.*combinational\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\(\s+(\S+)\).*/) {
            push @array, $1;
            push @array, $2;
            push @array, $3;
            push @array, $4;
            push @array, $5;
        }

        if ($line =~ m/.*Total\s+(\S+\s+\S+)\s+(\S+\s+\S+)\s+(\S+\s+\S+)\s+(\S+\s+\S+).*/) {
            push @array, $1;
            push @array, $2;
            push @array, $3;
            push @array, $4;
        }
    }

    # Close the report
    close $ar;

    printf $fh "    %-15s:   %-15s %-15s %-15s %-15s %-15s\n", 'Power Group', 'Internal', 'Switching', 'Leakage', 'Total', 'Percentage';
    print $fh "    "; print $fh '-' x 93, "\n";
    printf $fh "    %-15s:   %-15s %-15s %-15s %-15s %-15s\n", 'Register', $array[0], $array[1], $array[2], $array[3], $array[4];
    printf $fh "    %-15s:   %-15s %-15s %-15s %-15s %-15s\n", 'Combinational', $array[5], $array[6], $array[7], $array[8], $array[9];
    print $fh "    "; print $fh '-' x 93, "\n";
    printf $fh "    %-15s:   %-15s %-15s %-15s %-15s\n", 'Total', $array[10], $array[11], $array[12], $array[13];
}

sub read_qor {
    my ($i, $type, $fh) = @_;

    # read the report
    open (my $ar, '<', "$report_path/approx_${i}_CONV_ACC_${type}.rpt") or die "-E-: Could not open $report_path/approx_${i}_CONV_ACC_${type}.rpt ($!)\n";
    
    my @array;

    while (my $line = <$ar>) {   
        if ($line =~ m/.*Critical\s+Path\s+Slack:\s+(\S+).*/) {
            push @array, $1;
        }

        if ($line =~ m/.*Critical\s+Path\s+Clk\s+Period:\s+(\S+).*/) {
            push @array, $1;
        }

        if ($line =~ m/.*No.*Paths:\s+(\S+).*/) {
            push @array, $1;
        }

        if ($line =~ m/.*No.*Hold\s+Violations:\s+(\S+).*/) {
            push @array, $1;
        }
    }

    # Close the report
    close $ar;

    print $fh "    Clock Period: $array[1], Setup Slack: $array[0], No. Setup Viol: $array[2], No. Hold Viol: $array[3]\n";

}