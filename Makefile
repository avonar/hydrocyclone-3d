OPENSCAD ?= openscad
MAGICK ?= magick
ARTIFACTS_DIR := artifacts

CONCEPT_SCAD := hydrocyclone_concept.scad
VALIDATION_SCADS := \
	hydrocyclone_inlet_vertical_section_debug.scad \
	hydrocyclone_lid_section_debug.scad

PRINT_STLS := \
	$(ARTIFACTS_DIR)/hydrocyclone_body_print.stl \
	$(ARTIFACTS_DIR)/hydrocyclone_lid_print.stl \
	$(ARTIFACTS_DIR)/hydrocyclone_concept_preview.stl

PRINT_3MFS := \
	$(ARTIFACTS_DIR)/hydrocyclone_body_print.3mf \
	$(ARTIFACTS_DIR)/hydrocyclone_lid_print.3mf

DEBUG_SVGS := \
	$(ARTIFACTS_DIR)/hydrocyclone_inlet_vertical_section_debug.svg \
	$(ARTIFACTS_DIR)/hydrocyclone_lid_section_debug.svg

DEBUG_PNGS := $(DEBUG_SVGS:.svg=.png)

.PHONY: all prints debug validate sections preview print3mf clean dirs

# LLM note:
# These targets are intentionally independent. Prefer `make -j all`
# or `make -j prints debug` so OpenSCAD renders run in parallel.

all: prints debug

prints: $(PRINT_STLS) $(PRINT_3MFS)

debug: $(DEBUG_SVGS) $(DEBUG_PNGS)

validate: debug

sections: $(DEBUG_SVGS)

preview: $(ARTIFACTS_DIR)/hydrocyclone_concept_preview.stl

print3mf: $(PRINT_3MFS)

dirs:
	mkdir -p $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/hydrocyclone_body_print.stl: $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -D 'render_mode="body"' -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_lid_print.stl: $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -D 'render_mode="lid"' -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_concept_preview.stl: $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_body_print.3mf: $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -D 'render_mode="body"' -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_lid_print.3mf: $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -D 'render_mode="lid"' -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_inlet_vertical_section_debug.svg: hydrocyclone_inlet_vertical_section_debug.scad $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -o $@ $<

$(ARTIFACTS_DIR)/hydrocyclone_lid_section_debug.svg: hydrocyclone_lid_section_debug.scad $(CONCEPT_SCAD) | dirs
	$(OPENSCAD) -o $@ hydrocyclone_lid_section_debug.scad

$(ARTIFACTS_DIR)/%.png: $(ARTIFACTS_DIR)/%.svg | dirs
	$(MAGICK) $< $@

clean:
	rm -rf $(ARTIFACTS_DIR)
