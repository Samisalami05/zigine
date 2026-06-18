const std = @import("std");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const gl = @cImport(@cInclude("glad/glad.h"));

pub const core = @import("core.zig");
pub const fm = @import("filemanager.zig");

pub const EngineError = error{
    FailedToInitializeGLFW, 
    FailedToInitializeGLAD,
    FailedToCreateWindow,
    FailedToCompileShader,
    FailedToLinkProgram,
};

pub const Engine = struct {
    io: std.Io,
    alloc: std.mem.Allocator,
};

var engine: ?Engine = null;

pub fn init(args: std.process.Init) void {
    std.debug.assert(engine == null);

    engine = Engine {
        .io = args.io,
        .alloc = args.gpa,
    };
}

pub fn io() std.Io {
    std.debug.assert(engine != null);
    return engine.?.io;
}

pub fn allocator() std.mem.Allocator {
    std.debug.assert(engine != null);
    return engine.?.alloc;
}

pub fn run() !void {
    if (glfw.glfwInit() == 0) return error.FailedToInitializeGLFW;
    defer glfw.glfwTerminate();

    const window = glfw.glfwCreateWindow(1280, 720, "zig engine", null, null);
    if (window == null) return error.FailedToCreateWindow;
    defer glfw.glfwDestroyWindow(window);

    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Enable vsync
    
    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) return error.FailedToInitializeGLAD;

    // SHADER
    const vert: core.ShaderModule = try .init("assets/shaders/basic.vert", core.ShaderType.Vertex);
    const frag: core.ShaderModule = try .init("assets/shaders/basic.frag", core.ShaderType.Fragment);

    var shader: core.Shader = .init();
    defer shader.deinit();

    try shader.addModule(vert);
    try shader.addModule(frag);
    try shader.assemble();

    // VERTICES
    const verts = [_]f32{
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0,  0.5, 0.0
    };

    var vbo: c_uint = undefined;
    gl.glGenBuffers(1, &vbo);
    defer gl.glDeleteBuffers(1, &vbo);

    var vao: c_uint = undefined;
    gl.glGenVertexArrays(1, &vao);
    defer gl.glDeleteVertexArrays(1, &vao);

    gl.glBindVertexArray(vao);

    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)), &verts, gl.GL_DYNAMIC_READ);

    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0); 

    // VIEWPORT
    var width: c_int = undefined;
    var height: c_int = undefined;
    glfw.glfwGetWindowSize(window, &width, &height);
    gl.glViewport(0, 0, width, height);

    while (glfw.glfwWindowShouldClose(window) == 0) {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
        gl.glClearColor(0, 0, 0, 1);

        shader.bind();
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);

        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}
