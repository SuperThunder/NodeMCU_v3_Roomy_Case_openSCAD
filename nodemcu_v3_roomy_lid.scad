// 57.8mm for the board, doubled for sensor space
inner_length_param = 57.8;

inner_width_param = 31.0;

inner_height = 3;

// 5mm to allow for RF shield and soldered headers. Used to hold up the board by the edges
floor_to_pcb_margin = 4;
pcb_wall_margin = 0.5; //margin from the wall to the PCB edge - does result in USB port being slightly recessed

bottom_thickness = 1.5;

wall_thickness = 1.5;

snap_offset_from_top = 4;


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

height_full = bottom_thickness+inner_height;





//lid with clips
//meant to be 6mm, but ended up as 3.8mm
translate([0, 0, 0]) union()
{
    //generate empty box with cutouts
    difference()
    {
        cube([length_full, width_full, height_full], 0);
        
        // main cutout
        translate([wall_thickness, wall_thickness, bottom_thickness]) cube([inner_length_full, inner_width, inner_height+1]);
        
        //vent holes
        generate_vent_holes();
    }
    
    //snapfit clips
    generate_snapfit_clips();
    
}

//6 1cm clips. 3 on each side
//3.8mm from top to the top of the 2mm height triangle
module generate_snapfit_clips()
{
    hole_width = 12; //needed so that clip can be centered in hole
    clip_width = 11.5;
    clip_triangle_base = 2;
    clip_triangle_height = 2.5;
    
    spacer_thickness = 1.0;
    
    riser_thickness = 2;
    riser_height = bottom_thickness + inner_height + snap_offset_from_top + clip_triangle_base;
    
    //put holes at 10, 45, 90%
    //clip_y_offset = -1*hole_thickness/2;
    base_x_offset = wall_thickness + 0.10*inner_length_full;
    
    triangle_z_offset = height_full + snap_offset_from_top;
    
    //along y axis
    translate([(hole_width-clip_width)/2, 0, 0]) generate_snapfit_line();
    //along far wall
    //since we need the clips to face inwards, mirror along XZ axis through origin then translate
    translate([(hole_width-clip_width)/2, width_full, 0]) mirror([0,1,0]) generate_snapfit_line();
    
    //generate a line of 3
    module generate_snapfit_line()
    {
        translate([base_x_offset, 0, 0]) generate_snapfit_assembly(); 
        translate([base_x_offset + inner_length_full*0.35, 0, 0]) generate_snapfit_assembly();
        translate([base_x_offset + inner_length_full*0.7, 0, 0]) generate_snapfit_assembly();
    }
    
    //generate a single snapfit
    module generate_snapfit_assembly()
    {
        //spacer
        translate([0, -spacer_thickness, 0]) cube([clip_width, spacer_thickness+0.1, bottom_thickness+inner_height]);
        //riser
        translate([0, -spacer_thickness-riser_thickness, 0]) cube([clip_width, riser_thickness+0.1, riser_height]);
        //clip
        translate([clip_width, clip_triangle_height-spacer_thickness, riser_height-clip_triangle_base]) rotate([0, 0, 180]) prism(clip_width, clip_triangle_height, clip_triangle_base);
    }
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