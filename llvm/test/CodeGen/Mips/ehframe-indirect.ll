; RUN: llc -mtriple=mipsel-linux-gnu < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,LINUX,LINUX-O32,O32 %s
; RUN: llc -mtriple=mipsel-linux-android < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,LINUX,LINUX-O32,O32 %s
; RUN: llc -mtriple=mips64el-linux-gnu -target-abi=n32 < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,N32,N32REL %s
; RUN: llc -mtriple=mips64el-linux-gnu < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,LINUX,LINUX-NEW,N64,N64REL %s
; RUN: llc -mtriple=mips64el-linux-android < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,LINUX,LINUX-NEW,N64,N64REL %s
; RUN: llc -mtriple=mips64el-linux-gnu < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,N64,N64REL %s
; RUN: llc -mtriple=mips64-unknown-freebsd11.0 < %s -asm-verbose -relocation-model=pic | \
; RUN:     FileCheck -check-prefixes=ALL,N64,N64REL %s

; RUN: llc -mtriple=mips64-linux-gnu -target-abi=n32 -mips-pc64-rel=false \
; RUN:     -asm-verbose -relocation-model=pic < %s | \
; RUN:     FileCheck -check-prefixes=ALL,N32,N32ABS %s
; RUN: llc -mtriple=mips64-linux-gnu -mips-pc64-rel=false \
; RUN:     -asm-verbose -relocation-model=pic < %s | \
; RUN:     FileCheck -check-prefixes=ALL,N64,N64ABS %s

@_ZTISt9exception = external constant ptr

define i32 @main() personality ptr @__gxx_personality_v0 {
; ALL: .cfi_startproc

; O32: .cfi_personality 155, DW.ref.__gxx_personality_v0
; O32: .cfi_lsda 27, $exception0
; N32REL: .cfi_personality 155, DW.ref.__gxx_personality_v0
; N32REL: .cfi_lsda 27, .Lexception0
; N32ABS: .cfi_personality 128, DW.ref.__gxx_personality_v0
; N32ABS: .cfi_lsda 0, .Lexception0
; N64REL: .cfi_personality 155, DW.ref.__gxx_personality_v0
; N64REL: .cfi_lsda 27, .Lexception0
; N64ABS: .cfi_personality 128, DW.ref.__gxx_personality_v0
; N64ABS: .cfi_lsda 0, .Lexception0

entry:
  invoke void @foo() to label %cont unwind label %lpad
; ALL: foo
; ALL: jalr

lpad:
  %0 = landingpad { ptr, i32 }
    catch ptr null
    catch ptr @_ZTISt9exception
  ret i32 0

cont:
  ret i32 0
}
; ALL: .cfi_endproc

declare i32 @__gxx_personality_v0(...)

declare void @foo()

; ALL: GCC_except_table{{[0-9]+}}:
; ALL: .byte 155 # @TType Encoding = indirect pcrel sdata4
; O32: [[PC_LABEL:\$tmp[0-9]+]]:
; N32: [[PC_LABEL:\.Ltmp[0-9]+]]:
; N64: [[PC_LABEL:\.Ltmp[0-9]+]]:
; O32: .4byte	($_ZTISt9exception.DW.stub)-([[PC_LABEL]])
; N32: .4byte	.L_ZTISt9exception.DW.stub-[[PC_LABEL]]
; N64: .4byte	.L_ZTISt9exception.DW.stub-[[PC_LABEL]]
; O32: $_ZTISt9exception.DW.stub:
; N32: .L_ZTISt9exception.DW.stub:
; N64: .L_ZTISt9exception.DW.stub:
; O32: .4byte _ZTISt9exception
; N32: .4byte _ZTISt9exception
; N64: .8byte _ZTISt9exception
; ALL: .hidden DW.ref.__gxx_personality_v0
; ALL: .weak DW.ref.__gxx_personality_v0
; ALL: .section .data.DW.ref.__gxx_personality_v0,"aGw",@progbits,DW.ref.__gxx_personality_v0,comdat
; O32: .p2align 2
; N32: .p2align 2
; N64: .p2align 3
; ALL: .type DW.ref.__gxx_personality_v0,@object
; O32: .size DW.ref.__gxx_personality_v0, 4
; N32: .size DW.ref.__gxx_personality_v0, 4
; N64: .size DW.ref.__gxx_personality_v0, 8
; ALL: DW.ref.__gxx_personality_v0:
; O32: .4byte __gxx_personality_v0
; N32: .4byte __gxx_personality_v0
; N64: .8byte __gxx_personality_v0
