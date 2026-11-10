/* Extra checks outside the graded source directories. Reuse the official
 * independent cubie replay, applying it to the complete distance-11 set. */
#include "hardstates.h"
#include "print.h"
#include "tests/trubik.c"

int main(void)
{
    uint64_t maximum = 0;
    unsigned worst = 0;
    for (unsigned i = 0; i < 2644; ++i) {
        int moves = -1;
        if (solve_and_verify(rubik_solve_asm, hard_states[i], &moves) !=
                TEST_PASS ||
            moves != 11)
            return 1;
        char out[64];
        uint64_t used;
        int length;
        PERF_CALL(used,
                  length = rubik_solve_asm(hard_states[i], out, sizeof out));
        if (length != 11 || used > RUBIK_INSN_BUDGET)
            return 2;
        if (used > maximum) {
            maximum = used;
            worst = i;
        }
    }
    bm_printf(
        "PASS: 2644/2644 distance-11 states; optimal paths replayed on "
        "target\n");
    bm_printf("maximum_instret=%llu state=%s budget=%u\n", maximum,
              hard_states[worst], RUBIK_INSN_BUDGET);
    return 0;
}
