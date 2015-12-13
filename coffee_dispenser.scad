// outer diameter of jar in mm
DIAMETER_OUTER = 62;

//  currently not for all walls in mm
WALL_THICKNESS = 2;

// height of jar without walls for thread
CONTAINER_HEIGHT = 40;

// thickness (height) of thread, must be 0 < x < 1 (0 very sharp, 1 very thick)
THREAD_THICKNESS = 0.9;

// outer diameter of wall where thread is in mm
DIAMETER_THREAD_WALL = 52;

//
THREAD_HEIGHT = 3;

// how many degrees for thread
TWIST = -320;

// should be >= THREAD_HEIGHT
HEIGHT_THREAD_WALL =  9.2;

// outer diameter of thread in mm
THREAD_DIAMETER_OUTER = 55;



// helps to spread coffee on paddles, should be < WHEEL_WIDTH
UPPER_HOLE_DIAMETER = 22;
LOWER_HOLE_DIAMETER = UPPER_HOLE_DIAMETER;
UPPER_CONE_HEIGHT = 10;
LOWER_CONE_HEIGHT = UPPER_CONE_HEIGHT;


// wheel
NUM_PADDLES = 5;   // minimum: dependent on UPPER_HOLE_DIAMETER
DIAMETER_WHEEL = 50;
WHEEL_WALL_THICKNESS = 1;
WHEEL_WIDTH = 30;

WHEEL_DISTANCE_TO_INNER = 2;

// Diameter of axis for wheel (in mm)
WHEEL_AXIS_DIAMETER = 3;


// show open for more insight
SLICE_THROUGH_X = false;
SLICE_THROUGH_Y = false;

// which parts to include...
SHOW_COFFE_DISPENSER_HULL = true;
SHOW_WHEEL = false;
SHOW_AXIS = false;


$fn = 30;


/** TODO
 * How to place the Sieb underneath?
 * Handle for turning
 * Cut it to be able to put wheel inside
 * Stoppers for turning
 * Calculating volume of coffee in container and wheel
 * Make round edges
 * Window to see if there is coffee inside
 */


// -----------------------------------------------------

diam_wheel_space = DIAMETER_WHEEL + 2*WHEEL_DISTANCE_TO_INNER;


difference() {
    union() {
        if (SHOW_COFFE_DISPENSER_HULL)
            coffe_dispenser_hull();
        if (SHOW_WHEEL)
            wheel();
        if (SHOW_AXIS)
            axis();
    }
    union() {
        if (SLICE_THROUGH_X)
            translate([0., -500., -500.])
                cube([1000, 1000, 1000]);
        if (SLICE_THROUGH_Y)
            translate([-500., 0., -500.])
                cube([1000, 1000, 1000]);
    }
}



module coffe_dispenser_hull() {
    difference() {
        outer_shape();
        inner_shape();
    }
}



module outer_shape() {
    translate([0., 0., -diam_wheel_space/2. - LOWER_CONE_HEIGHT]) {
        total_height = CONTAINER_HEIGHT + UPPER_CONE_HEIGHT
            + diam_wheel_space + LOWER_CONE_HEIGHT;
        cylinder(d=DIAMETER_OUTER, h=total_height);
        translate([0., 0., total_height])
            thread();
    }
}



module inner_shape() {
    // FIXME should not be DIAMETER_THREAD_WALL but DIAMETER_OUTER
    inner_diameter = DIAMETER_THREAD_WALL - 2*WALL_THICKNESS;
    sphere_center_to_cone = sqrt(pow(diam_wheel_space/2., 2)
            - pow(UPPER_HOLE_DIAMETER/2., 2));

    translate([0., 0., UPPER_CONE_HEIGHT + sphere_center_to_cone])
        cylinder(d=inner_diameter, h=2*CONTAINER_HEIGHT + HEIGHT_THREAD_WALL);
    translate([0., 0., sphere_center_to_cone])
        cylinder(d1=UPPER_HOLE_DIAMETER, d2=inner_diameter,
                h=UPPER_CONE_HEIGHT);
    sphere(d=diam_wheel_space);

    translate([0., 0., -diam_wheel_space/2.]) {
        cylinder(d=diam_wheel_space, h=diam_wheel_space/2.);
        translate([0., 0., -UPPER_CONE_HEIGHT])
            cylinder(d1=LOWER_HOLE_DIAMETER, d2=diam_wheel_space,
                    h=LOWER_CONE_HEIGHT);
    }
}





// ------- axis -------

module axis() {
    rotate([90., 0., 0.]) {
        cube([WHEEL_AXIS_DIAMETER, WHEEL_AXIS_DIAMETER,
                WHEEL_WIDTH + WHEEL_WALL_THICKNESS*2], center=true);
        // TODO
        cylinder(d=WHEEL_AXIS_DIAMETER, h=100, center=true);
    }

}


// ------- wheel -------

module wheel() {
    intersection() {
        difference() {
            union() {
                _wheel_paddles();
                _wheel_discs();
                rotate([90., 0., 0.])
                    cylinder(d=2*WHEEL_AXIS_DIAMETER,
                            h=WHEEL_WIDTH, center=true);
            }
            axis_hole_size = WHEEL_AXIS_DIAMETER; // + something
            rotate([90., 0., 0.])
                cube([axis_hole_size, axis_hole_size,
                        2*(WHEEL_WIDTH+WHEEL_WALL_THICKNESS)], center=true);
        }

        // bounding sphere
        sphere(d=DIAMETER_WHEEL);
    }
}

module _wheel_paddles() {
    angle = 360./NUM_PADDLES;
    for(r = [0.:angle:360.]) {
        rotate([90., r, 0.])
            translate([DIAMETER_WHEEL/4., 0., 0.])
                cube([DIAMETER_WHEEL/2., WHEEL_WALL_THICKNESS, WHEEL_WIDTH],
                        center=true);
    }
}

module _wheel_discs() {
    for(i = [-1, 1]) {
        translate([0., i * (WHEEL_WIDTH + WHEEL_WALL_THICKNESS)/2., 0.])
            rotate([90., 0., 0.])
                cylinder(d=DIAMETER_WHEEL, h=WHEEL_WALL_THICKNESS,
                        center=true);
    }
}

// ------- END wheel -------



module thread() {
    // full, need to subtract inner
    translate([0., 0., (HEIGHT_THREAD_WALL - THREAD_HEIGHT)/2.]) {
        thread_outer_radius = THREAD_DIAMETER_OUTER/2.;
        linear_extrude(height=THREAD_HEIGHT, convexity = 5, twist = TWIST,
                        slices=$fn, $fn = $fn)
            translate([(1 - THREAD_THICKNESS) * thread_outer_radius, 0., 0.])
                circle(r=THREAD_THICKNESS * thread_outer_radius);
    }

    // thread wall
    cylinder(d=DIAMETER_THREAD_WALL, h=HEIGHT_THREAD_WALL);
}
