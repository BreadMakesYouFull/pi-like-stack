// pi-like-stack
// Stack pi-like boards on top of one another
// 85mm x 56mm x 20mm
// Standoffs 2.5mm diameter

// BUG (openscad): https://github.com/openscad/openscad/issues/3098
// Customizer has poor support for float input.
// Workaround: ``my_parameter = 1.0 // .01``
// Or:  ``my_parameter = 1.0 // [0:0.1:2]``
// See: "Unavailable customizations"
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer

// ----------------------------------------
// Parameters
// ----------------------------------------

$fn=15;

colour_a = [0.3, 0.3, 1.0];
colour_b = [0.42, 0.81, 0.39];

// Toggle board visiblity
board_enabled = true;

// Toggle case pillar connectors
case_minimal_enabled = true;
// Toggle case standoff connectors
case_board_connect_enabled = true;
// Toggle case slab
case_slab_enabled = false;
// Toggle hex air hole in case slab
case_slab_holes = false;

// Toggle standoff 1
standoff_1_enabled = true;
// Toggle standoff 2
standoff_2_enabled = true;
// Toggle standoff 3
standoff_3_enabled = true;
// Toggle standoff 4
standoff_4_enabled = true;

// Toggle pillars
pillars_enabled = true;

/* [Board] */

// Standard size pi-like
board_size = [85.0, 65.0, 20.0];
board_n=1;
// Half size pi-like
//board_size = [30, 65, 20];
// Duplicate board in X
//board_n=2;
// Board roundness
board_r = 3.0;  // .01

// Duplicate board gap
board_n_space = 10.0;  // .01

/* [Standoffs] */

// Standard size pi-like
// Standoff distance in X
standoff_x = 58.0;  // .01
// Standoff distance in Y
standoff_y = 49.0;  // .01

// Half size pi-like
//standoff_x = 23;  // .01
// Standoff distance in Y
//standoff_y = 58;  // .01

// Standoff height
standoff_z = 10.0;  // .01
// Standoff radius
standoff_r = 1.25;  // .01
// Standoff base radius
standoff_base_r = 2.5;  // .01
// Standoff base height
standoff_base_z = 2.5;  // .01
// Standoff distance from origin in X
standoff_offset_x = 3.5;  // .01
// Standoff distance from origin in Y
standoff_offset_y = 3.5;  // .01

/* [Case] */

// Case size in X
case_x = 100.0;  // .01
// Case size in Y
case_y = 75.0;  // .01
// Case thickness
case_z = 3.0;  // .01
// Case corner roundness
case_r = 3.0;  // .01
// Scale the air hole pattern if case slab and holes enabled
case_slab_hole_scale = 1.025;  // .01
case_slab_hole_offset = 1.0;  // .01


/* [Case pillars] */

pillar_h = 25.0;  // .01
pillar_r = 3.0;  // .01
pillar_offset_x = 6.0;  // .01
pillar_offset_y = 6.0;  // .01
pillar_dowel_h = 5.0;  // .01
pillar_dowel_r = 1.25;  // .01


// ----------------------------------------
// Utilities
// ----------------------------------------

module cube_round(
    size=[1,1,1],
    r=0.25,
    center=false,
    hull=true,
    corners=[true, true, true, true]
) {
    module _corners(){
        if(corners[0]){
            translate([r, r, 0])
            cylinder(h=size[2], r=r, center=false);
        }
        if(corners[1]){
            translate([size[0]-2*r, 0, 0])
            translate([r, r, 0])
            cylinder(h=size[2], r=r, center=false);
        }
        if(corners[2]){
            translate([0, size[1]-2*r, 0])
            translate([r, r, 0])
            cylinder(h=size[2], r=r, center=false);
        }
        if(corners[3]){
            translate([size[0]-2*r, size[1]-2*r, 0])
            translate([r, r, 0])
            cylinder(h=size[2], r=r, center=false);
        }
    }
    if (hull){
        hull()
            _corners();
    } else {
        _corners();
    }
}

module pillars(
    size=[1,1,1],
    r=0.25,
    center=false,
    size_from_pillar=false,
    corners=[true, true, true, true],
    hull=false
){
    d = r * 2;
    _size = size_from_pillar ? [size[0]+d, size[1]+d, size[2]]: size;
    _translate = size_from_pillar ? [-r, -r, 0] : [0, 0, 0];
    translate(_translate){
        cube_round(
            size=_size,
            r=r,
            center=center,
            corners=corners,
            hull=hull
        );
    }
}

// ----------------------------------------
// Components
// ----------------------------------------

module board(size=board_size, r=board_r){
    % color(colour_b, 0.5) cube_round([size[0], size[1], 1.5], r=max(r, 0.1));
}

module standoffs(
    size=[standoff_x, standoff_y, standoff_z],
    r=standoff_r,
    r2=standoff_base_r,
    z2=standoff_base_z,
    size_from_pillar=true,
    offset=[standoff_offset_x, standoff_offset_y, 0],
    corners=[
        standoff_1_enabled,
        standoff_2_enabled,
        standoff_3_enabled,
        standoff_4_enabled
    ],
    hull=false,
    base=true,
){
    translate(offset){
        if(base){
            // base for board to sit on
            pillars(
                size=[size[0], size[1], z2],
                r=r2,
                size_from_pillar=size_from_pillar,
                corners=corners,
                hull=hull
            );
        }
        // main pillar
        pillars(
            size=size,
            r=r,
            size_from_pillar=size_from_pillar,
            corners=corners,
            hull=hull
        );
    }
}

module case_slab(
    size=[case_x, case_y, case_z],
    r=case_r,
    offset=[
        -(case_x - board_size[0]*board_n)/2 + board_n_space/2*(board_n-1),
        -(case_y - board_size[1])/2,
        -case_z
    ]
){
    // Main base
    translate(offset){
        cube_round(size, r=r);
    }
}

module case_minimal(
    size=[case_x, case_y, case_z],
    r=case_r,
    offset=[-(case_x - board_size[0]*board_n)/2 + board_n_space/2*(board_n-1), -(case_y - board_size[1])/2, -case_z]
){
    // Main Base
    translate(offset){
        cube_round(size, r=r, hull=true, corners=[true, false, false, true]);
        cube_round(size, r=r, hull=true, corners=[false, true, true, false]);
    }
}
module case_minimal_standoffs(
    size=[case_x, case_y, case_z],
    r=case_r,
    offset=[-(case_x - board_size[0]*board_n)/2, -(case_y - board_size[1])/2, -case_z]
){
    translate([0, 0, -case_z]){
        standoffs( size=[standoff_x, standoff_y, case_z], corners=[true, true, false, false], hull=true, base=false);
        standoffs( size=[standoff_x, standoff_y, case_z], corners=[false, true, false, true], hull=true, base=false);
        standoffs( size=[standoff_x, standoff_y, case_z], corners=[false, false, true, true], hull=true, base=false);
        standoffs( size=[standoff_x, standoff_y, case_z], corners=[true, false, true, false], hull=true, base=false);
    }
}

module case_pillars(
    size=[
        case_x - pillar_r * 2,
        case_y - pillar_r * 2,
        case_z + board_size[2]
    ],
    r=pillar_r,
    offset=[
        -(case_x - board_size[0]*board_n)/2+pillar_r + board_n_space/2*(board_n-1),
        -(case_y - board_size[1])/2+pillar_r,
        -case_z
    ],
    h2=pillar_dowel_h,
    r2=pillar_dowel_r
){
    translate(offset){
        // Pillar main
        pillars(size=size, r=r, size_from_pillar=true);
        // Pillar dowel
        pillars(size=[size[0], size[1], size[2] + h2], r=r2, size_from_pillar=true);
    }
}

module case_pillar_holes(
    size=[ 
        case_x - pillar_r * 2,
        case_y - pillar_r * 2,
        case_z + board_size[2]
    ],
    r=pillar_r,
    offset=[
        -(case_x - board_size[0]*board_n) / 2 + pillar_r + board_n_space/2*(board_n-1),
        -(case_y - board_size[1]) / 2 + pillar_r,
        -case_z + -0.1
    ]
){
    translate(offset){
        pillars(
            size=[
                size[0],
                size[1],
                pillar_dowel_h
            ],
            r=pillar_dowel_r + 0.4,
            size_from_pillar=true
        );
    } 
}

module case_vents(
    size=[case_x, case_y, case_z],
    offset=[
        -(case_x - board_size[0]*board_n)/2 + board_n_space/2*(board_n-1) + case_slab_hole_offset,
        -(case_y - board_size[1])/2,
        -case_z
    ],
    r=case_z*3/2,
    s=case_slab_hole_scale
){
    scale([s,s,1]){
        translate(offset){
            for(i=[0:size[2]*5:size[0]*2]){
                for(j=[0:size[2]*3.25:size[1]*2]){
                    translate([i+size[2]*2.5,j+size[2]+1.5,-size[2]])
                    cylinder(d=r*2,h=size[2] * 3, $fn=6);
                translate([i,j,-size[2]])
                    cylinder(d=r*2,h=size[2] * 3, $fn=6);
                }
            }
        }
    }
}

// ----------------------------------------
// Assembly / Main
// Ran if     : ``include <filename>``
// Skipped if : ``use <filename>``
// ----------------------------------------

module main(){
    // Board
    for(i=[0:1:board_n-1]){
        translate([i * (board_size[0] + board_n_space), 0, 0]){
            if(board_enabled){ board();}
        }
    }

    // Case
    translate([0,0,-standoff_base_z]){
        color(colour_a){
            difference(){
                union(){
                    if(case_slab_enabled){
                        difference(){
                            case_slab();
                            if(case_slab_holes){
                                difference(){
                                    case_vents();
                                    case_pillars();
                                }
                            }
                        }
                    }
                    if(case_minimal_enabled){case_minimal();}
                    for(i=[0:1:board_n-1]){
                        translate([i * (board_size[0] + board_n_space), 0, 0]){
                            if(case_board_connect_enabled){case_minimal_standoffs();}
                            standoffs();
                        }
                    }
                    if(pillars_enabled){case_pillars();}
                }
                case_pillar_holes();
            }
        }
    }
}

main();