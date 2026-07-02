const std = @import("std");

pub const g = @import("graphics.zig");
pub const fm = @import("filemanager.zig");
pub const lm = @import("linearmath.zig");
pub const inputman = @import("inputman.zig");
pub const events = @import("events.zig");
pub const input = @import("input.zig");

const glfw = @import("c.zig").glfw;
const gl = @import("c.zig").gl;

fn keyCallback(context: *anyopaque, event: events.Event) void {
    _ = context;

    switch (event) {
        .key => |e| {
            if (e.action == .repeat) return;
            switch (e.keyCode) {
                input.Key.w => w = e.action == input.InputAction.down,
                input.Key.a => a = e.action == input.InputAction.down,
                input.Key.s => s = e.action == input.InputAction.down,
                input.Key.d => d = e.action == input.InputAction.down,
                else => {},
            }
        },
        else => return,
    }
}

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

    eventman: events.EventManager,
    inputman: inputman.InputManager,
};

var engine: ?Engine = null;

pub fn init(args: std.process.Init) !void {
    std.debug.assert(engine == null);

    engine = Engine {
        .io = args.io,
        .alloc = args.gpa,

        .eventman = .init(),
        .inputman = .init(),
    };

    try engine.?.eventman.addListener(.{ .callback = keyCallback, .context = undefined });
}

fn deinit() void {
    engine.?.eventman.deinit();
}

fn beginFrame() !void {
    std.debug.assert(engine != null);
    
}

fn endFrame() !void {
    std.debug.assert(engine != null);

    try engine.?.eventman.poll();
}

pub fn get() *Engine {
    std.debug.assert(engine != null);
    return &engine.?;
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
    uv: [2]f32,
};

var w: bool = false;
var a: bool = false;
var s: bool = false;
var d: bool = false;

pub fn messageCallback(source: gl.GLenum, @"type": gl.GLenum, id: gl.GLuint, severity: gl.GLenum, length: gl.GLsizei, message: [*c]const gl.GLchar, userParam: ?*const anyopaque) callconv(.c) void
{
    _ = source;
    _ = id;
    _ = length;
    _ = userParam;
    if (@"type" != gl.GL_DEBUG_TYPE_ERROR) return;
    const typeStr = if ( @"type" == gl.GL_DEBUG_TYPE_ERROR ) "GL ERROR" else "GL MESSAGE";
    std.debug.print("[{s}] {s}\n[TYPE]: 0x{x}, [SEVERITY]: 0x{x}\n\n", 
      .{ typeStr, message, @"type", severity });
}

pub fn run() !void {
    if (glfw.glfwInit() == 0) return error.FailedToInitializeGLFW;
    defer glfw.glfwTerminate();

    const window = glfw.glfwCreateWindow(1280, 720, "zig engine", null, null);
    if (window == null) return error.FailedToCreateWindow;
    defer glfw.glfwDestroyWindow(window);

    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Enable vsync
    _ = glfw.glfwSetKeyCallback(window, inputman.InputManager.keyCallback);
    _ = glfw.glfwSetMouseButtonCallback(window, inputman.InputManager.mouseButtonCallback);

    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) return error.FailedToInitializeGLAD;

    gl.glEnable(gl.GL_DEBUG_OUTPUT);
    gl.glDebugMessageCallback(messageCallback, null);

    // SHADER
    const vert: g.ShaderModule = try .init("assets/shaders/basic.vert", g.ShaderType.Vertex);
    const frag: g.ShaderModule = try .init("assets/shaders/basic.frag", g.ShaderType.Fragment);

    var shader: g.Shader = .init();
    defer shader.deinit();

    try shader.addModule(vert);
    try shader.addModule(frag);
    try shader.assemble();

    const vertices = [_]f32 {
         0.5,  0.5, 0.0, 1.0, 1.0,
         0.5, -0.5, 0.0, 1.0, 0.0,
        -0.5, -0.5, 0.0, 0.0, 0.0,
        -0.5,  0.5, 0.0, 0.0, 1.0
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
    vao.bind();

    vbo.upload(&vertices);
    ebo.upload(&indices);

    vao.addAttribute(3, f32, false, @offsetOf(Vertex, "pos"));
    vao.addAttribute(2, f32, false, @offsetOf(Vertex, "uv"));

    var lastWidth: c_int = 0;
    var lastHeight: c_int = 0;
    glfw.glfwGetFramebufferSize(window, &lastWidth, &lastHeight);
    gl.glViewport(0, 0, lastWidth, lastHeight);

    var last: f64 = 0.0;

    const model: lm.Mat4 = .init();
    var cam: g.Camera = .init(1280, 720);

    var godot = try g.Texture2D.init("assets/images/godot.png");
    defer godot.deinit();
    var bricks = try g.Texture2D.init("assets/images/brick.png");
    defer bricks.deinit();
    bricks.options.filterMin = .nearest;
    bricks.options.filterMag = .nearest;
    bricks.updateOptions();

    while (glfw.glfwWindowShouldClose(window) == 0) {
        try beginFrame();
        var width: c_int = 0;
        var height: c_int = 0;
        glfw.glfwGetFramebufferSize(window, &width, &height);
        if (width != lastWidth or height != lastHeight) {
            gl.glViewport(0, 0, width, height);
            cam.width = @intCast(width);
            cam.height = @intCast(height);
            lastWidth = width;
            lastHeight = height;
            std.debug.print("resized: {} {}\n", .{width, height});
        }

        const time = glfw.glfwGetTime();
        const deltaTime = time - last;
        last = time;
        //std.debug.print("fps: {}                   \r", .{1 / deltaTime});

        if (w) cam.pos.addAssign(cam.forward().mul(@as(f32, @floatCast(deltaTime))));
        if (a) cam.pos.addAssign(cam.right().inversed().mul(@as(f32, @floatCast(deltaTime))));
        if (s) cam.pos.addAssign(cam.forward().inversed().mul(@as(f32, @floatCast(deltaTime))));
        if (d) cam.pos.addAssign(cam.right().mul(@as(f32, @floatCast(deltaTime))));

        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
        gl.glClearColor(0, 0, 0, 1);

        shader.bind();
        shader.setMat4("model", model);
        shader.setMat4("view", cam.view());
        shader.setMat4("proj", cam.proj());

        godot.bind(0);
        shader.setI32("tex", 0);

        vao.bind();
        gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, null);

        var model2 = model;
        model2.translate(.right);
        shader.setMat4("model", model2);
        bricks.bind(0);
        shader.setI32("tex", 0);
        gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, null);


        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();

        try endFrame();
    }

    deinit();
}
