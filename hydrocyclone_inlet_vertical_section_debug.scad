use <hydrocyclone_concept.scad>

// XZ section through the inlet centerline of the current assembly.
// This file intentionally mirrors only the cut-plane position so the geometry comes from the main model.

inlet_pipe_center_y = 16;

projection(cut = true)
  translate([0, 0, -inlet_pipe_center_y])
    rotate([90, 0, 0])
      hydrocyclone_assembly();
