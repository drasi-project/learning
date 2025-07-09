// Copyright 2025 The Drasi Authors.
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

export const VEHICLE_COLORS = [
    { name: 'Blue', hex: '#1E40AF' },
    { name: 'Red', hex: '#DC2626' },
    { name: 'Green', hex: '#047857' },
    { name: 'Black', hex: '#111827' },
    { name: 'Purple', hex: '#6D28D9' }
] as const;

export const DEFAULT_COLOR = { name: 'Yellow', hex: '#FACC15' };

export type VehicleColor = typeof VEHICLE_COLORS[number]['name'];

/**
 * Gets the hex color value for a given vehicle color name.
 * Returns the default color (yellow) if the color isn't found.
 */
export const getColorValue = (color: string): string => {
    const colorMatch = VEHICLE_COLORS.find(
        vc => vc.name.toLowerCase() === color.toLowerCase()
    );
    return colorMatch?.hex || DEFAULT_COLOR.hex;
};