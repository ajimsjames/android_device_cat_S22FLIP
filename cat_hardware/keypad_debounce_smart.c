/*
 * Cat S22 Flip Keypad Daemon with Smooth Continuous Virtual Mouse Mode
 *
 * 1. Debounces raw matrix keypad events (120ms anti-chatter).
 * 2. Number keys 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, # are 100% untouched:
 *    Always type normally for lockscreen PIN, dialer, and T9 text!
 * 3. Long-press '*' (KEY_NUMERIC_STAR / 522 >= 2.0 seconds):
 *    - Toggles Virtual Mouse Mode ON / OFF with haptic pulse.
 *    - In Mouse Mode:
 *        * D-PAD UP, DOWN, LEFT, RIGHT:
 *          - Continuous smooth fluid movement (60 Hz poll ticker).
 *          - Dynamic acceleration (starts precise, accelerates smoothly while held).
 *        * D-PAD CENTER (ENTER / 28): Left Click / Tap at cursor position.
 * 4. User Configurable Mouse Speed:
 *    - Real-time speed setting loaded from /dev/shm_outerscreen_cmd (configured via CatParts app).
 * 5. Normal Mode:
 *    - D-PAD works as normal directional navigation.
 *    - Speaker button: Short press -> TAB, Long press -> MENU.
 */

#define __NR_read          3
#define __NR_write         4
#define __NR_open          5
#define __NR_close         6
#define __NR_ioctl         54
#define __NR_nanosleep     162
#define __NR_poll          168
#define __NR_clock_gettime 263
#define __NR_exit          1

#include <linux/input.h>
#include <linux/uinput.h>

struct pollfd {
    int fd;
    short events;
    short revents;
};

#define POLLIN 0x0001

static inline long sc1(long n, long a) {
    register long r0 __asm__("r0") = a;
    register long r7 __asm__("r7") = n;
    __asm__ __volatile__("svc #0" : "+r"(r0) : "r"(r7) : "memory");
    return r0;
}
static inline long sc2(long n, long a, long b) {
    register long r0 __asm__("r0") = a;
    register long r1 __asm__("r1") = b;
    register long r7 __asm__("r7") = n;
    __asm__ __volatile__("svc #0" : "+r"(r0) : "r"(r7), "r"(r1) : "memory");
    return r0;
}
static inline long sc3(long n, long a, long b, long c) {
    register long r0 __asm__("r0") = a;
    register long r1 __asm__("r1") = b;
    register long r2 __asm__("r2") = c;
    register long r7 __asm__("r7") = n;
    __asm__ __volatile__("svc #0" : "+r"(r0) : "r"(r7), "r"(r1), "r"(r2) : "memory");
    return r0;
}

static long _open(const char *path, int flags) { return sc2(__NR_open, (long)path, flags); }
static long _read(int fd, void *buf, long len) { return sc3(__NR_read, fd, (long)buf, len); }
static long _write(int fd, const void *buf, long len) { return sc3(__NR_write, fd, (long)buf, len); }
static long _close(int fd) { return sc1(__NR_close, fd); }
static long _ioctl(int fd, unsigned long req, long arg) { return sc3(__NR_ioctl, fd, (long)req, arg); }
static long _poll(struct pollfd *fds, unsigned int nfds, int timeout) { return sc3(__NR_poll, (long)fds, (long)nfds, (long)timeout); }
static void _exit(int code) { sc1(__NR_exit, code); __builtin_unreachable(); }

struct _timespec { long tv_sec; long tv_nsec; };
static long long mono_ns(void) {
    struct _timespec ts;
    sc2(__NR_clock_gettime, 1, (long)&ts);
    return (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

static void _sleep_ms(int ms) {
    struct _timespec ts = { ms / 1000, (ms % 1000) * 1000000L };
    sc2(__NR_nanosleep, (long)&ts, 0);
}

static void _memset(void *p, int v, long n) {
    unsigned char *b = p;
    while (n--) *b++ = (unsigned char)v;
}

#define INPUT_DEV       "/dev/input/event1"
#define UINPUT_DEV      "/dev/uinput"
#define CONFIG_FILE     "/dev/shm_outerscreen_cmd"

#define DEBOUNCE_NS     120000000LL        /* 120 ms anti-chatter */
#define STAR_LONG_NS    2000000000LL       /* Full 2.0 seconds long-press for '*' */
#define SPK_LONG_NS     500000000LL        /* 500 ms for Speaker button */
#define MAX_KEYS        600
#define O_RDONLY        0
#define O_WRONLY        1
#define O_NONBLOCK      2048

#define KEY_SPEAKER_RAW 248  /* KEY_MICMUTE */
#define KEY_CUSTOM_TAB  15   /* KEY_TAB */
#define KEY_CUSTOM_MENU 139  /* KEY_MENU */

#define KEY_STAR_RAW    522  /* KEY_NUMERIC_STAR */
#define KEY_ENTER_RAW   28   /* KEY_ENTER */
#define KEY_UP_RAW      103  /* KEY_UP */
#define KEY_DOWN_RAW    108  /* KEY_DOWN */
#define KEY_LEFT_RAW    105  /* KEY_LEFT */
#define KEY_RIGHT_RAW   106  /* KEY_RIGHT */

static const int matrix_keys[] = {
    0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009,
    0x000a, 0x000b, 0x000e, 0x001c, 0x0067, 0x0069, 0x006a, 0x006c,
    0x009e, 0x00a9, 0x00ac, 0x00f8, 0x020a, 0x020b, 0x020c, 0x020d,
    0x0244,
    15,     /* KEY_TAB */
    139     /* KEY_MENU */
};
#define NUM_KEYS (sizeof(matrix_keys)/sizeof(matrix_keys[0]))

static void emit_key(int ui, int code, int val) {
    struct input_event ev;
    _memset(&ev, 0, sizeof(ev));
    ev.type = EV_KEY;
    ev.code = code;
    ev.value = val;
    _write(ui, &ev, sizeof(ev));

    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    ev.value = 0;
    _write(ui, &ev, sizeof(ev));
}

static void emit_rel(int ui, int code, int val) {
    struct input_event ev;
    _memset(&ev, 0, sizeof(ev));
    ev.type = EV_REL;
    ev.code = code;
    ev.value = val;
    _write(ui, &ev, sizeof(ev));

    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    ev.value = 0;
    _write(ui, &ev, sizeof(ev));
}

static void emit_rel_xy(int ui, int dx, int dy) {
    struct input_event ev;
    if (dx != 0) {
        _memset(&ev, 0, sizeof(ev));
        ev.type = EV_REL;
        ev.code = REL_X;
        ev.value = dx;
        _write(ui, &ev, sizeof(ev));
    }
    if (dy != 0) {
        _memset(&ev, 0, sizeof(ev));
        ev.type = EV_REL;
        ev.code = REL_Y;
        ev.value = dy;
        _write(ui, &ev, sizeof(ev));
    }
    _memset(&ev, 0, sizeof(ev));
    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    ev.value = 0;
    _write(ui, &ev, sizeof(ev));
}

static void haptic_pulse(int ms) {
    int fd_dur = (int)_open("/sys/class/leds/vibrator/duration", O_WRONLY);
    int fd_act = (int)_open("/sys/class/leds/vibrator/activate", O_WRONLY);
    if (fd_dur >= 0 && fd_act >= 0) {
        char buf[16];
        int len = 0;
        int tmp = ms;
        char rev[16];
        int rlen = 0;
        while (tmp > 0) { rev[rlen++] = '0' + (tmp % 10); tmp /= 10; }
        if (rlen == 0) rev[rlen++] = '0';
        while (rlen > 0) buf[len++] = rev[--rlen];
        buf[len++] = '\n';
        _write(fd_dur, buf, len);
        _write(fd_act, "1\n", 2);
    }
    if (fd_dur >= 0) _close(fd_dur);
    if (fd_act >= 0) _close(fd_act);
}

/* Parse mouse speed preference from config file */
static int read_configured_mouse_speed(int default_speed) {
    int fd = (int)_open(CONFIG_FILE, O_RDONLY);
    if (fd < 0) return default_speed;
    char buf[512];
    long n = _read(fd, buf, sizeof(buf) - 1);
    _close(fd);
    if (n <= 0) return default_speed;
    buf[n] = '\0';
    for (int i = 0; i <= n - 12; i++) {
        if (buf[i] == 'm' && buf[i+1] == 'o' && buf[i+2] == 'u' &&
            buf[i+3] == 's' && buf[i+4] == 'e' && buf[i+5] == '_' &&
            buf[i+6] == 's' && buf[i+7] == 'p' && buf[i+8] == 'e' &&
            buf[i+9] == 'e' && buf[i+10] == 'd' && buf[i+11] == '=') {
            int val = 0;
            int j = i + 12;
            while (j < n && buf[j] >= '0' && buf[j] <= '9') {
                val = val * 10 + (buf[j] - '0');
                j++;
            }
            if (val >= 4 && val <= 80) return val;
        }
    }
    return default_speed;
}

void main(void) {
    int src = (int)_open(INPUT_DEV, O_RDONLY | O_NONBLOCK);
    if (src < 0) _exit(1);

    _ioctl(src, EVIOCGRAB, 1);

    int ui = (int)_open(UINPUT_DEV, O_WRONLY | O_NONBLOCK);
    if (ui < 0) _exit(2);

    _ioctl(ui, UI_SET_EVBIT, EV_KEY);
    _ioctl(ui, UI_SET_EVBIT, EV_REL);
    _ioctl(ui, UI_SET_EVBIT, EV_SYN);
    _ioctl(ui, UI_SET_EVBIT, EV_MSC);
    _ioctl(ui, UI_SET_MSCBIT, MSC_SCAN);

    _ioctl(ui, UI_SET_RELBIT, REL_X);
    _ioctl(ui, UI_SET_RELBIT, REL_Y);
    _ioctl(ui, UI_SET_RELBIT, REL_WHEEL);

    _ioctl(ui, UI_SET_KEYBIT, BTN_LEFT);
    _ioctl(ui, UI_SET_KEYBIT, BTN_RIGHT);
    _ioctl(ui, UI_SET_KEYBIT, BTN_MIDDLE);

    for (unsigned int i = 0; i < NUM_KEYS; i++) {
        _ioctl(ui, UI_SET_KEYBIT, matrix_keys[i]);
    }

    struct uinput_user_dev uid;
    _memset(&uid, 0, sizeof(uid));
    const char *nm = "Cat_Keypad_Clean";
    for (int i = 0; nm[i]; i++) uid.name[i] = nm[i];
    uid.id.bustype = 0x0003;
    uid.id.vendor  = 0x18d1;
    uid.id.product = 0x0001;
    uid.id.version = 0x0001;

    _write(ui, &uid, sizeof(uid));
    _ioctl(ui, UI_DEV_CREATE, 0);

    long long last_down[MAX_KEYS];
    long long last_up[MAX_KEYS];
    int       last_val[MAX_KEYS];
    _memset(last_down, 0, sizeof(last_down));
    _memset(last_up,   0, sizeof(last_up));
    for (int i = 0; i < MAX_KEYS; i++) last_val[i] = -1;

    long long spk_down_time = 0;
    int spk_is_down = 0;

    long long star_down_time = 0;
    int star_is_down = 0;

    int mouse_mode = 0; /* 0 = Normal, 1 = Mouse Cursor Mode */
    int current_mouse_speed = 18; /* Default base speed */

    long long enter_down_time = 0;
    int enter_is_down = 0;

    /* Active directional hold state for smooth 60Hz continuous movement */
    int dpad_up_held = 0;
    int dpad_down_held = 0;
    int dpad_left_held = 0;
    int dpad_right_held = 0;
    long long dpad_held_start = 0;

    long long last_cfg_check = 0;

    struct pollfd pfd;
    pfd.fd = src;
    pfd.events = POLLIN;

    for (;;) {
        /*
         * If any D-PAD key is held in mouse mode, poll with a 16ms (~60 FPS) timeout
         * to produce continuous, butter-smooth cursor motion!
         * Otherwise, wait up to 1000ms.
         */
        int any_held = mouse_mode && (dpad_up_held || dpad_down_held || dpad_left_held || dpad_right_held);
        int timeout_ms = any_held ? 16 : 1000;

        pfd.revents = 0;
        _poll(&pfd, 1, timeout_ms);

        long long now = mono_ns();

        /* Periodically refresh speed preference every 2 seconds */
        if (now - last_cfg_check > 2000000000LL) {
            current_mouse_speed = read_configured_mouse_speed(18);
            last_cfg_check = now;
        }

        /* Read pending hardware input events */
        if (pfd.revents & POLLIN) {
            struct input_event ev;
            while (_read(src, &ev, sizeof(ev)) == (long)sizeof(ev)) {
                if (ev.type != EV_KEY) {
                    _write(ui, &ev, sizeof(ev));
                    continue;
                }

                int code = ev.code;
                int val  = ev.value;

                if (code < 0 || code >= MAX_KEYS) {
                    _write(ui, &ev, sizeof(ev));
                    continue;
                }

                if (val == 1) {
                    if (last_val[code] == 1 && (now - last_down[code]) < DEBOUNCE_NS) continue;
                    if (last_val[code] == 0 && (now - last_up[code])   < DEBOUNCE_NS) continue;
                    last_down[code] = now;
                    last_val[code]  = 1;
                } else if (val == 0) {
                    if (last_val[code] == 0 && (now - last_up[code]) < DEBOUNCE_NS) continue;
                    if (last_val[code] != 1) continue;
                    last_up[code]  = now;
                    last_val[code] = 0;
                }

                /* 1. Long-press '*' (>= 2.0 seconds) to toggle Virtual Mouse */
                if (code == KEY_STAR_RAW) {
                    if (val == 1) {
                        star_down_time = now;
                        star_is_down = 1;
                    } else if (val == 0) {
                        if (star_is_down) {
                            star_is_down = 0;
                            long long duration = now - star_down_time;
                            if (duration >= STAR_LONG_NS) {
                                mouse_mode = !mouse_mode;
                                dpad_up_held = 0;
                                dpad_down_held = 0;
                                dpad_left_held = 0;
                                dpad_right_held = 0;
                                if (mouse_mode) {
                                    haptic_pulse(60);
                                    current_mouse_speed = read_configured_mouse_speed(18);
                                    emit_rel(ui, REL_X, 0);
                                    emit_rel(ui, REL_Y, 0);
                                } else {
                                    haptic_pulse(25);
                                    _sleep_ms(80);
                                    haptic_pulse(25);
                                }
                            } else {
                                /* Normal short press '*' */
                                emit_key(ui, KEY_STAR_RAW, 1);
                                emit_key(ui, KEY_STAR_RAW, 0);
                            }
                        }
                    }
                    continue;
                }

                /* 2. Speaker Button (Short -> TAB, Long -> MENU) */
                if (code == KEY_SPEAKER_RAW) {
                    if (val == 1) {
                        spk_down_time = now;
                        spk_is_down = 1;
                    } else if (val == 0) {
                        if (spk_is_down) {
                            spk_is_down = 0;
                            long long duration = now - spk_down_time;
                            if (duration >= SPK_LONG_NS) {
                                emit_key(ui, KEY_CUSTOM_MENU, 1);
                                emit_key(ui, KEY_CUSTOM_MENU, 0);
                            } else {
                                emit_key(ui, KEY_CUSTOM_TAB, 1);
                                emit_key(ui, KEY_CUSTOM_TAB, 0);
                            }
                        }
                    }
                    continue;
                }

                /* 3. Virtual Mouse Controls (Active ONLY when mouse_mode == 1) */
                if (mouse_mode) {
                    if (code == KEY_UP_RAW) {
                        dpad_up_held = (val == 1);
                        if (val == 1) dpad_held_start = now;
                        continue;
                    } else if (code == KEY_DOWN_RAW) {
                        dpad_down_held = (val == 1);
                        if (val == 1) dpad_held_start = now;
                        continue;
                    } else if (code == KEY_LEFT_RAW) {
                        dpad_left_held = (val == 1);
                        if (val == 1) dpad_held_start = now;
                        continue;
                    } else if (code == KEY_RIGHT_RAW) {
                        dpad_right_held = (val == 1);
                        if (val == 1) dpad_held_start = now;
                        continue;
                    } else if (code == KEY_ENTER_RAW) {
                        if (val == 1) {
                            enter_down_time = now;
                            enter_is_down = 1;
                        } else if (val == 0) {
                            if (enter_is_down) {
                                enter_is_down = 0;
                                long long duration = now - enter_down_time;
                                if (duration >= 500000000LL) {
                                    /* Long Press (> 0.5s): Right Click (Context Menu / Back) */
                                    haptic_pulse(40);
                                    emit_key(ui, BTN_RIGHT, 1);
                                    emit_key(ui, BTN_RIGHT, 0);
                                } else {
                                    /* Short Tap (< 0.5s): Left Click (Tap / Open) */
                                    emit_key(ui, BTN_LEFT, 1);
                                    emit_key(ui, BTN_LEFT, 0);
                                }
                            }
                        }
                        continue;
                    }
                }

                /* 4. Normal Mode:
                 *    Every other key (Numbers 0-9, #, Back, Call, Home, Volume, etc.)
                 *    is 100% untouched and passes straight through to Android!
                 */
                _write(ui, &ev, sizeof(ev));
            }
        }

        /* 5. Continuous Smooth Mouse Movement Loop */
        if (mouse_mode && (dpad_up_held || dpad_down_held || dpad_left_held || dpad_right_held)) {
            long long hold_time = now - dpad_held_start;

            /*
             * Smooth dynamic acceleration:
             * - Initial 150ms: Fine precision (starts around 5-8 px per tick).
             * - After 150ms: Smoothly accelerates up to full configured speed.
             * - After 800ms of continuous hold: Turbo boost (up to 1.6x) for long sweeps.
             */
            int step = current_mouse_speed / 3;
            if (step < 4) step = 4;

            if (hold_time > 800000000LL) {
                step = (current_mouse_speed * 16) / 10;
            } else if (hold_time > 150000000LL) {
                step = current_mouse_speed;
            }

            int dx = 0;
            int dy = 0;
            if (dpad_left_held)  dx -= step;
            if (dpad_right_held) dx += step;
            if (dpad_up_held)    dy -= step;
            if (dpad_down_held)  dy += step;

            emit_rel_xy(ui, dx, dy);
        }
    }

    _ioctl(ui, UI_DEV_DESTROY, 0);
    _exit(0);
}
