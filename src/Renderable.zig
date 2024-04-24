const std = @import("std");
const Renderable = @This();

pub const Sprite = struct {
    texture_id: u32,
    tex_coord: [8]f32,
};

pub const Color = union(enum) {
    rgb: [3]f32,
    rgba: [4]f32,
};

const pos_size = 3; // x y z
const col_size = 4; // r g b a
const tex_coord_size = 2; // x y;
const tex_id_size = 1;
pub const vertex_size = pos_size + col_size + tex_coord_size + tex_id_size;

const num_indices = 6;
const num_vertices = 4;

//vertices: [vertex_size * num_vertices]f32,
vertices: [4]Vertex,

const Vertex = struct {
    pos: [3]f32,
    color: [4]f32,
    tex_coord: [2]f32,
    tex_id: f32,
};

fn init(sprite: Sprite, x: f32, y: f32, z: f32, color: Color.rgba, width: f32, height: f32) Renderable {
    const tex_id: f32 = @floatFromInt(sprite.texture_id);
    return .{
        .vertices = .{
            Vertex{
                .pos = .{ x, y, z },
                .color = color,
                .tex_coord = sprite.tex_coord[0..2],
                .tex_id = tex_id,
            },
            Vertex{
                .pos = .{ x + width, y, z },
                .color = color,
                .tex_coord = sprite.tex_coord[2..4],
                .tex_id = tex_id,
            },
            Vertex{
                .pos = .{ x + width, y + height, z },
                .color = color,
                .tex_coord = sprite.tex_coord[4..6],
                .tex_id = tex_id,
            },
            Vertex{
                .pos = .{ x, y + height, z },
                .color = color,
                .tex_coord = sprite.tex_coord[6..8],
                .tex_id = tex_id,
            },
        },
    };
}

pub fn getIndices(offset: u32) [num_indices]u32 {
    return .{ offset, offset + 1, offset + 2, offset + 3, offset + 4, offset + 5 };
}

fn getVertices(self: Renderable) [vertex_size * num_vertices]f32 {
    return self.vertices;
}
