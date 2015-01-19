use warnings;
use strict;

use utf8;

my $radius_earth       = 5;
my $x_sun              = 300;
my $y_sun              = 300;

my $x_star             = 700;
my $y_star             = 350;

my $radius_orbit       = 80;

my $days_per_year      = 6.25;
my $positions_per_day  = 4;
my $positions          = $days_per_year * $positions_per_day;
my $id_counter         = 0;
my $one_year           = 1;

open (my $svg, '>', 'Erdumlaufbahn.svg');

svg_intro();


print $svg qq{
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
  >
};


for (my $i=0; $i<$one_year; $i+=1/$positions) {

  my $x_earth = $x_sun - $radius_orbit*sin($i*3.14156*2);
  my $y_earth = $y_sun - $radius_orbit*cos($i*3.14156*2);

  my $id = "id_$id_counter"; $id_counter ++;

  print $svg "<g id=\"$id\">";

  earth($x_earth, $y_earth, -$i*2*3.14156);

  my $x_observer = $x_earth - cos($i*($days_per_year+1) *3.14156*2 + 3.14156/2) * ($radius_earth+0.5);
  my $y_observer = $y_earth + sin($i*($days_per_year+1) *3.14156*2 + 3.14156/2) * ($radius_earth+0.5);

  print $svg qq|<path d="M $x_observer,$y_observer L $x_star,$y_star" stroke="#00f" stroke-width="0.1mm"/>|;
  print $svg qq|<path d="M $x_observer,$y_observer L $x_sun,$y_sun"   stroke="#f70" stroke-width="0.1mm"/>|;

  print $svg qq|<circle cx="$x_observer" cy="$y_observer" r="1" fill="red" />|;

  print $svg "</g>";

  my $x_translate = 300 - $x_observer;
  my $y_translate = 900 - $y_observer;

  my $rotation    = $i*$days_per_year * 3.14156*2 - $i*3.14156*2;

}

print $svg '  </g>
';

svg_extro();

close $svg;

sub translation_matrix { # {{{

    my $x = shift;
    my $y = shift;

    return
       (1, 0, $x,
        0, 1, $y,
        0, 0,  1);
    
} # }}}

sub rotation_matrix { # {{{

    my $α = shift;
    
    return
       (cos($α), -sin($α), 0,
        sin($α),  cos($α), 0,
        0      ,  0      , 1);

} # }}}

sub matrix_mutliplication { # {{{

    my @m1 = (shift, shift, shift, shift, shift, shift, shift, shift, shift);
    my @m2 = (shift, shift, shift, shift, shift, shift, shift, shift, shift);

    my @ret=();

    #          0  1  2
    #          3  4  5
    #          6  7  8
    #         +-------
    # 0  1  2 |
    # 3  4  5 |
    # 6  7  8 |
    #
    #
    $ret [0] = $m1[0]*$m2[0] + $m1[1]*$m2[3] + $m1[2]*$m2[6];
    $ret [1] = $m1[0]*$m2[1] + $m1[1]*$m2[4] + $m1[2]*$m2[7];
    $ret [2] = $m1[0]*$m2[2] + $m1[1]*$m2[5] + $m1[2]*$m2[8];

    $ret [3] = $m1[3]*$m2[0] + $m1[4]*$m2[3] + $m1[5]*$m2[6];
    $ret [4] = $m1[3]*$m2[1] + $m1[4]*$m2[4] + $m1[5]*$m2[7];
    $ret [5] = $m1[3]*$m2[2] + $m1[4]*$m2[5] + $m1[5]*$m2[8];

    $ret [6] = $m1[6]*$m2[0] + $m1[7]*$m2[3] + $m1[8]*$m2[6];
    $ret [7] = $m1[6]*$m2[1] + $m1[7]*$m2[4] + $m1[8]*$m2[7];
    $ret [8] = $m1[6]*$m2[2] + $m1[7]*$m2[5] + $m1[8]*$m2[8];

    return @ret;
    
} # }}}

sub matrix_to_svg { # {{{

    return "transform=\"matrix($_[0],$_[3],$_[1],$_[4],$_[2],$_[5])\"";

} # }}}

sub earth { # {{{

   my $x              = shift;
   my $y              = shift;
   my $rotation       = shift;

   my @trx = translation_matrix($x, $y);
   my @rot = rotation_matrix   ($rotation);

   my @matrix = matrix_mutliplication(@trx, @rot);

   my $translation = matrix_to_svg(@matrix);


   my $xRadius        =  $radius_earth;
   my $yRadius        =  $radius_earth;
   my $xAxisRotation  =  0;
   my $largeArcFlag   =  0;
   my $sweepFlag_1    =  1;
   my $sweepFlag_2    =  0;

   my $xFrom          = -$radius_earth;
   my $yFrom          =  0;

   my $yTo            =  0;
   my $xTo            =  $radius_earth;

   print $svg qq{
    <g $translation>
      <path
         d="M $xFrom,$yFrom A $xRadius,$yRadius $xAxisRotation $largeArcFlag,$sweepFlag_1 $xTo,$yTo"
         style="fill:#000000;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;fill-opacity:1" />
      <path
         d="M $xFrom,$yFrom A $xRadius,$yRadius $xAxisRotation $largeArcFlag,$sweepFlag_2 $xTo,$yTo"
         style="fill:#00c5ff;fill-opacity:1;fill-rule:evenodd;stroke:#0000ff;stroke-width:0.2mm;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"/>
    </g>};
   
    
} # }}}

sub svg_intro { # {{{
    print $svg qq{<?xml version="1.0" encoding="UTF-8" standalone="no"?>

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="1052.3622"
   height="744"
   version="1.1"
   >
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="0.7"
     inkscape:cx="370"
     inkscape:cy="400"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     units="mm"
     inkscape:window-width="1440"
     inkscape:window-height="838"
     inkscape:window-x="-8"
     inkscape:window-y="-8"
     inkscape:window-maximized="1" />
  }
} # }}}

sub svg_extro { # {{{
  print $svg '     
</svg>';
} # }}}
