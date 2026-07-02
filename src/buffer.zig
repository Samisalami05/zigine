const std = @import("std");
const gl = @import("c.zig").gl;

pub const BufferType = enum {
    const Self = @This();

    arrayBuffer,
    atomicCounterBuffer,
    copyReadBuffer,
    copyWriteBuffer,
    drawIndirectBuffer,
    dispatchIndirectBuffer,
    elementArrayBuffer,
    pixelPackBuffer,
    pixelUnpackBuffer,
    queryBuffer,
    shaderStorageBuffer,
    textureBuffer,
    transformFeedbackBuffer,
    uniformBuffer,

    pub fn toGL(self: Self) c_uint {
        return switch (self) {
            BufferType.arrayBuffer => gl.GL_ARRAY_BUFFER,
            BufferType.atomicCounterBuffer => gl.GL_ATOMIC_COUNTER_BUFFER,
            BufferType.copyReadBuffer => gl.GL_COPY_READ_BUFFER,
            BufferType.copyWriteBuffer => gl.GL_COPY_WRITE_BUFFER,
            BufferType.drawIndirectBuffer => gl.GL_DRAW_INDIRECT_BUFFER,
            BufferType.dispatchIndirectBuffer => gl.GL_DISPATCH_INDIRECT_BUFFER,
            BufferType.elementArrayBuffer => gl.GL_ELEMENT_ARRAY_BUFFER,
            BufferType.pixelPackBuffer => gl.GL_PIXEL_PACK_BUFFER,
            BufferType.pixelUnpackBuffer => gl.GL_PIXEL_UNPACK_BUFFER,
            BufferType.queryBuffer => gl.GL_QUERY_BUFFER,
            BufferType.shaderStorageBuffer => gl.GL_SHADER_STORAGE_BUFFER,
            BufferType.textureBuffer => gl.GL_TEXTURE_BUFFER,
            BufferType.transformFeedbackBuffer => gl.GL_TRANSFORM_FEEDBACK_BUFFER,
            BufferType.uniformBuffer => gl.GL_UNIFORM_BUFFER,
        };
    }
};

pub const BufferUsage = enum {
    const Self = @This();

    streamDraw,
    streamRead,
    streamCopy,
    staticDraw,
    staticRead,
    staticCopy,
    dynamicDraw,
    dynamicRead,
    dynamicCopy,

    pub fn toGL(self: Self) c_uint {
        return switch (self) {
            Self.streamDraw => gl.GL_STREAM_DRAW,
            Self.streamRead => gl.GL_STREAM_READ,
            Self.streamCopy => gl.GL_STREAM_COPY,
            Self.staticDraw => gl.GL_STATIC_DRAW,
            Self.staticRead => gl.GL_STATIC_READ,
            Self.staticCopy => gl.GL_STATIC_COPY,
            Self.dynamicDraw => gl.GL_DYNAMIC_DRAW,
            Self.dynamicRead => gl.GL_DYNAMIC_READ,
            Self.dynamicCopy => gl.GL_DYNAMIC_COPY,
        };
    }
};

pub const Error = error {
    outOfBounds,
};

// TODO: make immutable and mutable versions
// TODO: implement clear 

pub fn Buffer(comptime T: type) type {
    return struct {
        const Self = @This();

        handle: c_uint,
        type_: BufferType, // Buffer type
        usage: BufferUsage,
        size_: usize,

        pub fn init(type_: BufferType, usage: BufferUsage) Self {
            var self: Self = .{
                .handle = 0,
                .type_ = type_,
                .usage = usage,
                .size_ = 0,
            };
            gl.glGenBuffers(1, &self.handle);
            return self;
        }

        pub fn deinit(self: *Self) void {
            gl.glDeleteBuffers(1, &self.handle);
        }

        pub fn bind(self: *const Self) void {
            gl.glBindBuffer(self.type_.toGL(), self.handle);
        }

        // Reallocates the buffer if size changed
        pub fn upload(self: *Self, data: [] const T) void {
            const dataSize = data.len * @sizeOf(T);
            self.bind();
            if (dataSize != self.size_) {
                gl.glBufferData(self.type_.toGL(), @intCast(dataSize), data.ptr, self.usage.toGL());
                self.size_ = dataSize;
                return;
            }
            gl.glBufferSubData(self.type_.toGL(), 0, @intCast(dataSize), data.ptr);
        }

        pub fn resize(self: *Self, newSize: usize) void {
            if (self.size_ == newSize) return;
            self.bind();
            gl.glBufferData(self.type_.toGL(), @intCast(newSize), null, self.usage.toGL());
            self.size_ = newSize;
        }

        // Does not reallocate the buffer
        pub fn update(self: *Self, data: []const T) void {
            self.updateSection(0, data);
        }

        // Does not reallocate the buffer
        pub fn updateSection(self: *Self, off: usize, data: []const T) Error!void {
            const dataSize = data.len * @sizeOf(T);
            if (off * @sizeOf(T) + dataSize > self.size_) {
                return error.outOfBounds;
            }
            self.bind();
            gl.glBufferSubData(self.type_.toGL(), @intCast(off), @intCast(dataSize), data.ptr);
        }

        pub fn invalidate(self: *Self) void {
            gl.glInvalidateBufferData(self.handle);
        }

        pub fn invalidateSection(self: *Self, off: usize, len: usize) void {
            gl.glInvalidateBufferSubData(self.handle, off, len);
        }

        pub fn size(self: *const Self) usize {
            return self.size_;
        }
    };
}
