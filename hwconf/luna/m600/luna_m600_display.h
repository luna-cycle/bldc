/*
	Copyright 2020 Marcos Chaparro	mchaparro@powerdesigns.ca

	This file is part of the VESC firmware.

	The VESC firmware is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The VESC firmware is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    */

#ifndef APP_LUNA_DISPLAY_CANBUS_H_
#define APP_LUNA_DISPLAY_CANBUS_H_

#include "stdint.h"

typedef enum {
	PAS_LEVEL_0 = 0x00,
	PAS_LEVEL_1 = 0x01,
	PAS_LEVEL_2 = 0x0B,
	PAS_LEVEL_3 = 0x0C,
	PAS_LEVEL_4 = 0x0D,
	PAS_LEVEL_5 = 0x02,
	PAS_LEVEL_6 = 0x15,
	PAS_LEVEL_7 = 0x16,
	PAS_LEVEL_8 = 0x17,
	PAS_LEVEL_9 = 0x03,
	PAS_LEVEL_WALK = 0x06,
} LUNA_PAS_LEVEL;

void luna_canbus_start(void);
float luna_canbus_get_PAS_torque(void);
float get_encoder_error(void);
float get_torque_sensor_deadband(void);
int32_t get_torque_sensor_output(void);
int32_t get_torque_sensor_lower_range(void);
int32_t get_torque_sensor_upper_range(void);
int32_t set_torque_sensor_lower_range(int32_t new_lower_range);
int32_t set_torque_sensor_upper_range(int32_t new_upper_range);
int32_t measure_torque_sensor_offset(void);
LUNA_PAS_LEVEL luna_canbus_get_pas_level(void);
#endif /* APP_LUNA_DISPLAY_CANBUS_H_ */
