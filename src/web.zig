// Copyright 2023 XXIV
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pub const WBY_OK = @as(c_int, 0);
pub const WBY_MAX_HEADERS = @as(c_int, 64);
pub const WBY_UINT_PTR = usize;
pub const wby_byte = u8;
pub const wby_size = usize;
pub const wby_ptr = usize;

pub const wby_header = extern struct {
    name: [*c]const u8,
    value: [*c]const u8,
};

pub const wby_request = extern struct {
    method: [*c]const u8,
    uri: [*c]const u8,
    http_version: [*c]const u8,
    query_params: [*c]const u8,
    content_length: c_int,
    header_count: c_int,
    headers: [WBY_MAX_HEADERS]wby_header,
};

pub const wby_con = extern struct {
    request: wby_request,
    user_data: ?*anyopaque,
};

pub const wby_frame = extern struct {
    flags: wby_byte,
    opcode: wby_byte,
    header_size: wby_byte,
    padding_: wby_byte,
    mask_key: [4]wby_byte,
    payload_length: c_int,
};

pub const wby_config = extern struct {
    userdata: ?*anyopaque,
    address: [*c]const u8,
    port: c_ushort,
    connection_max: c_uint,
    request_buffer_size: wby_size,
    io_buffer_size: wby_size,
    log: wby_log_f,
    dispatch: ?fn ([*c]wby_con, ?*anyopaque) callconv(.C) c_int,
    ws_connect: ?fn ([*c]wby_con, ?*anyopaque) callconv(.C) c_int,
    ws_connected: ?fn ([*c]wby_con, ?*anyopaque) callconv(.C) void,
    ws_closed: ?fn ([*c]wby_con, ?*anyopaque) callconv(.C) void,
    ws_frame: ?fn ([*c]wby_con, [*c]const wby_frame, ?*anyopaque) callconv(.C) c_int,
};

pub const wby_connection = opaque {};

pub const wby_server = extern struct {
    config: wby_config,
    memory_size: wby_size,
    socket: wby_ptr,
    con_count: wby_size,
    con: ?*wby_connection,
};

pub const wby_websock_flags = enum(c_uint) {
    FIN = 1,
    MASKED = 2
};

pub const wby_websock_operation = enum(c_uint) {
    CONTINUATION    = 0,
    TEXT_FRAME      = 1,
    BINARY_FRAME    = 2,
    CLOSE           = 8,
    PING            = 9,
    PONG            = 10
};

pub const wby_log_f = ?fn ([*c]const u8) callconv(.C) void;

pub extern "C" fn wby_init([*c]wby_server, [*c]const wby_config, needed_memory: [*c]wby_size) void;
pub extern "C" fn wby_start([*c]wby_server, memory: ?*anyopaque) c_int;
pub extern "C" fn wby_update([*c]wby_server) void;
pub extern "C" fn wby_stop([*c]wby_server) void;
pub extern "C" fn wby_response_begin([*c]wby_con, status_code: c_int, content_length: c_int, headers: [*c]const wby_header, header_count: c_int) c_int;
pub extern "C" fn wby_response_end([*c]wby_con) void;
pub extern "C" fn wby_read([*c]wby_con, ptr: ?*anyopaque, len: wby_size) c_int;
pub extern "C" fn wby_write([*c]wby_con, ptr: ?*const anyopaque, len: wby_size) c_int;
pub extern "C" fn wby_frame_begin([*c]wby_con, opcode: c_int) c_int;
pub extern "C" fn wby_frame_end([*c]wby_con) c_int;
pub extern "C" fn wby_find_query_var(buf: [*c]const u8, name: [*c]const u8, dst: [*c]u8, dst_len: wby_size) c_int;
pub extern "C" fn wby_find_header([*c]wby_con, name: [*c]const u8) [*c]const u8;
