const std = @import("std");

const glfw = @import("glfw.zig");
const gl = @import("gl");

const panic = std.debug.panic;
const print = std.debug.print;

const Window = @This();

window: *glfw.Window,

var width: c_int = 0;
var height: c_int = 0;

pub fn getWidth(_: Window) c_int {
    return width;
}
pub fn getWidthPtr(_: *Window) *c_int {
    return &width;
}

pub fn getHeight(_: Window) c_int {
    return height;
}
pub fn getHeightPtr(_: *Window) *c_int {
    return &height;
}

fn glGetProcAddress(_: glfw.GLproc, proc: [:0]const u8) ?gl.FunctionPointer {
    return glfw.getProcAddress(proc);
}

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    panic("Error: {d} {s}\n", .{ err, description });
}

pub fn init(w: c_int, h: c_int) !Window {
    var my_window = Window{
        .window = undefined,
    };

    _ = glfw.setErrorCallback(errorCallback);
    {
        var major: c_int = undefined;
        var minor: c_int = undefined;
        var rev: c_int = undefined;
        glfw.getVersion(&major, &minor, &rev);
        print("GLFW {d}.{d}.{d}", .{ major, minor, rev });
    }

    glfw.init() catch panic("Failed to init GLFW", .{});

    my_window.window = glfw.createWindow(w, h, "Game Engine", null, null) catch panic("failed to create GLFW window: ", .{});

    glfw.makeContextCurrent(my_window.window);
    _ = glfw.setFramebufferSizeCallback(my_window.window, framebufferSizeCallback);
    glfw.getWindowSize(my_window.window, &width, &height);

    const proc: glfw.GLproc = undefined;
    try gl.load(proc, glGetProcAddress);

    return my_window;
}

pub fn deinit(self: *Window) void {
    glfw.destroyWindow(self.window);
    glfw.terminate();
}

pub fn shouldClose(self: Window) bool {
    return glfw.windowShouldClose(self.window);
}

pub fn pollEvents(_: Window) void {
    glfw.pollEvents();
}

fn framebufferSizeCallback(window: *glfw.Window, w: c_int, h: c_int) callconv(.C) void {
    _ = window;
    width = w;
    height = h;
    gl.viewport(0, 0, width, height);
}
