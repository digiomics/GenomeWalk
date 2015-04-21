#!/usr/bin/perl
use strict;
use warnings;
use SVG;
#use Inline 'C';
use constant STEP =>2;
(my ($xs,$ys));
push(@{$xs},600);
push(@{$ys},400);
 my $svg= SVG->new(width=>800,height=>800);
while (<>) {
    next if /^>/ || /^$/;
    chomp;
    print $xs->[-1],"\t";
    (my ($x_tem,$y_tem)) = calc_path_pl([split(//,$_)],$xs->[-1],$ys->[-1]);
    push(@{$xs},@{$x_tem});
    push(@{$ys},@{$y_tem});
    print $xs->[-1],"\n";
}

 my $path = $svg->get_path(
        x => $xs,
        y => $ys,
        -type   => 'polyline',
        -closed => 'false'  #specify that the polyline is closed
    );
$svg->polyline(%$path,style=>{
        'fill'          => 'none',
        'stroke'         => 'grey',
        'stroke-width'   =>  3,
        
        
});
print $svg->xmlify;


sub calc_path_pl {
    my $string = shift;
    my $x = shift;
    my $y = shift;
    my $x_ref;
    my $y_ref;
    
    foreach(@{$string}){
        if ($_ eq 'C'){
            push(@{$x_ref},$x);
            $y-= STEP;
            push(@{$y_ref},$y);
        }
        elsif($_ eq 'G'){
            push(@{$x_ref},$x);
            $y+=STEP;
            push(@{$y_ref},$y);
        }
            
        elsif($_ eq 'A'){
            $x-=STEP;
            push (@{$x_ref},$x);
            push (@{$y_ref},$y);
        }
        elsif($_ eq 'T'){
            $x+=STEP;
            push(@{$x_ref},$x);
            push(@{$y_ref},$y);
        }
    }
    return ($x_ref,$y_ref);
}


#__END__
#__C__

#/* convert a string of bases into a unique numeric index */


#int calc_path(char* str,int x int y) {
#      int i = 0;
#      char c;
#    AV* ret = newAV();
#      while(c =r str[i++]) {
#        if (c == 'C') 
#          index += base * 1;
#        else if (c == 'T')
#          index += base * 2;
#        else if (c == 'G')
#          index += base * 3;
#        base *= 4;
#      }
#      return index;
#}
    
#<<<
