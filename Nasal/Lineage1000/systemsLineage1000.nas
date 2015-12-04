# Lineage 1000 SYSTEMS
#########################

## LIVERY SELECT
################

aircraft.livery.init("Aircraft/VIP/Models/Liveries/Lineage1000");

## LIGHTS
#########

# create all lights
var beacon_switch = props.globals.getNode("controls/switches/beacon", 2);
var beacon = aircraft.light.new("sim/model/lights/beacon", [0.015, 3], "controls/lighting/beacon");

var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new("sim/model/lights/strobe", [0.025, 1.5], "controls/lighting/strobe");

## SOUNDS
#########

# seatbelt/no smoking sign triggers
setlistener("controls/switches/seatbelt-sign", func {
	props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(1);
	settimer(func {
  		props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(0);
  	}, 2);
});

setlistener("controls/switches/no-smoking-sign", func {
	props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(0);
	}, 2);
});

## INSTRUMENTS
##############

var instruments = {

	calcBugDeg: func(bug, limit) {
		var heading = getprop("orientation/heading-magnetic-deg");
		var bugDeg = 0;

		while (bug < 0) {
			bug += 360;
		}
		while (bug > 360) {
			bug -= 360;
		}
		if (bug < limit) {
			bug += 360;
		}
		if (heading < limit) {
			heading += 360;
		}

		# bug is adjusted normally
		if (math.abs(heading - bug) < limit) {
			bugDeg = heading - bug;
		} elsif (heading - bug < 0) {
			if (math.abs(heading - bug + 360 >= 180)) {
				# bug is on the far right
				bugDeg = -limit;
			} elsif (math.abs(heading - bug + 360 < 180)) {
				# bug is on the far left
				bugDeg = limit;
			}
		} else {
			if (math.abs(heading - bug >= 180)) {
				# bug is on the far right
				bugDeg = -limit;
			} elsif (math.abs(heading - bug < 180)) {
				# bug is on the far left
				bugDeg = limit;
			}
		}
		return bugDeg;
	},

	loop: func {
		instruments.setHSIBugsDeg();
		instruments.setSpeedBugs();
		instruments.setMPProps();
		instruments.calcEGTDegC();

		settimer(instruments.loop, 0);
	},

	# set the rotation of the HSI bugs
	setHSIBugsDeg: func {
		setprop("sim/model/ERJ/heading-bug-pfd-deg", instruments.calcBugDeg(getprop("autopilot/settings/heading-bug-deg"), 80));
		setprop("sim/model/ERJ/heading-bug-deg", instruments.calcBugDeg(getprop("autopilot/settings/heading-bug-deg"), 37));
		setprop("sim/model/ERJ/nav1-bug-deg", instruments.calcBugDeg(getprop("instrumentation/nav[0]/heading-deg"), 37));
		setprop("sim/model/ERJ/nav2-bug-deg", instruments.calcBugDeg(getprop("instrumentation/nav[1]/heading-deg"), 37));
		if (getprop("autopilot/route-manager/route/num") > 0 and getprop("autopilot/route-manager/wp[0]/bearing-deg") != nil) {
			setprop("sim/model/ERJ/wp-bearing-deg", instruments.calcBugDeg(getprop("autopilot/route-manager/wp[0]/bearing-deg"), 45));
		}
	},

	setSpeedBugs: func {
		setprop("sim/model/ERJ/ias-bug-kt-norm", getprop("autopilot/settings/target-speed-kt") - getprop("velocities/airspeed-kt"));
		setprop("sim/model/ERJ/mach-bug-kt-norm", (getprop("autopilot/settings/target-speed-mach") - getprop("velocities/mach")) * 600);
	},

	setMPProps: func {
		var calcMPDistance = func(tree) {
			var x = getprop(tree ~ "position/global-x");
			var y = getprop(tree ~ "position/global-y");
			var z = getprop(tree ~ "position/global-z");
			var coords = geo.Coord.new().set_xyz(x, y, z);

			var distance = nil;
			call(func distance = geo.aircraft_position().distance_to(coords), nil, var err = []);
			if (size(err) or distance == nil) {
				return 0;
			} else {
				return distance;
			}
		};

		var calcMPBearing = func(tree) {
			var x = getprop(tree ~ "position/global-x");
			var y = getprop(tree ~ "position/global-y");
			var z = getprop(tree ~ "position/global-z");
			var coords = geo.Coord.new().set_xyz(x, y, z);

			return geo.aircraft_position().course_to(coords);
		};

		if (getprop("ai/models/multiplayer[0]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[0]", calcMPDistance("ai/models/multiplayer[0]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[0]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[0]/"), 45));
		}
		if (getprop("ai/models/multiplayer[1]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[1]", calcMPDistance("ai/models/multiplayer[1]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[1]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[1]/"), 45));
		}
		if (getprop("ai/models/multiplayer[2]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[2]", calcMPDistance("ai/models/multiplayer[2]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[2]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[2]/"), 45));
		}
		if (getprop("ai/models/multiplayer[3]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[3]", calcMPDistance("ai/models/multiplayer[3]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[3]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[3]/"), 45));
		}
		if (getprop("ai/models/multiplayer[4]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[4]", calcMPDistance("ai/models/multiplayer[4]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[4]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[4]/"), 45));
		}
		if (getprop("ai/models/multiplayer[5]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[5]", calcMPDistance("ai/models/multiplayer[5]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[5]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[5]/"), 45));
		}
	},

	calcEGTDegC: func() {
		if (getprop("engines/engine[0]/egt-degf") != nil) {
			setprop("engines/engine[0]/egt-degc", (getprop("engines/engine[0]/egt-degf") - 32) * 1.8);
		}
		if (getprop("engines/engine[1]/egt-degf") != nil) {
			setprop("engines/engine[1]/egt-degc", (getprop("engines/engine[1]/egt-degf") - 32) * 1.8);
		}
	}

};

# start the loop 2 seconds after the FDM initializes
setlistener("sim/signals/fdm-initialized", func {
	settimer(instruments.loop, 2);
});

