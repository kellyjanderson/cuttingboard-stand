include <BOSL2/std.scad>;

recess_size = 25;
recess_corner_radius = 3;

sheet_thickness = 1;
stencil_margin = 12;
slot_width = 0.8;
bridge_length = 6;
bridge_thickness = slot_width;

module cutting_pad_stencil() {
    difference() {
        base_plate();
        cutting_slot_with_bridges();
    }
}

module base_plate() {
    cuboid(
        [
            recess_size + stencil_margin * 2,
            recess_size + stencil_margin * 2,
            sheet_thickness
        ],
        anchor = CENTER
    );
}

module cutting_slot_with_bridges() {
    slot_height = sheet_thickness + 0.2;  // ensure clean subtraction
    outer_size = recess_size + slot_width;
    inner_size = recess_size - slot_width;
    outer_radius = recess_corner_radius + slot_width / 2;
    inner_radius = max(recess_corner_radius - slot_width / 2, 0);
    bridge_offset = inner_size / 2 + slot_width / 2;

    difference() {
        difference() {
            linear_extrude(height = slot_height, center = true)
                rect([outer_size, outer_size], anchor = CENTER, rounding = outer_radius);
            linear_extrude(height = slot_height + 0.2, center = true)
                rect([inner_size, inner_size], anchor = CENTER, rounding = inner_radius);
        }
        for (dir = [[1, 0], [-1, 0], [0, 1], [0, -1]])
            translate([dir[0] * bridge_offset, dir[1] * bridge_offset, 0])
                linear_extrude(height = slot_height + 0.2, center = true)
                    rect(
                        dir[0] != 0
                                ? [bridge_thickness, bridge_length]
                                : [bridge_length, bridge_thickness],
                            anchor = CENTER
                        );
    }
}

cutting_pad_stencil();
