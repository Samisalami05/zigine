const std = @import("std");
const gl = @cImport(@cInclude("glad/glad.h"));

pub const BufferStorage = enum {
    Stream,  // The data store contents will be modified once and used at most a few times.
    Static,  // The data store contents will be modified once and used many times.
    Dynamic, // The data store contents will be modified repeatedly and used many times.
};


pub const BufferAccess = enum {
    Draw, // The data store contents are modified by the application, and used as the source for GL drawing and image specification commands.
    Read, // The data store contents are modified by reading data from the GL, and used to return that data when queried by the application.
    Copy, // The data store contents are modified by reading data from the GL, and used as the source for GL drawing and image specification commands.
};

fn glTypeConv(stype: BufferStorage, atype: BufferAccess) c_uint {
    return switch (stype) {
        BufferStorage.Stream => switch (atype) {
            BufferAccess.Draw => gl.GL_STREAM_DRAW,
            BufferAccess.Read => gl.GL_STREAM_READ,
            BufferAccess.Copy => gl.GL_STREAM_COPY,
        },
        BufferStorage.Static => switch (atype) {
            BufferAccess.Draw => gl.GL_STATIC_DRAW,
            BufferAccess.Read => gl.GL_STATIC_READ,
            BufferAccess.Copy => gl.GL_STATIC_COPY,
        },
        BufferStorage.Dynamic => switch (atype) {
            BufferAccess.Draw => gl.GL_DYNAMIC_DRAW,
            BufferAccess.Read => gl.GL_DYNAMIC_READ,
            BufferAccess.Copy => gl.GL_DYNAMIC_COPY,
        },
    };
}

pub const VertexBuffer = struct {

};

// TODO: generic storage type
pub const ArrayBuffer = struct {
    const Self = @This();

    handle: c_uint,
    storage: BufferStorage,
    access: BufferAccess,

    pub fn init(stype: BufferStorage, atype: BufferAccess) Self {
        var self = Self {
            .stype = stype,
            .atype = atype,
        };
        gl.glCreateBuffers(1, &self.handle);
        return self;
    }

    pub fn deinit(self: *Self) void {
        gl.glDeleteBuffers(1, self.handle);
    }

    pub fn updateData(self: *Self, data: []anyopaque) void {
        self.bind();
        gl.glBufferData(gl.GL_ARRAY_BUFFER, data.len, data.ptr, glTypeConv(self.stype, self.atype));
    }

    pub fn bind(self: *Self) void {
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.handle);
    }

    pub fn unbind(self: *Self) void {
        _ = self;
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0);
    }
};
