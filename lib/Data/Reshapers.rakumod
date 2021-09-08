=begin pod

=head1 Data::Reshapers

C<Data::Reshapers> package has data reshaping functions for
different data structures (full arrays, Red tables, Text::CSV tables.)

=head1 Synopsis

    # To run the code below make sure you have this CSV file :
    #    "https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv"

    use Data::Reshapers;
    use Text::CSV;

    my $csv = Text::CSV.new;
    my $fileName = $*CWD.Str ~ "/resources/dfTitanic.csv";
    my @tbl = $csv.csv(in => $fileName, headers => "auto");

    my $xtab1 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex');
    my $xtab2 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex', 'passengerAge');

    my @tbl2 = $csv.csv(in => $fileName, headers => "none");
    my $xtab3 = cross-tabulate(@tbl, 1, 3);
    my $xtab4 = cross-tabulate(@tbl, 1, 3, 2);

=end pod

unit module Data::Reshapers;

use Text::CSV;

#===========================================================

#| Get the Titanic dataset. Returns Positional[Hash] or Positional[Array].
sub get-titanic-dataset( Str:D :$headers = 'auto', --> Positional ) is export {
    my $csv = Text::CSV.new;
    my $fileHandle = %?RESOURCES<dfTitanic.csv>;

    my @tbl = $csv.csv(in => $fileHandle.Str, :$headers);

    return @tbl;
}
#| Ingests the resource file "dfTitanic.csv" of Data::Reshapers.


#===========================================================
proto data-reshape(|) is export {*}

