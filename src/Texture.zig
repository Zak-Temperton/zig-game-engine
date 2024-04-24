const std = @import("std");
const Allocator = std.mem.Allocator;

const gl = @import("gl");
const zstbi = @import("zstbi");

const util = @import("util.zig");

const Texture = @This();

id: gl.Texture,
width: u32,
height: u32,

pub fn init(allocator: Allocator, path: []const u8) Texture {
    zstbi.init(allocator);
    defer zstbi.deinit();

    const abs_path = util.pathToContent(allocator, path);
    var image = try zstbi.Image.init(&abs_path, 0);
    defer image.deinit();

    std.debug.print(
        "\nImage 1 info:\n\n  img width: {any}\n  img height: {any}\n  nchannels: {any}\n",
        .{ image.width, image.height, image.num_components },
    );

    const texture = Texture{
        .id = undefined,
        .width = image.width,
        .height = image.height,
    };

    gl.genTextures(1, &texture.id);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, texture.id);
    gl.textureStorage2D(texture.id, 1, gl.TextureInternalFormat.rgb8, texture.width, texture.height);

    return texture;
}
