#!/usr/bin/env python3
"""Compare the additive wind model with a constant-power cycling model.

The additive model (first implementation in this PR) assumed the rider keeps a
constant speed relative to the air, so the ground speed became
``v = v_still - headwind``.  Real cyclists hold a roughly constant power, and
only the aerodynamic part of the resistance grows with the wind, so the ground
speed drops much less than the headwind itself.

Power balance used here (Martin et al., 1998, "Validation of a Mathematical
Model for Road Cycling Power"):

    P = F_other * v + 0.5 * rho * CdA * v * (v + w) * |v + w|

``F_other`` collects rolling resistance, gravity and drivetrain losses; it is
recovered from the still-air speed that the routing profile predicts for the
segment, so slow segments (climbs, dirt) stay slow and are barely affected by
the wind, exactly as in reality.

Usage:  python3 experiments/bicycle_wind_model.py [path.json]
"""

import json
import math
import sys

RHO = 1.225  # kg/m^3, air density at sea level, 15 C
CDA = 0.4  # m^2, drag area of an upright rider on the hoods
CRR_FORCE_N = 4.0  # N, rolling + drivetrain force (Crr 0.005 * 80 kg * 9.81)
DRAG = 0.5 * RHO * CDA


def rider_power(cruising_speed_mps):
    """Power the rider sustains, implied by the flat-road cruising speed."""
    return CRR_FORCE_N * cruising_speed_mps + DRAG * cruising_speed_mps**3


def speed_with_wind(still_speed_mps, headwind_mps, power_w):
    """Ground speed at constant power for the given along-track headwind."""
    other_force = power_w / still_speed_mps - DRAG * still_speed_mps**2

    def excess(v):
        # The drag keeps the sign of the airspeed: a tailwind faster than the rider pushes.
        air = v + headwind_mps
        return other_force * v + DRAG * v * air * abs(air) - power_w

    lo, hi = 0.0, still_speed_mps + abs(headwind_mps)
    assert excess(lo) <= 1e-9 and excess(hi) >= -1e-9, (excess(lo), excess(hi))
    for _ in range(32):
        mid = 0.5 * (lo + hi)
        if excess(mid) < 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def speed_additive(still_speed_mps, headwind_mps):
    """The model this PR started with, including its 25% floor."""
    return max(still_speed_mps - headwind_mps, still_speed_mps * 0.25)


def bearing_deg(lon1, lat1, lon2, lat2):
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dlon = math.radians(lon2 - lon1)
    y = math.sin(dlon) * math.cos(phi2)
    x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(dlon)
    return math.degrees(math.atan2(y, x)) % 360.0


def distance_m(lon1, lat1, lon2, lat2):
    r = 6378137.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = phi2 - phi1
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlon / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def load_segments(path):
    with open(path) as f:
        data = json.load(f)
    coords = data["features"][0]["geometry"]["coordinates"]
    segments = []
    for (lon1, lat1, *alt1), (lon2, lat2, *alt2) in zip(coords, coords[1:]):
        d = distance_m(lon1, lat1, lon2, lat2)
        if d <= 0.0:
            continue
        grade = ((alt2[0] if alt2 else 0) - (alt1[0] if alt1 else 0)) / d
        segments.append((d, bearing_deg(lon1, lat1, lon2, lat2), grade))
    return segments


def bicycle_climb_penalty(grade):
    """Port of GetBicycleClimbPenalty() below the mountain sickness altitude.

    Same slope factor as libs/routing/edge_estimator.cpp, which follows
    https://web.tecnico.ulisboa.pt/~rosamfelix/gis/declives/SpeedSlopeFactor.html
    """
    slope = grade * 100.0
    if slope < -30.0:
        return 1.5
    if slope < 0.0:
        return 1.0 + 2 * 0.7 / 13.0 * slope + 0.7 / 169.0 * slope * slope
    if slope <= 20.0:
        return 1.0 + slope * slope / 49.0
    return 10.0


def travel_times(segments, cruising_kmph, wind_mps, wind_from_deg):
    """Return (still air, additive model, power model) seconds.

    The still-air speed of a segment is the cruising speed divided by the slope
    factor.  The router additionally scales by road type and clamps climbs on
    good roads, which a bare GeoJSON track cannot tell apart; the wind models
    are compared against the same still-air baseline, so that does not affect
    the comparison.
    """
    cruising = cruising_kmph / 3.6
    power = rider_power(cruising)
    still = additive = physical = 0.0
    for length, bearing, grade in segments:
        v0 = cruising / bicycle_climb_penalty(grade)
        headwind = wind_mps * math.cos(math.radians(bearing - wind_from_deg))
        still += length / v0
        additive += length / speed_additive(v0, headwind)
        physical += length / speed_with_wind(v0, headwind, power)
    return still, additive, physical


def fmt(seconds):
    return f"{int(seconds // 60)}:{int(seconds % 60):02d}"


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "path.json"
    segments = load_segments(path)
    total_km = sum(s[0] for s in segments) / 1000.0
    print(f"route: {len(segments)} segments, {total_km:.2f} km\n")

    for cruising_kmph in (20.0, 30.0):
        print(f"--- cruising speed {cruising_kmph:g} km/h ---")
        print(f"{'wind':>18} {'still air':>10} {'additive':>10} {'power':>10} "
              f"{'additive x':>11} {'power x':>9}")
        for wind_mps in (3, 5, 8):
            for wind_from, label in ((0.0, "N"), (90.0, "E"), (180.0, "S"), (270.0, "W")):
                still, additive, physical = travel_times(segments, cruising_kmph, wind_mps, wind_from)
                print(f"{wind_mps:>3} m/s from {label:<4} {fmt(still):>10} {fmt(additive):>10} "
                      f"{fmt(physical):>10} {additive / still:>10.2f}x {physical / still:>8.2f}x")
        print()

    print("--- headwind on a straight flat road, ground speed (km/h) ---")
    print(f"{'still air':>10} {'wind':>8} {'additive':>10} {'power':>8}")
    for cruising_kmph in (15.0, 20.0, 25.0, 30.0):
        cruising = cruising_kmph / 3.6
        power = rider_power(cruising)
        for wind_mps in (3, 5, 8):
            print(f"{cruising_kmph:>10.0f} {wind_mps:>8} "
                  f"{speed_additive(cruising, wind_mps) * 3.6:>10.1f} "
                  f"{speed_with_wind(cruising, wind_mps, power) * 3.6:>8.1f}")


if __name__ == "__main__":
    main()
