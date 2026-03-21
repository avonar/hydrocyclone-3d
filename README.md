# Hydrocyclone Prototype

This repository contains a parametric `OpenSCAD` prototype of a small household hydrocyclone / centrifugal sand separator intended as a pre-filter for well water.

The current concept is aimed at:

- `1-3 m^3/h` operating range, with `2.5 m^3/h` as the main design point
- `2-4 bar` system pressure
- `32 mm` external pipe connections
- sand and coarse suspended solids removal before a downstream filter

This is a geometry and assembly prototype, not a certified pressure vessel.

## Design Intent

The project is based on a hybrid engineering model:

- the upper part behaves like a compact hydrocyclone
- the lower part is treated as a straight underflow outlet for connection to a separate sediment collector / purge volume

Current base proportions:

- cyclone chamber diameter `Dc = 40 mm`
- cylindrical section height `Hc = 40 mm`
- cone length `Lc = 120 mm`
- vortex finder inner diameter `Do = 14 mm`
- lower outlet diameter `Du = 9 mm`
- minimum wall thickness `t = 4 mm`

The inlet is modeled as:

- external round `32 mm` stub
- internal transition to a short tangential slot

The top assembly is split into two printable parts:

- main body
- removable lid/head with the outlet stub and internal vortex finder

This split reduces support material and makes the upper internal geometry printable.

## Repository Layout

- [hydrocyclone_concept.scad](/Users/avonar/petprojects/hydrocyclone_v2/hydrocyclone_concept.scad)  
  Main source of truth for the current 3D geometry.

- [hydrocyclone_inlet_vertical_section_debug.scad](/Users/avonar/petprojects/hydrocyclone_v2/hydrocyclone_inlet_vertical_section_debug.scad)  
  Validation cut through the inlet plane. Useful for checking the inlet window and vortex finder depth relationship.

- [hydrocyclone_lid_section_debug.scad](/Users/avonar/petprojects/hydrocyclone_v2/hydrocyclone_lid_section_debug.scad)  
  Validation cut for the removable lid and inner outlet tube.

- [Makefile](/Users/avonar/petprojects/hydrocyclone_v2/Makefile)  
  Rebuilds printable artifacts and debug sections.

Generated files are written into `artifacts/`.

## Build

Requirements:

- `openscad`
- `magick` (ImageMagick) for `svg -> png` conversion

Common commands:

```bash
make -j all
```

Builds:

- body `STL`
- lid `STL`
- body `3MF`
- lid `3MF`
- assembly preview `STL`
- validation section `SVG` and `PNG` files

Other useful targets:

```bash
make -j prints
make -j validate
make preview
make print3mf
make clean
```

`Makefile` is intentionally structured so that `make -j ...` can run independent OpenSCAD renders in parallel.

## Current Outputs

After a successful build, the main outputs are:

- `artifacts/hydrocyclone_body_print.stl`
- `artifacts/hydrocyclone_lid_print.stl`
- `artifacts/hydrocyclone_body_print.3mf`
- `artifacts/hydrocyclone_lid_print.3mf`
- `artifacts/hydrocyclone_concept_preview.stl`

Validation outputs:

- `artifacts/hydrocyclone_inlet_vertical_section_debug.svg`
- `artifacts/hydrocyclone_inlet_vertical_section_debug.png`
- `artifacts/hydrocyclone_lid_section_debug.svg`
- `artifacts/hydrocyclone_lid_section_debug.png`

## Notes On Validation

Two validation cuts are kept in the repository on purpose:

- inlet section: checks whether the vortex finder extends low enough relative to the inlet opening
- lid section: checks whether the inner outlet tube is actually supported by the lid geometry

These are the two checks that are most likely to catch future geometry regressions.

## Safety

This model should be treated as a prototype for:

- fit checks
- printability checks
- assembly checks
- early hydraulic layout validation

It should not be treated as a production-ready pressurized component without:

- material verification
- wall / joint verification
- sealing design validation
- hydrostatic testing
- safety margin review
