// outer diameter of jar in mm
DIAMETER_OUTER = 62;

//  currently not for all walls in mm
WALL_THICKNESS = 2;

// height of jar without walls for thread
HEIGHT = 40;

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


// -----------------------------------------------------


$fn = 30;


difference() {
    union() {
        cylinder(d=DIAMETER_OUTER, h=HEIGHT);
        translate([0., 0., HEIGHT])
            thread();
    }

    // inside
    translate([0., 0., WALL_THICKNESS])
        cylinder(d=DIAMETER_THREAD_WALL - 2*WALL_THICKNESS, h=HEIGHT * 2);
}


// need to subtract inside
module thread() {
    translate([0., 0., (HEIGHT_THREAD_WALL - THREAD_HEIGHT)/2.]) {
        thread_outer_radius = THREAD_DIAMETER_OUTER/2.;
        linear_extrude(height=THREAD_HEIGHT, convexity = 5, twist = TWIST, slices=$fn, $fn = $fn)
            translate([(1 - THREAD_THICKNESS) * thread_outer_radius, 0., 0.])
                circle(r=THREAD_THICKNESS * thread_outer_radius);
    }

    // thread wall
    cylinder(d=DIAMETER_THREAD_WALL, h=HEIGHT_THREAD_WALL);
}
