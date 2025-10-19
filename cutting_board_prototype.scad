include <BOSL2/std.scad>;

platform_target_width = 100;
platform_depth = 200;
platform_height = 5;

fin_width = 3;
fin_spacing = 11.5;
fin_height_back = 150;
fin_height_front = 0;

lip_thickness = 4;
lip_drop = 5;

can_diameter = 66;
can_height = 122;
can_clearance = 10;

// Recursively generate fin [x_pos, width] pairs that fit across the platform width.
function fin_layout(x_pos = 0) =
    (x_pos + fin_width <= platform_target_width)
        ? concat([[x_pos, fin_width]], fin_layout(x_pos + fin_width + fin_spacing))
        : [];

fin_pairs = fin_layout();
final_platform_width = len(fin_pairs) > 0
    ? fin_pairs[len(fin_pairs) - 1][0] + fin_pairs[len(fin_pairs) - 1][1]
    : 0;

module cutting_board_stand() {
    base_platform();
    fins();
    front_lip();
}

module base_platform() {
    cuboid([final_platform_width, platform_depth, platform_height], anchor=BOTTOM+FRONT+LEFT);
}

module fins() {
    for (fin_pair = fin_pairs)
        fin(fin_pair[0], fin_pair[1]);
}

module fin(x_pos, width) {
    polyhedron(
        points = [
            [x_pos, 0, platform_height],
            [x_pos + width, 0, platform_height],
            [x_pos + width, 0, platform_height + fin_height_back],
            [x_pos, 0, platform_height + fin_height_back],
            [x_pos, platform_depth, platform_height],
            [x_pos + width, platform_depth, platform_height],
            [x_pos + width, platform_depth, platform_height + fin_height_front],
            [x_pos, platform_depth, platform_height + fin_height_front]
        ],
        faces = [
            [0, 1, 2, 3],
            [4, 7, 6, 5],
            [0, 4, 5, 1],
            [3, 2, 6, 7],
            [1, 5, 6, 2],
            [0, 3, 7, 4]
        ]
    );
}

module front_lip() {
    translate([0, platform_depth, platform_height])
        cuboid(
            [final_platform_width, lip_thickness, platform_height + lip_drop],
            anchor=TOP+FRONT+LEFT
        );
}

cutting_board_stand();
