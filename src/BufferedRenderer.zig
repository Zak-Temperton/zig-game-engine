const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const Allocator = std.mem.Allocator;

const gl = @import("gl");
const zm = @import("zmath");
const Camera = @import("Camera.zig");
const Program = @import("Shader.zig");
const Renderable = @import("Renderable.zig");

const BufferedRenderer = @This();

allocator: Allocator,
shader_program: Program,
vertices: ArrayList(f32),
indices: ArrayList(u32),
vao: u32,
vbo: u32,
ebo: u32,
index_offset: u32 = 0,
count: u32 = 0,

pub fn init(allocator: Allocator, shader_program: Program) BufferedRenderer {
    var vao: u32 = 0;
    var vbo: u32 = 0;
    var ebo: u32 = 0;
    gl.genVertexArrays(1, &vao);
    gl.genBuffers(1, &vbo);
    gl.genBuffers(1, &ebo);

    return .{
        .allocator = allocator,
        .shader_program = shader_program,
        .vertices = ArrayList(f32){},
        .indices = ArrayList(u32){},
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
    };
}

pub fn deinit(self: *BufferedRenderer) void {
    self.vertices.deinit(self.allocator);
    self.indices.deinit(self.allocator);
    defer gl.deleteVertexArrays(1, &self.vao);
    defer gl.deleteBuffers(1, &self.vbo);
    defer gl.deleteBuffers(1, &self.ebo);
}

pub fn append(self: *BufferedRenderer, renderable: Renderable) !void {
    self.vertices.appendSlice(self.allocator, renderable.getVertices());
    try self.indices.append(self.allocator, Renderable.getIndices(self.index_offset));
    self.index_offset += Renderable.num_indices;
    self.count += Renderable.num_vertices;
}

pub fn bind(self: BufferedRenderer) void {
    gl.bindVertexArray(self.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
    gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * self.vertices.items.len), &self.vertices.items[0], gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * self.indices.items.len), &self.indices.items[0], gl.STATIC_DRAW);

    const pos_offset = null;
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, @intCast(Renderable.vertex_size * @sizeOf(f32)), pos_offset);
    gl.enableVertexAttribArray(0);

    const color_offset: [*c]c_uint = (3 * @sizeOf(f32));
    gl.vertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, @intCast(Renderable.vertex_size * @sizeOf(f32)), color_offset);
    gl.enableVertexAttribArray(2);

    const tex_coord_offset: [*c]c_uint = (7 * @sizeOf(f32));
    gl.vertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, @intCast(Renderable.vertex_size * @sizeOf(f32)), tex_coord_offset);
    gl.enableVertexAttribArray(2);

    const tex_id_offset: [*c]c_uint = (9 * @sizeOf(f32));
    gl.vertexAttribPointer(3, 1, gl.FLOAT, gl.FALSE, @intCast(Renderable.vertex_size * @sizeOf(f32)), tex_id_offset);
    gl.enableVertexAttribArray(1);
}

pub fn render(self: BufferedRenderer, camera: Camera, width: u32, height: u32) void {
    var projection: [16]f32 = undefined;
    zm.storeMat(&projection, camera.getProjectionMatrix(width, height));
    self.shader_program.use();
    self.shader_program.setMat4f("proj", projection);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
    gl.bindVertexArray(self.vao);
    gl.drawElements(gl.TRIANGLES, @intCast(self.indices.items.len), gl.UNSIGNED_INT, null);
    gl.bindVertexArray(0);
}

pub fn clear(self: *BufferedRenderer) void {
    self.vertices.clearAndFree(self.allocator);
    self.indices.clearAndFree(self.allocator);
    self.count = 0;
    self.index_offset = 0;
}
