const std = @import("std");

pub const g = @import("graphics.zig");
pub const fm = @import("filemanager.zig");
pub const lm = @import("linearmath.zig");
pub const input_man = @import("inputman.zig");
pub const events = @import("events.zig");
pub const input = @import("input.zig");
pub const Window = @import("window.zig").Window;
pub const time = @import("time.zig");

const glfw = @import("c.zig").glfw;
const gl = @import("c.zig").gl;

pub const EngineError = error{
    FailedToInitializeGLFW, 
    FailedToInitializeGLAD,
    FailedToCreateWindow,
    FailedToCompileShader,
    FailedToLinkProgram,
};

pub const Engine = struct {
    const Self = @This();

    io: std.Io,
    alloc: std.mem.Allocator,

    window: Window,
    renderer: g.Renderer,

    eventman: events.EventManager,
    inputman: input_man.InputManager,
    timeman: time.TimeManager,

    pub fn init(args: std.process.Init) !Self {
        try initGLFW();

        const win: Window = try .init(1280, 720);
        const ren: g.Renderer = .init(win);

        const self: Self = .{
            .io = args.io,
            .alloc = args.gpa,

            .window = win,
            .renderer = ren,

            .eventman = .init(),
            .inputman = try .init(),
            .timeman = .init(),
        };

        try initGL();

        return self;
    }

    pub fn start(self: *Self) !void {
        try self.inputman.attach(&self.eventman);
        try self.renderer.attach(&self.eventman);
    }

    pub fn deinit(self: *Self) void {
        self.eventman.deinit();

        self.window.deinit();
        deinitGLFW();
    }

    fn initGLFW() !void { if (glfw.glfwInit() == 0) return error.FailedToInitializeGLFW; }
    fn deinitGLFW() void { glfw.glfwTerminate(); }

    fn initGL() !void {
        const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
        if (gl.gladLoadGLLoader(loader) == 0) return error.FailedToInitializeGLAD;

        gl.glEnable(gl.GL_DEBUG_OUTPUT);
        gl.glDebugMessageCallback(messageCallback, null);
    }
};

var engine: ?Engine = null;

pub fn init(args: std.process.Init) !void {
    std.debug.assert(engine == null);

    engine = try Engine.init(args);
    try engine.?.start();
}

fn beginFrame() !void {
    std.debug.assert(engine != null);
    engine.?.timeman.update();
}

fn endFrame() !void {
    std.debug.assert(engine != null);

    engine.?.inputman.update();
    try engine.?.eventman.poll();
}

// TODO: is probably bad
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

pub fn inputman() *input_man.InputManager {
    std.debug.assert(engine != null);
    return &engine.?.inputman;
}

pub fn timeman() *time.TimeManager {
    return &engine.?.timeman;
}

pub fn window() *Window {
    std.debug.assert(engine != null);
    return &engine.?.window;
}

pub fn renderer() *g.Renderer {
    std.debug.assert(engine != null);
    return &engine.?.renderer;
}

const Vertex = struct {
    pos: [3]f32,
    uv: [2]f32,
};

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
    // SHADER
    const vert: g.ShaderModule = try .init("assets/shaders/basic.vert", g.ShaderType.Vertex);
    const frag: g.ShaderModule = try .init("assets/shaders/basic.frag", g.ShaderType.Fragment);

    var shader: g.Shader = .init();
    defer shader.deinit();

    try shader.addModule(vert);
    try shader.addModule(frag);
    try shader.assemble();

    // GEOMETRY
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
    glfw.glfwGetFramebufferSize(engine.?.window.handle, &lastWidth, &lastHeight);
    gl.glViewport(0, 0, lastWidth, lastHeight);


    const model: lm.Mat4 = .init();

    var godot = try g.Texture2D.init("assets/images/godot.png");
    defer godot.deinit();
    var bricks = try g.Texture2D.init("assets/images/brick.png");
    defer bricks.deinit();
    bricks.options.filterMin = .nearest;
    bricks.options.filterMag = .nearest;
    bricks.updateOptions();

    const cam: *g.Camera = &engine.?.renderer.camera;


    while (!window().shouldClose()) {
        try beginFrame();

        std.debug.print("fps: {}     \r", .{1 / time.deltaTime()});

        if (input.isKeyDown(.w)) cam.pos.addAssign(cam.forward().mul(time.deltaTime()));
        if (input.isKeyDown(.a)) cam.pos.addAssign(cam.right().inversed().mul(time.deltaTime()));
        if (input.isKeyDown(.s)) cam.pos.addAssign(cam.forward().inversed().mul(time.deltaTime()));
        if (input.isKeyDown(.d)) cam.pos.addAssign(cam.right().mul(time.deltaTime()));

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


        engine.?.window.swapBuffers();
        engine.?.window.pollEvents();
        try endFrame();
    }
}
