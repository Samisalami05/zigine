const std = @import("std");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const gl = @cImport(@cInclude("glad/glad.h"));

pub const g = @import("graphics.zig");
pub const fm = @import("filemanager.zig");
pub const lm = @import("linearmath.zig");

const Image = @import("image.zig").Image;

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

const Vertex = struct {
    pos: [3]f32,
};

fn keyCallback(win: ?*glfw.struct_GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
    if (action != glfw.GLFW_PRESS) return;
    _ = win;
    _ = scancode;
    _ = mods;
    switch (key) {
        glfw.GLFW_KEY_W => std.debug.print("W pressed\n", .{}),
        else => {},
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
    _ = glfw.glfwSetKeyCallback(window, keyCallback);
    
    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) return error.FailedToInitializeGLAD;

    // SHADER
    const vert: g.ShaderModule = try .init("assets/shaders/basic.vert", g.ShaderType.Vertex);
    const frag: g.ShaderModule = try .init("assets/shaders/basic.frag", g.ShaderType.Fragment);

    var shader: g.Shader = .init();
    defer shader.deinit();

    try shader.addModule(vert);
    try shader.addModule(frag);
    try shader.assemble();

    const vertices = [_]f32 {
         0.5,  0.5, 0.0,
         0.5, -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5,  0.5, 0.0
    };
    const indices = [_]u32 {
        0, 1, 3,
        1, 2, 3
    };

    var vbo: g.Buffer(f32) = .init(.arrayBuffer, .staticDraw);
    defer vbo.deinit();

    var ebo: g.Buffer(u32) = .init(.elementArrayBuffer, .staticDraw);
    defer ebo.deinit();

    var vao: g.VertexArray(Vertex) = .init();
    defer vao.deinit();

    //var vao: c_uint = undefined;
    //gl.glGenVertexArrays(1, &vao);
    //defer gl.glDeleteVertexArrays(1, &vao);

    //gl.glBindVertexArray(vao);
    vao.bind();

    vbo.upload(&vertices);
    ebo.upload(&indices);

    vao.addAttribute(3, f32, false, @offsetOf(Vertex, "pos"));

    //gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3 * @sizeOf(f32), null);
    //gl.glEnableVertexAttribArray(0);
    
    // VIEWPORT
    var width: c_int = undefined;
    var height: c_int = undefined;
    glfw.glfwGetWindowSize(window, &width, &height);
    gl.glViewport(0, 0, width, height);

    var last: f64 = 0.0;

    const model: lm.Mat4 = .init();
    const view: lm.Mat4 = .lookat(lm.Vec3.one, .init(1.0, 1.0, 0.0));
    const proj: lm.Mat4 = .projection(90.0, 16.0 / 9.0, 1, 1000);

    const img = try Image.init("assets/images/brick.png");
    defer img.deinit();

    while (glfw.glfwWindowShouldClose(window) == 0) {
        const time = glfw.glfwGetTime();
        const deltaTime = time - last;
        last = time;

        _ = deltaTime;
        //std.debug.print("fps: {}                   \r", .{1 / deltaTime});

        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
        gl.glClearColor(0, 0, 0, 1);

        shader.bind();
        shader.setMat4("model", model);
        shader.setMat4("view", view);
        shader.setMat4("proj", proj);

        vao.bind();
        gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, null);

        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }
}
