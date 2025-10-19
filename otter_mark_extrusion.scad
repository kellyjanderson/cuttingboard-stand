module otter_mark(height=1, path="ottermaker.svg") {
    linear_extrude(height=height, center=false, convexity=10)
        import(path, center=true, convexity=10);
}

otter_mark(height=1);
