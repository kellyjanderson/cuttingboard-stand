include <BOSL2/std.scad>;

platform_target_width = 100;
platform_depth = 200;
platform_height = 5;

recess_size = 25;
recess_depth = 1.5;
recess_corner_radius = 3;

fin_width = 3;
fin_spacing = 11.5;
fin_height_back = 150;
fin_height_front = 0;

lip_thickness = 4;
lip_drop = 5;

fin_point_front_ratio = 0.65;  // fraction from Kelly back (0) to Kelly front (1)
fin_point_height_ratio = 0.9;  // ≈ 180mm with current heights (200 → 20mm drop)

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
    difference() {
        base_platform();
        bottom_recesses();
    }
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

module bottom_recesses() {
    x_offsets = [final_platform_width / 4, final_platform_width * 3 / 4];
    y_offsets = [platform_depth / 4, platform_depth * 3 / 4];

    for (x_pos = x_offsets)
        for (y_pos = y_offsets)
            translate([x_pos, y_pos, -0.1])
                linear_extrude(height = recess_depth + 0.1, center = false)
                    rect([recess_size, recess_size], anchor = CENTER, rounding = recess_corner_radius);
}

module fin(x_pos, width) {
    os_front_top = platform_height + fin_height_back;
    os_back_top = platform_height + fin_height_front;
    point_y = platform_depth * fin_point_front_ratio;
    highest_height = max(fin_height_front, fin_height_back);
    point_top = platform_height + highest_height * fin_point_height_ratio;

    points = [
        [x_pos, 0, platform_height],                     // 0 front bottom left (OS front / Kelly back)
        [x_pos + width, 0, platform_height],             // 1 front bottom right
        [x_pos + width, 0, os_front_top],                // 2 front top right
        [x_pos, 0, os_front_top],                        // 3 front top left
        [x_pos, point_y, point_top],                     // 4 knee left
        [x_pos + width, point_y, point_top],             // 5 knee right
        [x_pos, platform_depth, os_back_top],            // 6 back top left (Kelly front)
        [x_pos + width, platform_depth, os_back_top],    // 7 back top right
        [x_pos, platform_depth, platform_height],        // 8 back bottom left
        [x_pos + width, platform_depth, platform_height] // 9 back bottom right
    ];

    faces = [
        [0, 1, 2], [0, 2, 3],
        [8, 6, 7], [8, 7, 9],
        [0, 8, 9], [0, 9, 1],
        [3, 2, 5], [3, 5, 4],
        [4, 5, 7], [4, 7, 6],
        [0, 3, 4], [0, 4, 6], [0, 6, 8],
        [1, 5, 2], [1, 7, 5], [1, 9, 7]
    ];

    polyhedron(points = points, faces = faces);
}

module front_lip() {
    translate([0, platform_depth, platform_height])
        cuboid(
            [final_platform_width, lip_thickness, platform_height + lip_drop],
            anchor=TOP+FRONT+LEFT
        );
}

cutting_board_stand();
