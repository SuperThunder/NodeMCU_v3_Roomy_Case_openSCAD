// Case for NodeMCU v3 with enough vertical space to use dupont cables, and long enough to reduce ESP heat getting to temperature sensor


// 57.8mm for the board, doubled for sensor space
inner_length_param = 57.8;

inner_width_param = 31.0;

inner_height = 30;

// 4mm to allow for RF shield and soldered headers. Used to hold up the board by the edges
floor_to_pcb_margin = 4;
pcb_wall_margin = 0.5; //margin from the wall to the PCB edge - does result in USB port being slightly recessed

bottom_thickness = 1.5;

wall_thickness = 1.5;

inner_wall_thickness = 1.0;
inner_wall_height = 8;

//Height with margin for cable
usb_height = 7.5;

//Width with margin for cable
usb_width = 12.5;


//Corner posts
corner_post_protrusion_height = 4;
//corner_post_outer_radius = 3;
corner_post_inner_radius = 1.4;
corner_post_pcb_radius = 1.5; //M3 hole?
//used for center of support/holding posts
//edge of protruding post from x wall
corner_post_x_from_wall = 1.3;
//edge of protruding post from y wall
corner_post_y_from_wall = 1.3;


//Snapfit hole values
snapfit_hole_width = 12;
snapfit_hole_thickness = 6;
snapfit_hole_height = 3;
snapfit_hole_offset = 4; //4mm from top

//CALCULATED VALUES
//add margin so board is not pressed tight
inner_length = inner_length_param + pcb_wall_margin*2;
inner_width = inner_width_param + pcb_wall_margin*2;

//add wall thickness
inner_length_full = inner_length*2;
length_full = inner_length_full+wall_thickness*2;

width_full = inner_width+wall_thickness*2;

height_full = bottom_thickness+inner_height;

// overall case
translate([0, 0, 0]) union()
{
    //generate empty box with cutouts
    difference()
    {
        cube([length_full, width_full, height_full], 0);
        
        // main cutout
        translate([wall_thickness, wall_thickness, bottom_thickness]) cube([inner_length_full, inner_width, inner_height+1]);
        
        // USB cutout, placed in the center starting at floor height
        translate([-0.5, width_full/2 - usb_width/2, bottom_thickness]) cube([wall_thickness*3,  usb_width, usb_height+0.5]);
        
        //snapfit cutouts
        generate_snapfit_holes();
        
        //button holes
        generate_button_holes();
        
        //vent holes
        generate_rectangular_vent_holes();
        
        //todo: inner snap fit holding plate holes/structure
        //(a plate that will snap in place above the board to securely hold it in
        //possibly better just to have long posts coming out of lid
        
        
    }
    
    //corner posts
    generate_posts();
    
    //wall seperating nodemcu and sensor areas
    generate_inner_wall();
    
    //hook
    translate([length_full-0.3, width_full/2, 0]) generate_hook();
    
}



//larger radius, smaller radius, transition height, total height
module retaining_cylinder(r, h)
{
    $fn = 50;
    //cylinder(trh, ro, ro, false); 
    //translate([-ro, -ro, 0]) cube([ro*2, ro*2, trh]);
    cylinder(h, r, r, false);
}

//square support ledge
module support_ledge()
{
    //doubled to get diameter, and then +50% to get a suitable overhang
    edge_length = 2*corner_post_pcb_radius*1.5;
    //echo("edge_length of support: ");
    //echo(edge_length);
    //translated so it is centered with the cylinder
    translate([-edge_length/2, -edge_length/2, 0]) cube([edge_length, edge_length, bottom_thickness+floor_to_pcb_margin]);
}

module corner_post()
{
   // support_post(corner_post_outer_radius, corner_post_inner_radius, bottom_thickness+floor_to_pcb_margin, bottom_thickness+floor_to_pcb_margin+5);
    retaining_cylinder(corner_post_inner_radius, bottom_thickness+floor_to_pcb_margin+corner_post_protrusion_height);
}

module generate_posts()
{   
 //offset from y axis and PCB hole to hole distance
 x_offset = wall_thickness + corner_post_x_from_wall + corner_post_pcb_radius + pcb_wall_margin;
 y_offset = corner_post_pcb_radius + wall_thickness + corner_post_y_from_wall + pcb_wall_margin;
 x_cross = inner_length - 2*corner_post_x_from_wall - 2*corner_post_pcb_radius - 2*pcb_wall_margin;
 y_cross = inner_width - 2*corner_post_y_from_wall - 2*corner_post_pcb_radius - 2*pcb_wall_margin;
    
    
//The bottom square supports are shifted to nestle them in the corner
//bottom right
 translate([x_offset, y_offset, 0]) union()
 {
    translate([-0.4, -0.5, 0]) support_ledge();
    corner_post();
 }
    
//bottom left
 translate([x_offset, y_offset+y_cross, 0]) union()
 {
    translate([-0.4, 0.5, 0]) support_ledge();
    corner_post();   
 }

//top right
 translate([x_offset + x_cross, y_offset, 0]) union()
 {
    support_ledge();
    corner_post();    
 }

//top left
 translate([x_offset + x_cross, y_offset + y_cross, 0]) union()
 {
    support_ledge();
    corner_post();      
 }

}

module generate_inner_wall()
{
   triangle_length = inner_width / 6;
   triangle_height = height_full - snapfit_hole_height - snapfit_hole_offset/2 - inner_wall_height - bottom_thickness;
    
   translate([inner_length+10, wall_thickness, 0]) union()
   {   
    //lower rectangular portion 
    cube([inner_wall_thickness, inner_width+0.4, inner_wall_height+bottom_thickness]);
       
    //triangular support on left and  right
    //y axis wall
    translate([inner_wall_thickness, triangle_length, inner_wall_height]) rotate([0, 0, 180]) prism(inner_wall_thickness, triangle_length, triangle_height);
       
    //far y wall
    translate([0, inner_width-triangle_length, inner_wall_height]) rotate([0, 0, 0]) prism(inner_wall_thickness, triangle_length, triangle_height);
       
   }
}

//6 1cm holes, 3 on each side
module generate_snapfit_holes()
{
    
    hole_width = snapfit_hole_width;
    hole_thickness = snapfit_hole_thickness;
    hole_height = snapfit_hole_height;
    hole_offset = snapfit_hole_offset;
    
    //put holes at 10, 45, 90%
    hole_y_offset = -1*hole_thickness/2;
    base_x_offset = wall_thickness + 0.10*inner_length_full;
    
    hole_z_offset = height_full - hole_height - hole_offset; //4mm from top
    
    //along y axis
    gen_hole_line();
    //along far y wall
    translate([0, width_full, 0]) gen_hole_line();
    
    
    module gen_hole_line()
    {
        translate([base_x_offset, hole_y_offset, hole_z_offset]) cube([hole_width, hole_thickness, hole_height]); 
        translate([base_x_offset + inner_length_full*0.35, hole_y_offset, hole_z_offset]) cube([hole_width, hole_thickness, hole_height]);
        translate([base_x_offset + inner_length_full*0.7, hole_y_offset, hole_z_offset]) cube([hole_width, hole_thickness, hole_height]);
    }
    
}

module generate_button_holes()
{
    button_hole_x = 5;
    button_hole_y = 3.8;
    
    //distance from PCB edge to button along width
    button_distance_from_edge_y = 5.6;
    button_distance_from_edge_x = 2.2;
    
    //RST button
    //subtract half of cube width to center it
    translate([wall_thickness+button_distance_from_edge_x, wall_thickness + button_distance_from_edge_y, 0]) cube([button_hole_x, button_hole_y, bottom_thickness*1.5]);
    
    //Flash button
    translate([wall_thickness+button_distance_from_edge_x, width_full-wall_thickness-button_distance_from_edge_y - button_hole_y, 0]) cube([button_hole_x, button_hole_y, bottom_thickness*1.5]);
    
}

module generate_rectangular_vent_holes()
{
    //closer wall
    translate([length_full * 3/5 + 2, -2 , bottom_thickness+1]) generate_vent_line(5, 18, 4, 5, 4.5);
    
    //far wall
    translate([length_full * 3/5 + 2, width_full-2, bottom_thickness+1]) generate_vent_line(5, 18, 4, 5, 4.5);
    
    //far wall
    translate([length_full+2, (width_full - total_vent_line_length(6, 2, 3))/2, bottom_thickness+1]) rotate([0,0,90]) generate_vent_line(6, 20, 2, 5, 4.5);
    
    //bottom of sensor bay
    translate([length_full - total_vent_line_length(8, 2, 3) - 10, (width_full-24)/2, bottom_thickness+1]) rotate([-90,0,0]) generate_vent_line(7, 24, 2, 5, 4.5);
    
    
    module generate_vent_line(count, height, width, thickness, spacing)
    {
        function xpos(n,wi,sp) = n*wi + n*sp;
        
        //generate the specified size holes at the given spacing
        for(i = [0:1:count-1])
        {            
            //echo("xpos:");
            //echo(xpos(i,width,spacing));
            translate([xpos(i,width,spacing), 0, 0]) gen_hole();  
        }
        
        module gen_hole()
        {
            cube([width, thickness, height]);
        }
    }
    
    //calculate total length from the left of the first vent hole to the right of the last
    function total_vent_line_length(count, width, spacing) = 
       count*(width+spacing) - spacing;
    
}

//put hook at sensor end
module generate_hook()
{
    hook_outer_radius = 17;
    hook_inner_radius = 15;
    hook_height = 3;
    
    difference()
    {
        cylinder(hook_height, hook_outer_radius, hook_outer_radius, $fn=24);
        
        cylinder(hook_height, hook_inner_radius, hook_inner_radius, $fn=24);
        translate([-2*hook_outer_radius, -hook_outer_radius, 0]) cube([hook_outer_radius*2, hook_outer_radius*2, hook_height]);
        
    }
}


//from https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
//makes 3D triangles
module prism(l, w, h){
   polyhedron(
           points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
           faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
           );
  
   }