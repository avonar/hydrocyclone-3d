$fn = 128;
render_mode = is_undef(render_mode) ? "assembly" : render_mode;

// Parametric hydrocyclone concept for layout and 3D-print iteration.
// Units: millimeters.
// This is a geometry study model, not a certified pressure vessel.

dc = 40; // Inner diameter of cylindrical vortex chamber
hc = 40; // Height of cylindrical vortex chamber
lc = 120; // Cone length
do_inner = 14; // Vortex finder inner diameter
vf_insert = 16; // Vortex finder insertion depth below the removable lid
du = 9; // Lower outlet diameter
bottom_stub_len = 36; // Lower straight outlet for connection to a separate collector
bottom_stub_od = 22; // Outer diameter of the lower outlet stub

wall = 4; // Minimum wall thickness
top_cap = 6; // Removable lid thickness
flange_thickness = 6; // Body flange thickness at the split line
join_overlap = 2; // Solid overlap so boolean unions stay connected
port_overlap = 4; // Extra overlap for bores so they remain visibly through
vf_outer_od = do_inner + 2 * wall; // Solid inner sleeve diameter of the vortex finder

outlet_stub_len = 48; // Straight outlet stub above the removable lid
outlet_stub_od = 32; // Outer diameter of outlet stub
outlet_stub_id = 26; // Bore for top outlet connection
outlet_transition_len = 14; // Internal transition length from the 32 mm connector bore to the vortex finder

inlet_pipe_od = 32; // External connection sized for a 32 mm pipe
inlet_pipe_id = 26; // Approximate bore for a 32 mm PE/PND pipe connection
inlet_slot_w = 8; // Tangential slot width at the chamber wall
inlet_slot_h = 10; // Tangential slot height
inlet_outer_slot_w = inlet_slot_w + 2 * wall;
inlet_outer_slot_h = inlet_slot_h + 2 * wall;
inlet_stub_len = 48; // Straight external pipe length before the transition
inlet_transition_len = 22; // Reducer length from the pipe connection to the nozzle
inlet_body_penetration = 8; // Outer reducer penetration into the main body for a true union
inlet_nozzle_intrusion = 4; // Inner flow penetration into the chamber
inlet_z = 10; // Lower Z of the tangential slot from the open chamber top

flange_od = 72; // Outer diameter of the split flange for the printable body/lid joint
flange_hole_d = 4.5; // Through holes for M4 hardware
flange_hole_count = 4; // Bolt count around the flange
flange_bcd = 60; // Bolt circle diameter
bolt_angle_offset = 6.25; // Rotate the bolt pattern away from the inlet stub without moving the next hole under the opposite pipe

outer_dc = dc + 2 * wall;
outer_du = du + 2 * wall;

cone_z = hc;
bottom_stub_z = cone_z + lc;
inlet_outer_slot_center_y = outer_dc / 2 - inlet_outer_slot_w / 2;
inlet_slot_center_y = dc / 2 - inlet_slot_w / 2;
inlet_pipe_center_y = inlet_outer_slot_center_y;
inlet_center_z = inlet_z + inlet_slot_h / 2;
split_raise = max(2, inlet_pipe_od / 2 - inlet_center_z + 2); // Lift the split plane above the round inlet crown
vf_tip_margin_below_inlet = 8; // Push the vortex finder tip clearly below the inlet window to reduce short-circuit flow
vf_insert_min_visible = inlet_z + inlet_slot_h + split_raise + vf_tip_margin_below_inlet; // Keep the vortex finder tip below the inlet opening when viewed from the feed side
vf_insert_effective = max(vf_insert, vf_insert_min_visible);

module bolt_holes(z0, h) {
  for (i = [0:flange_hole_count - 1])
    rotate([0, 0, bolt_angle_offset + i * 360 / flange_hole_count])
      translate([flange_bcd / 2, 0, z0])
        cylinder(h=h, d=flange_hole_d);
}

module inlet_outer_manifold() {
  union() {
    translate([-inlet_stub_len - inlet_transition_len - join_overlap, inlet_pipe_center_y, inlet_center_z])
      rotate([0, 90, 0])
        cylinder(h=inlet_stub_len + join_overlap, d=inlet_pipe_od);

    hull() {
      translate([-inlet_transition_len - join_overlap, inlet_pipe_center_y, inlet_center_z])
        rotate([0, 90, 0])
          cylinder(h=1 + join_overlap, d=inlet_pipe_od);
      translate(
        [
          inlet_body_penetration - 1,
          inlet_outer_slot_center_y - inlet_outer_slot_w / 2,
          inlet_z - wall,
        ]
      )
        cube([1, inlet_outer_slot_w, inlet_outer_slot_h]);
    }
  }
}

module inlet_flow_volume() {
  union() {
    translate([-inlet_stub_len - inlet_transition_len - join_overlap - 1, inlet_pipe_center_y, inlet_center_z])
      rotate([0, 90, 0])
        cylinder(h=inlet_stub_len + join_overlap + 1, d=inlet_pipe_id);

    hull() {
      translate([-inlet_transition_len - join_overlap, inlet_pipe_center_y, inlet_center_z])
        rotate([0, 90, 0])
          cylinder(h=1 + join_overlap, d=inlet_pipe_id);
      translate(
        [
          0,
          inlet_slot_center_y - inlet_slot_w / 2,
          inlet_z,
        ]
      )
        cube([1, inlet_slot_w, inlet_slot_h]);
    }

    // Shape the final slot opening by the chamber radius instead of a flat nozzle end.
    intersection() {
      translate(
        [
          -1,
          inlet_slot_center_y - inlet_slot_w / 2,
          inlet_z,
        ]
      )
        cube([inlet_nozzle_intrusion + 1, inlet_slot_w, inlet_slot_h]);
      translate([0, 0, -join_overlap])
        cylinder(h=hc + 2 * join_overlap, d=dc);
    }
  }
}

module body_outer_shell() {
  union() {
    translate([0, 0, -split_raise])
      cylinder(h=flange_thickness + split_raise, d=flange_od);
    translate([0, 0, -split_raise])
      cylinder(h=hc + split_raise, d=outer_dc);
    translate([0, 0, cone_z])
      cylinder(h=lc, d1=outer_dc, d2=outer_du);
    translate([0, 0, bottom_stub_z - port_overlap])
      cylinder(h=bottom_stub_len + port_overlap, d=bottom_stub_od);

    inlet_outer_manifold();
  }
}

module body_flow_volume() {
  union() {
    translate([0, 0, -split_raise - 1])
      cylinder(h=hc + split_raise + 1, d=dc);
    translate([0, 0, cone_z])
      cylinder(h=lc, d1=dc, d2=du);
    translate([0, 0, bottom_stub_z - port_overlap])
      cylinder(h=bottom_stub_len + wall + port_overlap, d=du);

    inlet_flow_volume();
    bolt_holes(-split_raise - 1, flange_thickness + split_raise + 2);
  }
}

module lid_outer_shell() {
  union() {
    translate([0, 0, -split_raise - top_cap])
      cylinder(h=top_cap, d=flange_od);
    translate([0, 0, -split_raise - top_cap - outlet_stub_len])
      cylinder(h=outlet_stub_len + port_overlap, d=outlet_stub_od);
    translate([0, 0, -split_raise - top_cap])
      cylinder(h=top_cap + vf_insert_effective, d=vf_outer_od);
  }
}

module lid_flow_volume() {
  union() {
    translate([0, 0, -split_raise - top_cap - outlet_stub_len - port_overlap - 1])
      cylinder(h=outlet_stub_len + top_cap + port_overlap + 1 - outlet_transition_len, d=outlet_stub_id);
    translate([0, 0, -split_raise - outlet_transition_len])
      cylinder(h=outlet_transition_len, d1=outlet_stub_id, d2=do_inner);
    translate([0, 0, -split_raise - port_overlap])
      cylinder(h=vf_insert_effective + port_overlap, d=do_inner);

    bolt_holes(-split_raise - top_cap - 1, top_cap + 2);
  }
}

module hydrocyclone_body_part() {
  difference() {
    body_outer_shell();
    body_flow_volume();
  }
}

module hydrocyclone_lid_part() {
  difference() {
    lid_outer_shell();
    lid_flow_volume();
  }
}

module hydrocyclone_assembly() {
  hydrocyclone_body_part();
  hydrocyclone_lid_part();
}

module hydrocyclone_exploded() {
  hydrocyclone_body_part();
  translate([0, 0, -split_raise - top_cap - 12])
    hydrocyclone_lid_part();
}

if (render_mode == "none")
  ;
else if (render_mode == "body")
  hydrocyclone_body_part();
else if (render_mode == "lid")
  hydrocyclone_lid_part();
else if (render_mode == "exploded")
  hydrocyclone_exploded();
else
  hydrocyclone_assembly();
