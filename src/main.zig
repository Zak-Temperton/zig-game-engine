const std = @import("std");

const gl = @import("gl");
const glfw = @import("glfw.zig");

const game_engine = @import("game-engine");

const Shader = @import("Shader.zig");
pub const Camera = @import("Camera.zig");
pub const BufferedRenderer = @import("BufferedRenderer.zig");
const Window = @import("Window.zig");

const print = std.debug.print;
const warn = std.debug.warn;
const panic = std.debug.panic;

var width: c_int = 1800;
var height: c_int = 900;

pub fn main() !void {
    var window = try Window.init(1800, 900);
    defer window.deinit();

    var shader = Shader.init(vertex_shader_t, fragment_shader_t);
    defer shader.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const buf_render = BufferedRenderer.init(allocator, shader);
    const cam = Camera.init(.{ 0, 0 }, 1);

    while (!window.shouldClose()) {
        buf_render.bind();
        buf_render.render(cam, @intCast(window.getWidth()), @intCast(window.getHeight()));
        window.pollEvents();
    }
}

const vertex_shader_t =
    \\#version 410 core
    \\layout (location = 0) in vec3 aPos;
    \\layout (location = 1) in vec4 aColor;
    \\layout (location = 2) in vec2 aTexCoord;
    \\layout (location = 3) in float aTexId;
    \\uniform mat4 proj;
    \\out vec4 ourColor;
    \\out vec2 ourTexCoord;
    \\out float ourTexId;
    \\void main()
    \\{
    \\  gl_Position = proj * vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\  ourColor = aColor;
    \\  ourTexCoord = aTexCoord;
    \\  ourTexId = aTexId;
    \\}
;

const fragment_shader_t =
    \\#version 410 core
    \\in vec4 ourColor;
    \\in vec2 ourTexCoord;
    \\in float ourTexId;
    \\out vec4 FragColor;
    \\uniform sampler2D texture1;
    \\uniform sampler2D texture2;
    \\void main() {
    \\  switch (int(ourTexId)) {
    \\      case 0:
    \\          FragColor = ourColor + texture(texture1, ourTexCoord);
    \\          break;
    \\      case 1:
    \\          FragColor = ourColor + texture(texture2, ourTexCoord);
    \\          break;
    \\  }
    \\}
;
