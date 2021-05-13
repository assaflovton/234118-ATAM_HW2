#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>

// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>

// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>

// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>

// </STUDENT FILL>
}
