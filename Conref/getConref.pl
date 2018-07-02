use warnings;
use strict;


our @g_ID;
our @g_conref;
our @g_DITAfiles;
our @g_files;
our $g_file;
our $g_rowID;
our $g_rowConref;

sub initProg{
    # gather names of all files in local directory and subdirs
    # put files in array
    # filters .dita files and puts in another array
    use File::Find;
    use Cwd qw();

    my $DITAfile;
    my $localdir;
    my $dita;

    $localdir = Cwd::cwd();
    print "in local directory and subdirs: $localdir\n";

    find( \&getFileNames, $localdir);

    @g_DITAfiles=grep(/\.dita$/, @g_files);
    foreach $dita (@g_DITAfiles){
        print 'Files: ';
        print "$dita\n";}
}
 
sub getFileNames {
    push @g_files, $File::Find::name;
    return;
}		

sub initFile(){
    # Read all .dita file sequentially
    # Put all occurences conref in array
    # Put all occurences ID in array
    my @IDs;
    my @conrefs;
    my @lines;
    my $filerows;
    my $reuse='id';
    my $delim='"/>';
    my $ID;
    my $temp;
    my $conref;
  
    open (INPUT, "<", $g_file) or die "Input file issue";
        @lines=<INPUT>;
    close INPUT;
    
    open(OUTPUT, ">conref.csv") or die "cannot open OUTPUT";
    print OUTPUT "SOURCE FILE/ID,TARGET FILE,CONREF\n";
 
    foreach $filerows (@lines){
        if ( $filerows =~ /.+conref="([^"]+)/ ){
    	    $temp=$1;
    	    $temp=~ (s/\x23[^\x2F]+//);
    	    $temp=~(s/\x2E\x2E\x2F/\x2F/);
            $conref=$g_file."!".$temp;
        
            push @g_conref, $conref;
        }
        if ( $filerows =~ /.+id="([^"]+)/ ){
        $ID=$g_file."/".$1;
        push @g_ID, $ID;
        }
    }
}

sub relPath{
	use File::Spec; 
	my $relPath;
    $relPath = File::Spec->abs2rel ($_[1],  $_[2]);
}

sub processConref{
	my $temp;
	my $fileRow;
	
	$temp = $g_rowConref;
  	$temp=~s/.+\x21//;
  	if ($g_rowID=~m/$temp/){
  	   $g_rowConref=~tr/\x21/\x2C/;
  	    $fileRow = relPath($g_rowConref, $g_rowID) .','. relPath($g_rowID, $g_rowConref);
  	    print OUTPUT "$fileRow\n";
	}
}

sub finProg{
	close OUTPUT;
	print "Output in conref.csv  \n";
	print "The End \n";
}

# === MAIN === 
print "Searching for conrefs in your DITA project\n";
initProg();
foreach $g_file (@g_DITAfiles){
	initFile();
}
    foreach $g_rowID (@g_ID){
  	    foreach $g_rowConref(@g_conref){
  		processConref();
  	    }	
  	}
finProg();


