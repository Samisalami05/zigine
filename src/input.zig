const std = @import("std");
const glfw = @import("c.zig").glfw;
const engine = @import("root.zig");

// Returns whether key is held down
pub fn isKeyDown(key: Key) bool {
    const input = engine.inputman();
    return input.isKeyDown(key);
}

// Returns whether key is pressed this frame
pub fn isKeyPressed(key: Key) bool {
    const input = engine.inputman();
    return input.isKeyPressed(key);
}

// Returns whether key is released this frame
pub fn isKeyReleased(key: Key) bool {
    const input = engine.inputman();
    return input.isKeyReleased(key);
}

pub const InputAction = enum(u8) {
    const Self = @This();

    down,
    up,
    repeat, // Used for text input

    pub fn fromGLFW(action: c_int) Self {
        return switch (action) {
            glfw.GLFW_PRESS => .down,
            glfw.GLFW_RELEASE => .up,
            glfw.GLFW_REPEAT => .repeat,
            else => .up,
        };
    }
};

pub const Key = enum(u8) {
    const Self = @This();

    space,
    apostrophe,
    comma,
    minus,
    period,
    slash,
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    semicolon,
    equal,
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,
    leftBracket,
    backslash,
    rightBracket,
    graveAccent,
    world1,
    world2,

    // function keys
    escape,
    enter,
    tab,
    backspace,
    insert,
    delete,
    right,
    left,
    down,
    up,
    pageUp,
    pageDown,
    home,
    end,
    capsLock,
    scrollLock,
    numLock,
    printScreen,
    pause,
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    f13,
    f14,
    f15,
    f16,
    f17,
    f18,
    f19,
    f20,
    f21,
    f22,
    f23,
    f24,
    f25,
    kp0,
    kp1,
    kp2,
    kp3,
    kp4,
    kp5,
    kp6,
    kp7,
    kp8,
    kp9,
    kpDecimal,
    kpDivide,
    kpMultiply,
    kpSubtract,
    kpAdd,
    kpEnter,
    kpEqual,
    leftShift,
    leftControl,
    leftAlt,
    leftSuper,
    rightShift,
    rightControl,
    rightAlt,
    rightSuper,
    menu,

    pub fn count() u32 {
        return @intFromEnum(Key.menu) + 1;
    }

    pub fn fromGLFW(key: c_int) Self {
        return switch (key) {
            glfw.GLFW_KEY_SPACE => .space,
            glfw.GLFW_KEY_APOSTROPHE => .apostrophe,
            glfw.GLFW_KEY_COMMA => .comma,
            glfw.GLFW_KEY_MINUS => .minus,
            glfw.GLFW_KEY_PERIOD => .period,
            glfw.GLFW_KEY_SLASH => .slash,
            glfw.GLFW_KEY_0 => .zero,
            glfw.GLFW_KEY_1 => .one,
            glfw.GLFW_KEY_2 => .two,
            glfw.GLFW_KEY_3 => .three,
            glfw.GLFW_KEY_4 => .four,
            glfw.GLFW_KEY_5 => .five,
            glfw.GLFW_KEY_6 => .six,
            glfw.GLFW_KEY_7 => .seven,
            glfw.GLFW_KEY_8 => .eight,
            glfw.GLFW_KEY_9 => .nine,
            glfw.GLFW_KEY_SEMICOLON => .semicolon,
            glfw.GLFW_KEY_EQUAL => .equal,
            glfw.GLFW_KEY_A => .a,
            glfw.GLFW_KEY_B => .b,
            glfw.GLFW_KEY_C => .c,
            glfw.GLFW_KEY_D => .d,
            glfw.GLFW_KEY_E => .e,
            glfw.GLFW_KEY_F => .f,
            glfw.GLFW_KEY_G => .g,
            glfw.GLFW_KEY_H => .h,
            glfw.GLFW_KEY_I => .i,
            glfw.GLFW_KEY_J => .j,
            glfw.GLFW_KEY_K => .k,
            glfw.GLFW_KEY_L => .l,
            glfw.GLFW_KEY_M => .m,
            glfw.GLFW_KEY_N => .n,
            glfw.GLFW_KEY_O => .o,
            glfw.GLFW_KEY_P => .p,
            glfw.GLFW_KEY_Q => .q,
            glfw.GLFW_KEY_R => .r,
            glfw.GLFW_KEY_S => .s,
            glfw.GLFW_KEY_T => .t,
            glfw.GLFW_KEY_U => .u,
            glfw.GLFW_KEY_V => .v,
            glfw.GLFW_KEY_W => .w,
            glfw.GLFW_KEY_X => .x,
            glfw.GLFW_KEY_Y => .y,
            glfw.GLFW_KEY_Z => .z,
            glfw.GLFW_KEY_LEFT_BRACKET => .leftBracket,
            glfw.GLFW_KEY_BACKSLASH => .backslash,
            glfw.GLFW_KEY_RIGHT_BRACKET => .rightBracket,
            glfw.GLFW_KEY_GRAVE_ACCENT => .graveAccent,
            glfw.GLFW_KEY_WORLD_1 => .world1,
            glfw.GLFW_KEY_WORLD_2 => .world2,
            glfw.GLFW_KEY_ESCAPE => .escape,
            glfw.GLFW_KEY_ENTER => .enter,
            glfw.GLFW_KEY_TAB => .tab,
            glfw.GLFW_KEY_BACKSPACE => .backspace,
            glfw.GLFW_KEY_INSERT => .insert,
            glfw.GLFW_KEY_DELETE => .delete,
            glfw.GLFW_KEY_RIGHT => .right,
            glfw.GLFW_KEY_LEFT => .left,
            glfw.GLFW_KEY_DOWN => .down,
            glfw.GLFW_KEY_UP => .up,
            glfw.GLFW_KEY_PAGE_UP => .pageUp,
            glfw.GLFW_KEY_PAGE_DOWN => .pageDown,
            glfw.GLFW_KEY_HOME => .home,
            glfw.GLFW_KEY_END => .end,
            glfw.GLFW_KEY_CAPS_LOCK => .capsLock,
            glfw.GLFW_KEY_SCROLL_LOCK => .scrollLock,
            glfw.GLFW_KEY_NUM_LOCK => .numLock,
            glfw.GLFW_KEY_PRINT_SCREEN => .printScreen,
            glfw.GLFW_KEY_PAUSE => .pause,
            glfw.GLFW_KEY_F1 => .f1,
            glfw.GLFW_KEY_F2 => .f2,
            glfw.GLFW_KEY_F3 => .f3,
            glfw.GLFW_KEY_F4 => .f4,
            glfw.GLFW_KEY_F5 => .f5,
            glfw.GLFW_KEY_F6 => .f6,
            glfw.GLFW_KEY_F7 => .f7,
            glfw.GLFW_KEY_F8 => .f8,
            glfw.GLFW_KEY_F9 => .f9,
            glfw.GLFW_KEY_F10 => .f10,
            glfw.GLFW_KEY_F11 => .f11,
            glfw.GLFW_KEY_F12 => .f12,
            glfw.GLFW_KEY_F13 => .f13,
            glfw.GLFW_KEY_F14 => .f14,
            glfw.GLFW_KEY_F15 => .f15,
            glfw.GLFW_KEY_F16 => .f16,
            glfw.GLFW_KEY_F17 => .f17,
            glfw.GLFW_KEY_F18 => .f18,
            glfw.GLFW_KEY_F19 => .f19,
            glfw.GLFW_KEY_F20 => .f20,
            glfw.GLFW_KEY_F21 => .f21,
            glfw.GLFW_KEY_F22 => .f22,
            glfw.GLFW_KEY_F23 => .f23,
            glfw.GLFW_KEY_F24 => .f24,
            glfw.GLFW_KEY_F25 => .f25,
            glfw.GLFW_KEY_KP_0 => .kp0,
            glfw.GLFW_KEY_KP_1 => .kp1,
            glfw.GLFW_KEY_KP_2 => .kp2,
            glfw.GLFW_KEY_KP_3 => .kp3,
            glfw.GLFW_KEY_KP_4 => .kp4,
            glfw.GLFW_KEY_KP_5 => .kp5,
            glfw.GLFW_KEY_KP_6 => .kp6,
            glfw.GLFW_KEY_KP_7 => .kp7,
            glfw.GLFW_KEY_KP_8 => .kp8,
            glfw.GLFW_KEY_KP_9 => .kp9,
            glfw.GLFW_KEY_KP_DECIMAL => .kpDecimal,
            glfw.GLFW_KEY_KP_DIVIDE => .kpDivide,
            glfw.GLFW_KEY_KP_MULTIPLY => .kpMultiply,
            glfw.GLFW_KEY_KP_SUBTRACT => .kpSubtract,
            glfw.GLFW_KEY_KP_ADD => .kpAdd,
            glfw.GLFW_KEY_KP_ENTER => .kpEnter,
            glfw.GLFW_KEY_KP_EQUAL => .kpEqual,
            glfw.GLFW_KEY_LEFT_SHIFT => .leftShift,
            glfw.GLFW_KEY_LEFT_CONTROL => .leftControl,
            glfw.GLFW_KEY_LEFT_ALT => .leftAlt,
            glfw.GLFW_KEY_LEFT_SUPER => .leftSuper,
            glfw.GLFW_KEY_RIGHT_SHIFT => .rightShift,
            glfw.GLFW_KEY_RIGHT_CONTROL => .rightControl,
            glfw.GLFW_KEY_RIGHT_ALT => .rightAlt,
            glfw.GLFW_KEY_RIGHT_SUPER => .rightSuper,
            glfw.GLFW_KEY_MENU => .menu,
            else => .menu,
        };
    }
};

pub const MouseButton = enum(u8) {
    const Self = @This();

    mouseButton1,
    mouseButton2,
    mouseButton3,
    mouseButton4,
    mouseButton5,
    mouseButton6,
    mouseButton7,
    mouseButton8,

    pub const left = .mouseButton1;
    pub const right = .mouseButton2;
    pub const middle = .mouseButton3;

    pub fn count() u32 {
        return @intFromEnum(MouseButton.mouseButton8) + 1;
    }

    pub fn fromGLFW(button: c_int) Self {
        return switch (button) {
            glfw.GLFW_MOUSE_BUTTON_1 => .mouseButton1,
            glfw.GLFW_MOUSE_BUTTON_2 => .mouseButton2,
            glfw.GLFW_MOUSE_BUTTON_3 => .mouseButton3,
            glfw.GLFW_MOUSE_BUTTON_4 => .mouseButton4,
            glfw.GLFW_MOUSE_BUTTON_5 => .mouseButton5,
            glfw.GLFW_MOUSE_BUTTON_6 => .mouseButton6,
            glfw.GLFW_MOUSE_BUTTON_7 => .mouseButton7,
            glfw.GLFW_MOUSE_BUTTON_8 => .mouseButton8,
            else => .mouseButton8,
        };
    }
};
