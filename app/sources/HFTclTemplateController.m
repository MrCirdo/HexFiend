//
//  HFTclTemplateController.m
//  HexFiend_2
//
//  Created by Kevin Wojniak on 1/6/18.
//  Copyright © 2018 ridiculous_fish. All rights reserved.
//

#import "HFTclTemplateController.h"
#import <tcl.h>
#import <tclTomMath.h>

static Tcl_Obj* tcl_obj_from_uint64(uint64_t value) {
    char buf[21];
    const size_t num_bytes = snprintf(buf, sizeof(buf), "%" PRIu64, value);
    return Tcl_NewStringObj(buf, (int)num_bytes);
}

static Tcl_Obj* tcl_obj_from_int64(int64_t value) {
    return Tcl_NewWideIntObj((Tcl_WideInt)value);
}

static Tcl_Obj* tcl_obj_from_uint32(uint32_t value) {
    return Tcl_NewWideIntObj((Tcl_WideInt)value);
}

static Tcl_Obj* tcl_obj_from_int32(int32_t value) {
    return Tcl_NewIntObj((int)value);
}

static Tcl_Obj* tcl_obj_from_uint16(uint16_t value) {
    return Tcl_NewIntObj((int)value);
}

static Tcl_Obj* tcl_obj_from_int16(int16_t value) {
    return Tcl_NewIntObj((int)value);
}

static Tcl_Obj* tcl_obj_from_uint8(uint8_t value) {
    return Tcl_NewIntObj((int)value);
}

static Tcl_Obj* tcl_obj_from_int8(int8_t value) {
    return Tcl_NewIntObj((int)value);
}

enum command {
    command_uint64,
    command_int64,
    command_uint32,
    command_int32,
    command_uint16,
    command_int16,
    command_uint8,
    command_int8,
};

@interface HFTclTemplateController ()

@property (weak) HFController *controller;
@property unsigned long long position;

- (int)runCommand:(enum command)command objc:(int)objc objv:(struct Tcl_Obj * CONST *)objv;

@end

#define DEFINE_COMMAND(name) \
    int cmd_##name(ClientData clientData, Tcl_Interp *interp __unused, int objc, struct Tcl_Obj * CONST * objv) { \
        return [(__bridge HFTclTemplateController *)clientData runCommand:command_##name objc:objc objv:objv]; \
    }

DEFINE_COMMAND(uint64)
DEFINE_COMMAND(int64)
DEFINE_COMMAND(uint32)
DEFINE_COMMAND(int32)
DEFINE_COMMAND(uint16)
DEFINE_COMMAND(int16)
DEFINE_COMMAND(uint8)
DEFINE_COMMAND(int8)

@implementation HFTclTemplateController {
    Tcl_Interp *_interp;
}

- (instancetype)initWithController:(HFController *)controller {
    if ((self = [super init]) == nil) {
        return nil;
    }

    _controller = controller;

    _interp = Tcl_CreateInterp();
    if (Tcl_Init(_interp) != TCL_OK) {
        fprintf(stderr, "Tcl_Init error: %s\n", Tcl_GetStringResult(_interp));
        return nil;
    }

    struct command {
        const char *name;
        Tcl_ObjCmdProc *proc;
    };
    const struct command commands[] = {
        {"uint64", cmd_uint64},
        {"int64", cmd_int64},
        {"uint32", cmd_uint32},
        {"int32", cmd_int32},
        {"uint16", cmd_uint16},
        {"int16", cmd_int16},
        {"uint8", cmd_uint8},
        {"int8", cmd_int8},
    };
    for (size_t i = 0; i < sizeof(commands) / sizeof(commands[0]); ++i) {
        Tcl_CreateObjCommand(_interp, commands[i].name, commands[i].proc, (__bridge ClientData)self, NULL);
    }

    return self;
}

- (void)dealloc {
    if (_interp) {
        Tcl_DeleteInterp(_interp);
    }
}

- (NSString *)evaluateScript:(NSString *)path {
    if (Tcl_EvalFile(_interp, [path fileSystemRepresentation]) != TCL_OK) {
        return [NSString stringWithUTF8String:Tcl_GetStringResult(_interp)];
    }
    return nil;
}

- (int)runCommand:(enum command)command objc:(int)objc objv:(struct Tcl_Obj * CONST *)objv {
    if (objc != 2) {
        Tcl_WrongNumArgs(_interp, 1, objv, "title");
        return TCL_ERROR;
    }
    const char *name = Tcl_GetStringFromObj(objv[1], NULL);
    printf("Name: %s\n", name);
    switch (command) {
        case command_uint64: {
            uint64_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_uint64(val));
            break;
        }
        case command_int64: {
            int64_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_int64(val));
            break;
        }
        case command_uint32: {
            uint32_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_uint32(val));
            break;
        }
        case command_int32: {
            int32_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_int32(val));
            break;
        }
        case command_uint16: {
            uint16_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_uint16(val));
            break;
        }
        case command_int16: {
            int16_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_int16(val));
            break;
        }
        case command_uint8: {
            uint8_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_uint8(val));
            break;
        }
        case command_int8: {
            int8_t val = 0;
            [self readBytes:&val size:sizeof(val)];
            Tcl_SetObjResult(_interp, tcl_obj_from_int8(val));
            break;
        }
    }
    return TCL_OK;
}

- (void)readBytes:(void *)buffer size:(size_t)size {
    HFRange range = HFRangeMake([self.controller minimumSelectionLocation] + self.position, size);
    [self.controller copyBytes:buffer range:range];
    self.position += size;
}

@end