include <BOSL2/std.scad>;

platform_width = 40;
platform_depth = 30;
platform_height = 5;

fin_start_width = 3;
fin_width_step = 1;
fin_spacing = 3;
fin_height_front = 20;
fin_height_back = 5;

can_diameter = 66;
can_height = 122;
can_clearance = 10;

// Recursively generate fin [x_pos, width] pairs that fit across the platform width.
function fin_layout(width = fin_start_width, x_pos = 0) =
    (x_pos + width <= platform_width)
        ? concat([[x_pos, width]], fin_layout(width + fin_width_step, x_pos + width + fin_spacing))
        : [];

fin_pairs = fin_layout();

module cutting_board_stand() {
    base_platform();
    fins();
}

module base_platform() {
    cuboid([platform_width, platform_depth, platform_height], anchor=BOTTOM+FRONT+LEFT);
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
            [x_pos + width, 0, platform_height + fin_height_front],
            [x_pos, 0, platform_height + fin_height_front],
            [x_pos, platform_depth, platform_height],
            [x_pos + width, platform_depth, platform_height],
            [x_pos + width, platform_depth, platform_height + fin_height_back],
            [x_pos, platform_depth, platform_height + fin_height_back]
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

cutting_board_stand();
