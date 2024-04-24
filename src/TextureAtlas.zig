const std = @import("std");
const Allocator = std.mem.Allocator;
const gl = @import("gl");
const zstbi = @import("zstbi");
const util = @import("util.zig");
const TextureAtlas = @This();

var texture_slots: [32]bool = .{false} ** 32;

id: u32,
tex: u32,
width: u32,
height: u32,

pub fn init(allocator: Allocator, path: []const u8) TextureAtlas {
    zstbi.init(allocator);
    defer zstbi.deinit();

    const abs_path = util.pathToContent(allocator, path);
    var image = try zstbi.Image.init(&abs_path, 0);
    defer image.deinit();

    std.debug.print(
        "\nImage 1 info:\n\n  img width: {any}\n  img height: {any}\n  nchannels: {any}\n",
        .{ image.width, image.height, image.num_components },
    );

    const texture = TextureAtlas{
        .id = undefined,
        .width = image.width,
        .height = image.height,
    };

    for (0..32) |tex| {
        if (!texture_slots[tex]) {
            texture.tex = tex;
            texture_slots[tex] = true;
            break;
        }
    }

    gl.genTextures(1, &texture.id);
    gl.activeTexture(gl.TEXTURE0 + texture.tex);
    gl.bindTexture(gl.TEXTURE_2D, texture.id);
    gl.textureStorage2D(texture.id, 1, gl.TextureInternalFormat.rgb8, texture.width, texture.height);

    return texture;
}

pub fn deinit(self: *TextureAtlas) void {
    texture_slots[self.tex] = false;
    gl.genTextures(1, &self.id);
}
