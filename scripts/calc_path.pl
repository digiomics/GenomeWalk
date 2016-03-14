#!/usr/bin/perl
#
use strict;
use warnings;
use Inline 'C';
use constant STEP =>.02;
use constant HEIGHT => 850;
use constant WIDTH => 800;
use constant WINDOW => 1000;
use SVG;
use Getopt::Std;
my %opts;
getopt('i:o:', \%opts);
my $usage = "\n\t$0 -i [path/to/fasta/input/file] -o [path/to/svg/output/file]";

#checking input and output
die $usage unless ($opts{i} && $opts{o});
die "Error: $opts{i} does not exist!" unless (-e $opts{i});

open (my $fh, "<", $opts{i}) || die "Error. Could not open $opts{i}: $!\n";
open (my $fho,">",$opts{o}) || die "Error. Could not open $opts{o}: $!\n";

# initiating path
(my ($xs,$ys,$id,$string_buffer));
(my ($max_x,$min_x,$max_y,$min_y)) = (0 , 0 , 0 ,0 );
(my ($scale_x,$scale_y,$scale)) = (1,1,1);
push(@{$xs},0);
push(@{$ys},0);
my $svg= SVG->new(width=>WIDTH,height=>HEIGHT);
 $svg->rect(x=>1,y=>1,width=>WIDTH-1,height=>HEIGHT-1,style=>{'stroke' => 'black','stroke-width' => 1,fill=>'none'});

#Read fasta file
while (<$fh>) {
    next if /^$/;
    chomp;
    # check for header
    if (/^>.+\|\ (\w+\ \w+[^\|]+).*/){
	    $id = $1;
	next;
    }
#Append line from file to string buffer
    $string_buffer .= $_;
# check if string buffer contains enough sequence
    while (length($string_buffer) >= WINDOW ) {
	    my $window = substr($string_buffer , 0 ,WINDOW,"");
#    calculate path for buffer content
	    (my ($x_tem,$y_tem)) = calc_path($window,$xs->[-1],$ys->[-1]);
	    
	    push(@{$xs},$x_tem);
	    push(@{$ys},$y_tem);
	    #store maximum values
	    $max_x = $x_tem if $x_tem > $max_x;
	    $min_x = $x_tem if $x_tem < $min_x;
	    $max_y = $y_tem if $y_tem > $max_y;
	    $min_y = $y_tem if $y_tem < $min_y;
    }
 
}
close $fh || warn "Error. Could not close $opts{i}: $!";

# Process rest of sequence in string buffer
(my ($x_tem,$y_tem)) = calc_path($string_buffer,$xs->[-1],$ys->[-1]);
push(@{$xs},$x_tem);
push(@{$ys},$y_tem);
$max_x = $x_tem if $x_tem > $max_x;
$min_x = $x_tem if $x_tem < $min_x;
$max_y = $y_tem if $y_tem > $max_y;
$min_y = $y_tem if $y_tem < $min_y;
#Calculate scaling factor
if ($max_x - $min_x > WIDTH) {
	$scale_x = WIDTH  / ($max_x - $min_x) ;
}
if ($max_y - $min_y > (HEIGHT-50)) {
	$scale_y = ((HEIGHT-50) / ($max_y - $min_y)) ;
}
warn $scale_x,"\t",$scale_y,"\n";
$scale = ($scale_x < $scale_y) ? $scale_x : $scale_y;

# Transform path so that the plot is centered around the midpoint of the canvas
my $x_off = WIDTH  / 2  -($max_x - (($max_x - $min_x) / 2));
my $y_off = (HEIGHT+40) / 2  -($max_y - (($max_y - $min_y) / 2)) *$scale;

warn join("\t",($min_x,$max_x,$min_y,$max_y,$x_off,$y_off));
my $g = $svg->group("transform" => "translate( $x_off,$y_off) scale ($scale) ");
$g->circle(
    cx=>$xs->[0],
    cy=>$ys->[0],
    r=>3,
    style => {
        'fill'           => 'rgb(0, 255, 0)',
        'stroke'         => 'blue',
        'stroke-width'   =>  1,
        'stroke-opacity' =>  1,
        'fill-opacity'   =>  1,
    },
    );
 my $path = $svg->get_path(
        x => $xs,
        y => $ys,
        -type   => 'polyline',
        -closed => 'false'  #specify that the polyline is closed
    );
    
$g->polyline(%$path,style=>{
        'fill'          => 'none',
        'stroke'         => 'black',
        'stroke-width'   =>  1
        });
        

$g->circle(
    cx=>$xs->[-1],
    cy=>$ys->[-1],
    r=>3,
    style => {
        'fill'           => 'rgb(255, 0, 0)',
        'stroke'         => 'blue',
        'stroke-width'   =>  1,
        'stroke-opacity' =>  1,
        'fill-opacity'   =>  1,
    },
    );

$svg->text('x' => 20,
		'y' => 20,
		'stroke' => 'black',
		'fill' => 'red')->cdata($id);

print $fho $svg->xmlify;
close $fho || die "Error. Could not close $opts{o}: $!";
__END__
__C__

/* convert a string of bases into a unique numeric index */


void calc_path(char* str,double x, double y) {
      int i = 0;
      char c;
    
      while(c = str[i++]) {
        
        if (c == 'C') 
          y -= .02;
        else if (c == 'G')
          y += .02;
        else if (c == 'A')
          x -= .02;
        else if (c == 'T')
          x += .02;
      }
      Inline_Stack_Vars;
      Inline_Stack_Reset;
      Inline_Stack_Push(sv_2mortal(newSVnv(x)));
      Inline_Stack_Push(sv_2mortal(newSVnv(y)));
      Inline_Stack_Done;
}
