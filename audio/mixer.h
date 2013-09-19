/*
 * This file is part of MPlayer.
 *
 * MPlayer is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * MPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with MPlayer; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef MPLAYER_MIXER_H
#define MPLAYER_MIXER_H

#include <stdbool.h>

// Values of MPOpts.softvol
enum {
    SOFTVOL_NO = 0,
    SOFTVOL_YES = 1,
    SOFTVOL_AUTO = 2,
};

typedef struct mixer {
    struct MPOpts *opts;
    struct ao *ao;
    struct af_stream *af;
    // Static, dependent on ao/softvol settings
    bool softvol;                       // use AO (true) or af_volume (false)
    bool emulate_mute;                  // if true, emulate mute with volume=0
    // Last known values (possibly out of sync with reality)
    float vol_l, vol_r;
    bool muted;
    // Used to decide whether we should unmute on uninit
    bool muted_by_us;
    /* Contains ao driver name or "softvol" if volume is not persistent
     * and needs to be restored after the driver is reinitialized. */
    const char *driver;
    // Other stuff
    float balance;
} mixer_t;

void mixer_init(struct mixer *mixer, struct MPOpts *opts);
void mixer_reinit_audio(struct mixer *mixer, struct ao *ao, struct af_stream *af);
void mixer_uninit_audio(struct mixer *mixer);
void mixer_getvolume(mixer_t *mixer, float *l, float *r);
void mixer_setvolume(mixer_t *mixer, float l, float r);
void mixer_incvolume(mixer_t *mixer);
void mixer_decvolume(mixer_t *mixer);
void mixer_getbothvolume(mixer_t *mixer, float *b);
void mixer_setmute(mixer_t *mixer, bool mute);
bool mixer_getmute(mixer_t *mixer);
void mixer_getbalance(mixer_t *mixer, float *bal);
void mixer_setbalance(mixer_t *mixer, float bal);
char *mixer_get_volume_restore_data(struct mixer *mixer);

#endif /* MPLAYER_MIXER_H */
