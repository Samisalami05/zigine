const std = @import("std");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const gl = @cImport(@cInclude("glad/glad.h"));

pub const core = @import("shader.zig");
pub const fm = @import("filemanager.zig");

pub const EngineError = error{
    FailedToInitializeGLFW, 
    FailedToInitializeGLAD,
    FailedToCreateWindow,
    FailedToCompileShader,
    FailedToLinkProgram,
    EngineNotInitialized,
};

const vert_src =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main() {
    \\    gl_Position = vec4(aPos, 1.0);
    \\}
;
const frag_src = 
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main() {
    \\    FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);
    \\}
;

pub const Engine = struct {
    io: std.Io,
    alloc: std.mem.Allocator,
};

var engine: ?Engine = null;

pub fn init(args: std.process.Init) void {
    engine = Engine {
        .io = args.io,
        .alloc = args.gpa,
    };
}

pub fn io() EngineError!std.Io {
    if (engine == null) return error.EngineNotInitialized;
    return engine.?.io;
}

pub fn allocator() EngineError!std.mem.Allocator {
    if (engine == null) return error.EngineNotInitialized;
    return engine.?.alloc;
}

fn linkProgram(program: c_uint) EngineError!void {
    gl.glLinkProgram(program);
    var success: c_int = undefined;
    gl.glGetProgramiv(program, gl.GL_LINK_STATUS, &success);

    if (success == 0) {
        var msg: [512]u8 = undefined;
        var len: c_int = undefined;
        gl.glGetProgramInfoLog(program, 512, &len, &msg);
        std.debug.print("Failed to link program {}\n{s}\n", .{program, msg[0..@intCast(len)]});
        return error.FailedToLinkProgram;
    }
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

    const vert: core.ShaderModule = try .initRaw(vert_src, core.ShaderType.Vertex);
    const frag: core.ShaderModule = try .initRaw(frag_src, core.ShaderType.Fragment);

    var shader: core.Shader = .init();
    try shader.addModule(vert);
    try shader.addModule(frag);
    try shader.assemble();

    //const vert = gl.glCreateShader(gl.GL_VERTEX_SHADER);
    //gl.glShaderSource(vert, 1, &vert_src.ptr, null);
    //try compileShader(vert);

    //const frag = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
    //gl.glShaderSource(frag, 1, &frag_src.ptr, null);
    //try compileShader(frag);

    //const shader: c_uint = gl.glCreateProgram();
    //gl.glAttachShader(shader, vert);
    //gl.glAttachShader(shader, frag);
    //try linkProgram(shader);
    //defer gl.glDeleteProgram(shader);

    //gl.glDeleteShader(vert);
    //gl.glDeleteShader(frag);

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
    std.debug.print("size: {}\n", .{@sizeOf(@TypeOf(verts))});
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)), &verts, gl.GL_STATIC_DRAW);

    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0); 

    shader.bind();

    var width: c_int = undefined;
    var height: c_int = undefined;
    glfw.glfwGetWindowSize(window, &width, &height);
    gl.glViewport(0, 0, width, height);

    while (glfw.glfwWindowShouldClose(window) == 0) {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
        gl.glClearColor(0.4, 0.5, 0, 1);

        //gl.glUseProgram(shader);
        shader.bind();
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);

        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}
