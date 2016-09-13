//use <Bezier.scad>;

use <array_iterator.scad>;

//curve library to generate the neckpipe. Not ideal, but works for now and much easier
//to create good tubes with than with sweep() like the tuning slide.
use <Curved_Pipe_Library_for_OpenSCAD/curvedPipe.scad>;


$fn = 100;
//tuning_slide(solid=false) module renders a tuning slide, using the sweep module.
include <tuning_slide.scad>;

slide_receiver_tolerance = 0.1;

slide_receiver_small_radius = 50/pi/2 + slide_receiver_tolerance;
slide_receiver_large_radius = 54.7/pi/2 + slide_receiver_tolerance;

slide_receiver_sleeve_length=25;//normally 25

//extra width added to the slide receiver to match the slide


slide_receiver_length=31.5 + slide_receiver_tolerance;



bell_thickness = 0.8;

joint_width = 6.5;
joint_depth = 9;
//for your joint to have a nice looking and printable bottom, set this higher
joint_slanted_bottom = 20;
//the receiver should be slightly longer than the slide
tuning_sleeve_extra_length = 0.36;

lip_start=2;
lip_end=5;
lip_slant=1;
lip_length=7;
//difference in size between the joint outer and inner lip
//so they can fit together without requiring too much use of sandpaper
// i need better words for this :)
lip_offset = 0.2;

//difference between outer diameter of tuning slide and inner diameter of sleeve in mm
tuning_slide_spacing = 0.2;

neck_pipe_length = 269.10;
neck_pipe_radius = 7.25;

neckpipe_bell_connection_radius=6.5;

neck_pipe_minus_tuning_slide_receiver_length = neck_pipe_length - tuning_slide_small_length -tuning_sleeve_extra_length;

lip = [[lip_start, 0], [lip_start+lip_slant, lip_length], [lip_end-lip_slant, lip_length], [lip_end, 0]];

inner_lip = [[lip_start+lip_offset, 0], [lip_start+lip_slant +lip_offset, lip_length-lip_offset], [lip_end-lip_slant-lip_offset, lip_length-lip_offset], [lip_end-lip_offset, 0]];

total_bell_height = -55.93-96.85-150.42-150.42-53.36; //TODO: make this with proper parameters

tuning_slide_large_receiver_inner_radius = tuning_slide_large_radius + tuning_slide_wall_thickness + tuning_slide_spacing;

//steps of the bessel curve for loop
steps=100;
    

//the curve (not really a polygon, just a set of points for now!) of the bell
bell_polygon = concat(
            //tuning slide receiver. Inner tuning slide radius: 9.9mm. That makes a wall thickness of
            //the tuning slide of 10.53 - 9.9!
            [
                [tuning_slide_large_receiver_inner_radius, -55.93-96.85-150.42-150.42-53.36-tuning_slide_large_length + tuning_sleeve_extra_length],
                [tuning_slide_large_receiver_inner_radius, -55.93-96.85-150.42-150.42-53.36]
            //[
            ],
             //this is equivalent to   conic_tube(h=53.36, r1=10.53, r2=11.05, wall=bell_thickness);
            [
                [11.05, -55.93-96.85-150.42-150.42], 
                [10.53, -55.93-96.85-150.42-150.42-53.36]
            ],
   
            2d_bessel_polygon(translation=-55.93-96.85-150.42,  throat_radius=11.05, mouth_radius=15.07, length=150.42, flare=1.260),
            2d_bessel_polygon(translation=-55.93-96.85, throat_radius=15.07, mouth_radius=22.28, length=150.42, flare=0.894),
        2d_bessel_polygon(translation=-55.93, throat_radius=22.28, mouth_radius=41.18, length=96.85, flare=0.494),
        2d_bessel_polygon(throat_radius=41.18, mouth_radius=108.60, length=55.93, flare=1.110)
    );

//TODO minor: the tuning slide of a real trombone is straight, then
//bends, then is straight again
//this makes this trombone too wide, which is a bit strange

rotate([180,0,0]) {

//temporary render for a test
//translate([0,0,400])
//render_bell_segment(render_bottom_lip=true, render_top_lip=false, min_height=-410, max_height=-400);
//render_bell_segment(render_bottom_lip=false, render_top_lip=true, min_height=-400, max_height=-380);

//solid_bell();

//three part bell section render

union() {
    render_bell_segment(render_bottom_lip=true, render_top_lip=false, min_height=-570, max_height=-380);
    upper_bell_connection_base();
}
union() {
    render_bell_segment(render_bottom_lip=true, render_top_lip=true, min_height=-380, max_height=-190);
    lower_bell_connection_base();
}
render_bell_segment(render_bottom_lip=false, render_top_lip=true, min_height=-190, max_height=0);


//two part bell - for very high printers!
/*union() {
    render_bell_segment(render_bottom_lip=true, render_top_lip=false, min_height=-580, max_height=-290);
    bell_connection_bases();
}*/
//render_bell_segment(render_bottom_lip=false, render_top_lip=true, min_height=-290, max_height=0);



translated_tuning_slide();

//#check_slide_clearance(bell_thickness);
bottom_part_of_neckpipe(bell_thickness);
top_part_of_neckpipe(bell_thickness);
//neckpipe(bell_thickness);
//slide_receiver(bell_thickness);

bell_side_neckpipe_bell_connection();
tuning_slide_side_neckpipe_bell_connection();
}

module check_slide_clearance(wall_thickness) {
    neckpipe_implementation(wall_thickness,
			    neck_pipe_radius,
        false, check_slide_clearance=true);
}

module translated_tuning_slide() {
    translate([0,-tuning_slide_radius,total_bell_height-tuning_slide_small_length]) {
        rotate([270,0,0]) {
            tuning_slide();
        }
    };
}

module slide_receiver(wall_thickness, solid = false) {

    
    if(!solid) {
        difference() {
            cylinder(r2=slide_receiver_large_radius + wall_thickness, r1=slide_receiver_small_radius +wall_thickness, h=slide_receiver_length);
            cylinder(r2=slide_receiver_large_radius, r1=slide_receiver_small_radius, h=slide_receiver_length);
        };
    } else {
            cylinder(r2=slide_receiver_large_radius + wall_thickness, r1=slide_receiver_small_radius +wall_thickness, h=slide_receiver_length);
    }
    
        edge_for_locknut_length=2.5;
    edge_for_locknut_thickness = 1.5;
        translate([0,0,slide_receiver_length-edge_for_locknut_length])
        difference() {
            cylinder(r=slide_receiver_large_radius + wall_thickness+edge_for_locknut_thickness, h=edge_for_locknut_length);
            cylinder(r=slide_receiver_large_radius + wall_thickness, h=edge_for_locknut_length);
        }
    
        if(!solid) {
            //sleeve to make a good connection to the neckpipe - which could be less wide than this!
        
            translate([0,0,-slide_receiver_sleeve_length])
            difference() {
                cylinder(r2=slide_receiver_small_radius + wall_thickness, r1=neck_pipe_radius+wall_thickness, h=slide_receiver_sleeve_length);
                cylinder(r2=slide_receiver_small_radius, r1=neck_pipe_radius, h=slide_receiver_sleeve_length);
            }
        } else {
            //sleeve to make a good connection to the neckpipe - which could be less wide than this!

            translate([0,0,-slide_receiver_sleeve_length])
                cylinder(r2=slide_receiver_small_radius + wall_thickness, r1=neck_pipe_radius+wall_thickness, h=slide_receiver_sleeve_length);
        }            
}

module bell_side_neckpipe_bell_connection() {
    neckpipe_bell_connection(-340);
}

module tuning_slide_side_neckpipe_bell_connection() {
    neckpipe_bell_connection(-530);

}

module neckpipe_bell_connection(height) {


        difference() {
            translate([0,0,height])
            rotate([90,0,0])
            cylinder(h = tuning_slide_radius*2, r=neckpipe_bell_connection_radius);
            solid_neckpipe(bell_thickness);
            solid_bell();

            connection_bases(0.2);
        }        
     


}

module bottom_part_of_neckpipe(wall_thickness) {
    intersection() {
        translate([-50, -tuning_slide_radius*2-50, -480])
        cube(190);
           neckpipe(wall_thickness);
    }
    translate([0, -tuning_slide_radius*2, -480])
    rotate_extrude()
    
    top_joint([[neck_pipe_radius,0], [neck_pipe_radius, 10]]);
}


module top_part_of_neckpipe(wall_thickness) {
    intersection() {
        translate([-50, -tuning_slide_radius*2-50, -670])
        cube(190);
                   neckpipe(wall_thickness);
    }
    bottom_joint_height=10;
    translate([0, -tuning_slide_radius*2, -670+190-bottom_joint_height])
    rotate_extrude()
    
    bottom_joint([[neck_pipe_radius,0], [neck_pipe_radius, 10]]);
}

module neckpipe(wall_thickness) {
    neckpipe_implementation(wall_thickness,
			    neck_pipe_radius,
        false);
    
    neckpipe_connection_bases();
    
    //TODO: slide locknut
    //TODO: split in separate parts so it can be printed
}

//a solid neckpipe. useful in difference with some other things
module solid_neckpipe(wall_thickness) {
    neckpipe_implementation(wall_thickness, neck_pipe_radius, true);
    connection_bases();
}

module neckpipe_implementation(wall_thickness, neck_pipe_radius, solid=false, check_slide_clearance=false) {


        if(solid) {
            solid_small_tuning_slide_sleeve(bell_thickness);
        } else {
            small_tuning_slide_sleeve(bell_thickness);
        }

        od = neck_pipe_radius*2 + wall_thickness+2;
        id = solid? 0.0005 : neck_pipe_radius*2;

            
        goose_neck_offset = 4;

        goose_neck_start = 75;

        slide_receiver_begin = neck_pipe_minus_tuning_slide_receiver_length -slide_receiver_length;

        goose_neck_x_length = slide_receiver_begin - goose_neck_start;
        goose_neck_y_length = goose_neck_offset;


        goose_neck_angle=atan(goose_neck_y_length/goose_neck_x_length);

        //neck pipe, including gooseneck
        translate([0, -tuning_slide_radius *2, total_bell_height + tuning_sleeve_extra_length])
            curvedPipe([ [0,0,0],
				[0,0,goose_neck_start],
				[0,-goose_neck_offset,slide_receiver_begin]				
			   ],
	            2, //two segments. strange library
				[50],
                od,
                id);
    
        //slide receiver
        translate([0, -tuning_slide_radius *2-goose_neck_offset, total_bell_height + tuning_sleeve_extra_length + slide_receiver_begin])
        rotate([goose_neck_angle, 0, 0])
        slide_receiver(wall_thickness, solid);
    

    
    if(check_slide_clearance) {
        translate([0, -tuning_slide_radius *2-goose_neck_offset, total_bell_height + tuning_sleeve_extra_length + slide_receiver_begin])    
            rotate([goose_neck_angle, 0, 0])
            cylinder(r=5, h=730);

    }
}

module connection_bases(tolerance=0.0) {
    neckpipe_connection_bases(tolerance);
    bell_connection_bases(tolerance);
    
}

module neckpipe_connection_bases(tolerance=0.0) {
    neckpipe_connection_base(19, -530, tolerance);
    neckpipe_connection_base(16, -340, tolerance);
}

module neckpipe_connection_base(translation, height, tolerance) {
    difference() {
        translate([0,-tuning_slide_radius*2+translation, height-3])
        rotate([75,0,0])
        scale([1,1,1])
        cylinder(r2=8+tolerance, r1=1+tolerance, h=16, $fn=4);  
        neckpipe_implementation(bell_thickness, neck_pipe_radius, true);
    }
}

module bell_connection_bases(tolerance=0.0) {
    upper_bell_connection_base();
    lower_bell_connection_base();
}

module upper_bell_connection_base(tolerance=0.0) {
    bell_connection_base(-530, tolerance);
}

module lower_bell_connection_base(tolerance=0.0) {
    bell_connection_base(-340, tolerance);
}    

module bell_connection_base(height, tolerance) {

    cylinder_height=15; 
    difference() {
                    translate([0, -bell_radius_at_height(bell_polygon, height)-cylinder_height+5, height-4])
                        rotate([-70,0,0])
        scale([1,1,1])
        cylinder(r2=8+tolerance, r1=1+tolerance, h=cylinder_height, $fn=4);  
        solid_bell();
        }
}

module small_tuning_slide_sleeve(wall_thickness) {
    translate([0, -tuning_slide_radius *2, total_bell_height-tuning_slide_small_length])
    difference() {
        cylinder(h = tuning_slide_small_length + tuning_sleeve_extra_length, r = tuning_slide_small_radius + tuning_slide_wall_thickness + tuning_slide_spacing + wall_thickness);
        cylinder(h = tuning_slide_small_length + tuning_sleeve_extra_length, r = tuning_slide_small_radius + tuning_slide_wall_thickness + tuning_slide_spacing);
    };
    
    translate([0, -tuning_slide_radius *2, total_bell_height])
    difference() {
        cylinder(h=20, r2=neck_pipe_radius+wall_thickness, r1=tuning_slide_small_radius + +tuning_slide_wall_thickness + tuning_slide_spacing + wall_thickness);
        cylinder(h=20, r=neck_pipe_radius);
    }
    //TODO: at the bottom, slant towards the neckpipe or we will not have a good connection!
}

module solid_small_tuning_slide_sleeve(wall_thickness) {
    translate([0, -tuning_slide_radius *2, total_bell_height-tuning_slide_small_length])

    cylinder(h = tuning_slide_small_length + tuning_sleeve_extra_length, r = tuning_slide_small_radius + tuning_slide_wall_thickness + tuning_slide_spacing + wall_thickness);
    
    translate([0, -tuning_slide_radius *2, total_bell_height])

    cylinder(h=10, r2=neck_pipe_radius+wall_thickness, r1=tuning_slide_small_radius + +tuning_slide_wall_thickness + tuning_slide_spacing + wall_thickness);


    //TODO: at the bottom, slant towards the neckpipe or we will not have a good connection!
}

module render_bell_segment(render_bottom_lip, render_top_lip, min_height, max_height) {
    //rath R4 profile
    
    // leadpipe 26.145 mouthpiece ends at 0.664 mm
    // 0.695 inner slide diameter, 139.439 cm long (extends, of course)
    //  0.725 neck pipe,  26.910 cm long

  /*  
    //tuning slide bow. 
    //TODO: curve this thing. define wall thickness so it fits
    //TODO: add the inner tuning slides at both ends. 
    //TODO: inner tuning slide at bell end, 9.9mm inner, 10.53 outer diameter
    translate([0,0, -55.93-96.85-150.42-150.42-53.36-67.32-219.90])
        conic_tube(h=219.90, r1=7.55, r2=9.90, wall=bell_thickness);//sudden jump in profile. add some wall width to make this    
        */
    
    
    //bell, combination of bessel shapes and one bit of conical tubing:
    //TODO: this seems to bewithout the tuning slide cylinder on top!
         
    
    polygon = cut_curve_at_height2( //bell_polygon,
            cut_curve_at_height(bell_polygon, min_height, max_height)
        , min_height, max_height);

    //TODO: cut polygon at desired height and start at desired height
    //for the current part
    
    //render the joint to be glued

    echo("start and end of polygon: " );
    echo(polygon[0]);
        echo(polygon[len(polygon)-1]);

    rotate_extrude()
    if(render_top_lip && render_bottom_lip) {
        union() {
            bottom_joint(polygon);
            top_joint(polygon);
            extrude_line(polygon, bell_thickness);
        }
    }
    else if(render_top_lip) {
        union() {
                /* render the connecting lip on top of the polygon */
            top_joint(polygon);
            extrude_line(polygon, bell_thickness);
        };
    } else if (render_bottom_lip) {
        union() {
            bottom_joint(polygon);
            extrude_line(polygon, bell_thickness);
        }
    } else {
        extrude_line(polygon, bell_thickness);
    };

  //  translate(polygon[0] + [0,-1])
//        polygon(inner_lip);
}

module solid_bell() {
    rotate_extrude()   
    bell_profile();
}

module bell_profile() {
    extrude_solid(bell_polygon, bell_thickness);
}



module top_joint(polygon) {
    difference() {
        translate(polygon[0]) {
            difference() {
                polygon([[0, 0], [0, joint_slanted_bottom], [joint_width, joint_depth], [joint_width, 0]]);
                polygon(lip);
            };    
        };
        extrude_solid(polygon);
    };
}

module bottom_joint(polygon) {
    difference() {
        translate(polygon[len(polygon)-1]) {
            union() {    
              polygon([[0, 0], [0, -joint_slanted_bottom], [0, -joint_depth], [joint_width, 0]]);              
                polygon(inner_lip);
            }
  
        };
        extrude_solid(polygon);
    };
}

//bessel_curve(throat_radius=10.51, mouth_radius=108.06, length=-(-55.93-96.85-150.42-150.42), flare=0.78);
/* 
Renders a cone shaped tube.
wall is wall thickness
*/
module conic_tube(h, r1, r2, wall, center = false) {
  difference() {
          cylinder(h=h, r1=r1+wall, r2=r2+wall, center=center);
          cylinder(h=h, r1=r1, r2=r2, center=center);
  }
}

module conic_tube_conic_wall(h, r1, r2, wall1, wall2, center = false) {
  difference() {
          cylinder(h=h, r1=r1+wall2, r2=r2+wall1, center=center);
          cylinder(h=h, r1=r1, r2=r2, center=center);
  }
}

/*
* Bessel horn bell equation from
* http://www.acoustics.ed.ac.uk/wp-content/uploads/Theses/Braden_Alistair__PhDThesis_UniversityOfEdinburgh_2006.pdf
*/


module bessel_curve2(translation=0, throat_radius, mouth_radius, length, flare) {    

   2d_bessel = 2d_bessel_polygon(translation, throat_radius, mouth_radius, length, flare);

    extrude_line(2d_bessel, bell_thickness);   

}

module extrude_solid(curve) {
    polygon( points=
       concat(
        curve,
        [[0, 0]],
        [ [0, curve[0][1]]]
        )
    );
}

EPSILON = 0.00000001;
function abs_diff(o1, o2) =
    abs(o1-o2);
    
//from a single line, make a wall_thickness wide 2d polygon.
//translates along the normal vector without checking direction, so be careful :)steps
module extrude_line(input_curve, wall_thickness) {
    //remove consecutive points that are the same. Can't have that here or we'll have very strange results
    extrude_curve = concat([input_curve[0]], [for (i = [1:1:len(input_curve)-1]) if(abs_diff(input_curve[i][1], input_curve[i-1][1]) > EPSILON ) input_curve[i]]);

    polygon( points=
       concat(
        [extrude_curve[0]],
        [for (i = [1:1:len(extrude_curve)-1]) 
                extrude_curve[i]
        ],
        [extrude_curve[len(extrude_curve)-1]+[wall_thickness, 0]],
        [for (i = [len(extrude_curve)-1:-1:1]) 
                extrude_curve[i] + 
                unit_normal_vector(
                    extrude_curve[i-1],
                    extrude_curve[i]
                )*wall_thickness
        ],
        //add the top most part, make sure it ends with a horizontal edge
        //so it can be joined to another surface if needed.
        [extrude_curve[0]+[wall_thickness,0]]
        )
       
    );
}


function 2d_bessel_polygon(translation=0, throat_radius, mouth_radius, length, flare) =    

    //inner curve of the bell
    let(
        b = bessel_b_parameter(throat_radius, mouth_radius, length, flare),
        x_zero = bessel_x_zero_parameter(throat_radius, b, flare),
        step_size = (length-x_zero)/steps
    )


    [for (i = array_iterator(x_zero, step_size, x_zero + length)) 
         [bell_diameter(b, i, flare), i-(x_zero+length)] + [0, translation]
    ];


function bell_diameter(B, y, a) =
//   B/pow(y + y_zero,a);
   B*pow(-y,-a);
    
    
function bessel_b_parameter(r0, r1, d, gamma) =
    pow(
    (d/
        (
            pow(r0, -1/gamma) - 
            pow(r1, -1/gamma)
        )
    ), gamma);
 
function bessel_x_zero_parameter(r0, b, gamma) =
    - pow(r0/b, -1/gamma);
    
    
function unit_normal_vector(p1, p2) =
    let(
        dx = p2[0]-p1[0],
        dy = p2[1]-p1[1]
        ) 
        [dy, -dx]/norm([dy,-dx]);

function cut_curve_at_height(curve, min_height, max_height) =
    concat(
        [
            for (i = [0:1:len(curve)-2])
                if(curve[i+1][1] >= min_height)// && curve[i][1] <= max_height)
                   curve[i]             
        ],
        [for (i = [len(curve)-1]) if(curve[i][1] >= min_height) curve[i]]
    );
            
function cut_curve_at_height2(curve, min_height, max_height) =

    concat(
        [for (i = [0]) if(curve[i][1] <= max_height) curve[0]],
        [
        for (i = [1:1:len(curve)-1])
            if( curve[i][1] <= max_height)
               curve[i]             
        ]
    );

function bell_radius_at_height(curve, height) =
       [for (i = [1:1:len(curve)-1])
            if( curve[i-1][1] <= height && curve[i][1] >= height)
               curve[i][0]            
        ][0]
            ;
    
