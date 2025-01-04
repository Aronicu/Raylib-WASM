#+private
#+build freestanding
package game

import "base:runtime"
import "core:mem"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:c"

import rl "../../raylib"

@(private="file")
wasm_context: runtime.Context

@(private="file")
temp_allocator: WASM_Temp_Allocator

@(export)
game_init :: proc "c" () {
    wasm_context = create_wasm_context()
    context = wasm_context
    init()
}

@(export)
game_frame :: proc "c" () {
    context = wasm_context
    frame()
}

@(private="file")
create_wasm_context :: proc "contextless" () -> runtime.Context {
	context = runtime.default_context()

    c: runtime.Context = runtime.default_context()
    c.allocator = rl.MemAllocator()

    c.logger = create_wasm_logger()

	wasm_temp_allocator_init(&temp_allocator, 1 * mem.Megabyte, c.allocator)
    c.temp_allocator = wasm_temp_allocator(&temp_allocator)

    return c
}

WASM_Temp_Allocator :: struct {
	arena: runtime.Arena,
}

wasm_temp_allocator_init :: proc(s: ^WASM_Temp_Allocator, size: int, backing_allocator := context.allocator) {
	_ = runtime.arena_init(&s.arena, uint(size), backing_allocator)
}

wasm_temp_allocator_proc :: proc(
	allocator_data: rawptr,
	mode: runtime.Allocator_Mode,
	size, alignment: int,
	old_memory: rawptr,
	old_size: int,
	loc := #caller_location) -> (data: []byte, err: runtime.Allocator_Error) {
	s := (^WASM_Temp_Allocator)(allocator_data)
	return runtime.arena_allocator_proc(&s.arena, mode, size, alignment, old_memory, old_size, loc)
}

wasm_temp_allocator :: proc(allocator: ^WASM_Temp_Allocator) -> runtime.Allocator {
	return runtime.Allocator{
		procedure = wasm_temp_allocator_proc,
		data      = allocator,
	}
}

Wasm_Logger_Opts :: log.Options{.Level, .Short_File_Path, .Line}

@(private="file")
create_wasm_logger :: proc (lowest := log.Level.Debug, opt := Wasm_Logger_Opts) -> log.Logger {
	return log.Logger{data = nil, procedure = wasm_logger_proc, lowest_level = lowest, options = opt}
}

@(private="file")
wasm_logger_proc :: proc(
	logger_data: rawptr,
	level: log.Level,
	text: string,
	options: log.Options,
	location := #caller_location,
) {
	backing: [1024]byte
	buf := strings.builder_from_bytes(backing[:])

	do_level_header(options, &buf, level)
	do_location_header(options, &buf, location)
	fmt.sbprintf(&buf, text)
	// strings.write_byte(&buf, 0)

	puts(strings.to_cstring(&buf))
	// puts(fmt.ctprintf("%s%s", strings.to_string(buf), text))
}

Level_Headers := [?]string {
	0 ..< 10 = "[DEBUG] --- ",
	10 ..< 20 = "[INFO ] --- ",
	20 ..< 30 = "[WARN ] --- ",
	30 ..< 40 = "[ERROR] --- ",
	40 ..< 50 = "[FATAL] --- ",
}

@(private="file")
do_level_header :: proc(options: log.Options, buf: ^strings.Builder, level: log.Level) {
	fmt.sbprintf(buf, Level_Headers[level])
}

@(private="file")
do_location_header :: proc(opts: log.Options, buf: ^strings.Builder, location := #caller_location) {
	if log.Location_Header_Opts & opts == nil {
		return
	}
	fmt.sbprint(buf, "[")
	file := location.file_path
	if .Short_File_Path in opts {
		last := 0
		for r, i in location.file_path {
			if r == '/' {
				last = i + 1
			}
		}
		file = location.file_path[last:]
	}

	if log.Location_File_Opts & opts != nil {
		fmt.sbprint(buf, file)
	}
	if .Line in opts {
		if log.Location_File_Opts & opts != nil {
			fmt.sbprint(buf, ":")
		}
		fmt.sbprint(buf, location.line)
	}

	if .Procedure in opts {
		if (log.Location_File_Opts | {.Line}) & opts != nil {
			fmt.sbprint(buf, ":")
		}
		fmt.sbprintf(buf, "%s()", location.procedure)
	}

	fmt.sbprint(buf, "] ")
}

@(default_calling_convention = "c")
foreign {
	puts :: proc(buffer: cstring) -> c.int ---
}
