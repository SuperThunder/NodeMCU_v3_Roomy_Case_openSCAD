// 57.8mm for the board, doubled for sensor space
inner_length_param = 57.8;

inner_width_param = 31.0;

//inner_height = 3;


pcb_wall_margin = 0.5; //margin from the wall to the PCB edge - does result in USB port being slightly recessed


//Values used to get retaining posts to know where the board is and corner post protrusions are so we can avoid conflicting with them with our holding columns 
// 4mm to allow for RF shield and soldered headers. Used to hold up the board by the edges
floor_to_pcb_margin = 4;
case_inner_height = 30;
nodemcu_v3_pcb_thickness = 1.6;
corner_post_protrusion_height = 4;
corner_post_inner_radius = 1.4;
corner_post_pcb_radius = 1.5; //M3 hole?
//edge of protruding post from x wall
corner_post_x_from_wall = 1.3;
//edge of protruding post from y wall
corner_post_y_from_wall = 1.3;


bottom_thickness = 1.6;

wall_thickness = 2;

//snap_offset_from_top_nominal = 4;
//snap_offset_droop_margin = 0.1; //the snapfit triangles tend to sag, when printing, so make the post a little taller to account for this


//Values for snap fit mechanism
triangle_mount_base = 3;
triangle_mount_length = 14;
triangle_mount_dist_from_top = 1;


//CALCULATED VALUES
//add margin so board is not pressed tight
inner_length = inner_length_param + pcb_wall_margin*2;
inner_width = inner_width_param + pcb_wall_margin*2;

//TODO use above values if printed case has PCB wall margin
//inner_length = inner_length_param;
//inner_width = inner_width_param;

//add wall thickness
inner_length_full = inner_length*2;
length_full = inner_length_full+wall_thickness*2;

width_full = inner_width+wall_thickness*2;

//height_full = bottom_thickness+inner_height;

//account for potential droop
//snap_offset_from_top = snap_offset_from_top_nominal + snap_offset_droop_margin;


module generate_snapfit_solids(count, length)
{
    interval = length_full / 2 / count;
    
    //left side
    for(i = [0:count-1])
    {
        translate([2*i*interval + interval, width_full/2, 0]) snapfit_solid();
    }
    
    module snapfit_solid()
    {
        //the total height of the mount
        total_mount_height = triangle_mount_dist_from_top+triangle_mount_base;
        
        translate([0,-width_full/2+wall_thickness+triangle_mount_base, total_mount_height/2]) cube([length, triangle_mount_base*2, total_mount_height], center=true);
        translate([0,-width_full/2+wall_thickness, triangle_mount_dist_from_top]) triangle_mount(triangle_mount_base, wall_thickness/2, length);
    }
    
}

//lid with clips
//meant to be 6mm, but ended up as 3.8mm
translate([0, 0, 0]) union()
{
    
    
    //generate empty box with cutouts
    difference()
    {
        //cube([length_full, width_full, height_full], 0);
        
        //flat plate
        cube([length_full, width_full, bottom_thickness], 0);
        
        // main cutout
        //translate([wall_thickness, wall_thickness, bottom_thickness]) cube([inner_length_full, inner_width, inner_height+1]);
        
        //vent holes
        generate_vent_holes();
    }
    
    translate([0,0,bottom_thickness]) generate_snapfit_solids(3, triangle_mount_length);
    translate([0,width_full,bottom_thickness]) mirror([0,1,0]) generate_snapfit_solids(3, triangle_mount_length);
    
    
            //translate([length_full/4,-width_full/2+triangle_mount_base*2, triangle_mount_dist_from_top/2+bottom_thickness/2+triangle_mount_base/2]) cube([triangle_mount_length, triangle_mount_base*2, triangle_mount_dist_from_top+triangle_mount_base], center=true);
        //translate([length_full/4,-width_full/2+triangle_mount_base, triangle_mount_dist_from_top+bottom_thickness/2]) triangle_mount(triangle_mount_base, wall_thickness/2, triangle_mount_length);
            
        //bottom right triangle mount
//        translate([-ir_case_length/4,-ir_case_full_width/2+triangle_mount_base*2, triangle_mount_dist_from_top/2+lid_thickness/2+triangle_mount_base/2]) cube([triangle_mount_length, triangle_mount_base*2, triangle_mount_dist_from_top+triangle_mount_base], center=true);
//        translate([-ir_case_length/4,-ir_case_full_width/2+triangle_mount_base,triangle_mount_dist_from_top+lid_thickness/2]) triangle_mount(triangle_mount_base, wall_thickness/2, triangle_mount_length);
//            
//        //top left triangle mount
//        translate([ir_case_length/4,ir_case_full_width/2-triangle_mount_base*2, triangle_mount_dist_from_top/2+lid_thickness/2+triangle_mount_base/2]) cube([triangle_mount_length, triangle_mount_base*2, triangle_mount_dist_from_top+triangle_mount_base], center=true);
//        translate([ir_case_length/4,ir_case_full_width/2-triangle_mount_base,triangle_mount_dist_from_top+lid_thickness/2]) mirror([0,1,0]) triangle_mount(triangle_mount_base, wall_thickness/2, triangle_mount_length);
//            
//        //bottom left triangle mount
//        translate([-ir_case_length/4,ir_case_full_width/2-triangle_mount_base*2, triangle_mount_dist_from_top/2+lid_thickness/2+triangle_mount_base/2]) cube([triangle_mount_length, triangle_mount_base*2, triangle_mount_dist_from_top+triangle_mount_base], center=true);
//        translate([-ir_case_length/4,ir_case_full_width/2-triangle_mount_base,triangle_mount_dist_from_top+lid_thickness/2]) mirror([0,1,0]) triangle_mount(triangle_mount_base, wall_thickness/2, triangle_mount_length);
    //}
    
    //snapfit clips
    //generate_snapfit_clips();
    
    //holding posts/columns to hold board in place
    //too fragile, snap off and make it hard to put the lid on
    //generate_holding_posts();
    
    //TODO: make 2-3 'walls' sticking up from the lid to prevent the top of the sensor walls from being squeezed inwards and causing layer separation about the PCB
    //the walls could then potentially taper inwards to hold in the board
    
}


module generate_vent_holes()
{
    //top of sensor bay
    translate([length_full - total_vent_line_length(8, 2, 3) - 6, (width_full-24)/2, bottom_thickness+1]) rotate([-90,0,0]) generate_vent_line(8, 24, 2, 5, 3);
    
    
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

//from https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
module prism(l, w, h){
   polyhedron(
           points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
           faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
           );
  
   }
   
//from https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
//makes 3D triangles
module prism_isos(l, w, h){
   polyhedron(
           points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w/2,h], [l,w/2,h]],
           faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
           );
  
}

module triangle_mount(base, height, length)
{
    translate([-length/2,0,base/2]) rotate([90,0,0]) union(){
        //triangle portion
        //rotate([90,0,-90]) 
        translate([0,-base/2,0]) prism_isos(length,base,height);
        
        //rectangular support
        //rotate([0,90,0])
        //translate([-length/2,0,base]) 
        translate([length/2,0,-base/2]) cube([length,base,base], center=true);
    }
}