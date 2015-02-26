# Otto the experimental autopilot-helper in Nasal

var check=func() {
	setprop("/controls/autoflight/diff_to_climb", 0);
	setprop("/controls/flight/rudder_comp", getprop("/controls/flight/rudder"));
	setprop("/controls/flight/rudder", 0);
	checkData();
}

var checkData=func() {
#	print("---------------------------------------------------------------------");
#	print("vertical_mode=", getprop("controls/autoflight/vertical_mode"));
#	print("indicated alt=", getprop("instrumentation/altimeter/indicated-altitude-ft"));
#	print("ap set alt=", getprop("/autopilot/settings/altitude-setting-ft"));
#	print("ap target climb=", getprop("/autopilot/internal/target-climb-rate-fps"));
#	print("vert. speed=", getprop("/velocities/vertical-speed-fps"));
#	print("ap target pitch=", getprop("/autopilot/internal/target-pitch-deg"));
#	print("elevator trim=", getprop("/controls/flight/elevator-trim"));

	var test=math.abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-getprop("/autopilot/settings/altitude-setting-ft"));
	if (test<1000) {
		var test2=getprop("/autopilot/settings/altitude-setting-ft")-getprop("instrumentation/altimeter/indicated-altitude-ft");
		setprop("/controls/autoflight/diff_to_climb", test2);
	}
	if (test<100 and !getprop("controls/autoflight/app-engage") and !getprop("controls/autoflight/vnav-engage")) {
		var test2=getprop("/autopilot/settings/altitude-setting-ft")-getprop("instrumentation/altimeter/indicated-altitude-ft");
		setprop("/controls/autoflight/diff_to_climb", test2);
		setprop("controls/autoflight/fpa-engage", "false");
		setprop("controls/autoflight/alt-engage", "true");
		setprop("controls/autoflight/flch-engage", "false");
		setprop("controls/autoflight/vs-engage", "false");
		setprop("controls/autoflight/vertical_mode", 2);
	}

	if (getprop("controls/autoflight/vertical_mode")==0) {
#print("VR=", getprop("/instrumentation/fmc/vspeeds/VR"));
#print("AS=", getprop("/velocities/airspeed-kt"));
		var spd1=getprop("/instrumentation/fmc/vspeeds/VR");
		var spd2=getprop("/velocities/airspeed-kt");
		if (spd1>spd2) {
			setprop("/controls/autoflight/vr-ref-alt", getprop("/velocities/vertical-speed-fps"));
#print("Auto Take-Off is COLD");
		} else {
			setprop("/controls/autoflight/vr-ref-alt", 10000);
#print("Auto Take-Off is HOT");
		}
#print("-----------------------------------------------------------------------------");
	}

	settimer (checkData, 1);
}

var setVSabsolute=func() {
	setprop("/controls/autoflight/vertical-speed-abs", math.abs(getprop("/controls/autoflight/vertical-speed-select")));
}

var setAPengage=func() {
	var found="false";
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("/controls/autoflight/fpa-engage")) {
			setprop("controls/autoflight/vertical_mode", 0);
			setprop("controls/autoflight/fpa-engage", "true");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "false");
			found="true";
		}
		if (getprop("controls/autoflight/alt-engage") and !found) {
			if (getprop("controls/autoflight/flch-engage") and !found) {
				setprop("controls/autoflight/vertical_mode", 1);
				setprop("/autopilot/settings/altitude-setting-ft", getprop("controls/autoflight/altitude-select"));
				setprop("controls/autoflight/fpa-engage", "false");
				setprop("controls/autoflight/alt-engage", "true");
				setprop("controls/autoflight/flch-engage", "true");
				setprop("controls/autoflight/vs-engage", "false");
				setprop("controls/autoflight/app-engage", "false");
				setprop("controls/autoflight/vnav-engage", "false");
			} else {
				setprop("controls/autoflight/vertical_mode", 2);
				setprop("controls/autoflight/fpa-engage", "false");
				setprop("controls/autoflight/alt-engage", "true");
				setprop("controls/autoflight/flch-engage", "false");
				setprop("controls/autoflight/vs-engage", "false");
				setprop("controls/autoflight/app-engage", "false");
				setprop("controls/autoflight/vnav-engage", "false");
			}
			found="true";
		}
		if (getprop("controls/autoflight/vs-engage") and !found) {
			setprop("controls/autoflight/vertical_mode", 3);
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "true");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "false");
			found="true";
		}
		if (getprop("controls/autoflight/app-engage") and !found) {
			setprop("controls/autoflight/vertical_mode", 4);
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "true");
			setprop("controls/autoflight/vnav-engage", "false");
			found="true";
		}
		if (getprop("controls/autoflight/vnav-engage") and !found) {
			setprop("controls/autoflight/vertical_mode", 5);
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "true");
			found="true";
		}
		if (!found) {
			setprop("controls/autoflight/vertical_mode", 2);
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setFPAengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("controls/autoflight/fpa-engage")) {
			setprop("controls/autoflight/vertical_mode", 0);
			setprop("controls/autoflight/fpa-engage", "true");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "false");
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setALTengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("/controls/autoflight/alt-engage")) {
			if (getprop("controls/autoflight/flch-engage")==1) {
				setprop("controls/autoflight/vertical_mode", 1);
				setprop("controls/autoflight/fpa-engage", "false");
				setprop("controls/autoflight/alt-engage", "true");
				setprop("controls/autoflight/flch-engage", "true");
				setprop("controls/autoflight/vs-engage", "false");
				setprop("controls/autoflight/app-engage", "false");
				setprop("controls/autoflight/vnav-engage", "false");
			} else {
				setprop("controls/autoflight/vertical_mode", 2);
				setprop("controls/autoflight/fpa-engage", "false");
				setprop("controls/autoflight/alt-engage", "true");
				setprop("controls/autoflight/flch-engage", "false");
				setprop("controls/autoflight/vs-engage", "false");
				setprop("controls/autoflight/app-engage", "false");
				setprop("controls/autoflight/vnav-engage", "false");
			}
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setFLCHengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("controls/autoflight/flch-engage")) {
			setprop("/autopilot/settings/altitude-setting-ft", getprop("controls/autoflight/altitude-select"));
			var test=getprop("/autopilot/settings/altitude-setting-ft")-getprop("instrumentation/altimeter/indicated-altitude-ft");
			setprop("/controls/autoflight/diff_to_climb", test);
			setprop("controls/autoflight/vertical_mode", 1);
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "true");
			setprop("controls/autoflight/flch-engage", "true");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "false");
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setVSengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("controls/autoflight/vs-engage")) {
			setprop("controls/autoflight/vertical_mode", 3);
			setprop("/autopilot/settings/altitude-setting-ft", getprop("controls/autoflight/altitude-select"));
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "true");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "false");
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setAPPengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("controls/autoflight/app-engage")) {
			setprop("controls/autoflight/vertical_mode", 4);
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "true");
			setprop("controls/autoflight/vnav-engage", "false");
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var setVNAVengage=func() {
	if (getprop("/controls/autoflight/autopilot/engage")) {
		if (getprop("controls/autoflight/vnav-engage")) {
			setprop("controls/autoflight/vertical_mode", 5);
			if (getprop("autopilot/route-manager/route/wp/altitude-ft")>200) {
				setprop("/autopilot/settings/altitude-setting-ft", getprop("autopilot/route-manager/route/wp/altitude-ft"));
				setprop("/controls/autoflight/vnav-alt-ft", getprop("autopilot/route-manager/route/wp/altitude-ft"));
				setprop("/controls/autoflight/altitude-select", getprop("autopilot/route-manager/route/wp/altitude-ft"));
			} else {
				setprop("/autopilot/settings/altitude-setting-ft", getprop("/autopilot/route-manager/cruise/altitude-ft"));
				setprop("/controls/autoflight/vnav-alt-ft", getprop("/autopilot/route-manager/cruise/altitude-ft"));
				setprop("/controls/autoflight/altitude-select", getprop("/autopilot/route-manager/cruise/altitude-ft"));
			}
			setprop("controls/autoflight/fpa-engage", "false");
			setprop("controls/autoflight/alt-engage", "false");
			setprop("controls/autoflight/flch-engage", "false");
			setprop("controls/autoflight/vs-engage", "false");
			setprop("controls/autoflight/app-engage", "false");
			setprop("controls/autoflight/vnav-engage", "true");
		}
	} else {
		setprop("controls/autoflight/vertical_mode", -1);
	}
}

var printMessage=func() {
#	print("vmode set to ", getprop("/controls/autoflight/vertical_mode"));
}

var waypointChange=func() {
	var current=getprop("autopilot/route-manager/current-wp");
	if (current>0) {
		var active_route=getprop("/autopilot/route-manager/active");
		var vmode=getprop("/controls/autoflight/vertical_mode");
		var wp_altitude=getprop("autopilot/route-manager/route/wp["~current~"]/altitude-ft");

		if (active_route) {
			if (vmode==5) {
				if (wp_altitude>200) {
					setprop("/autopilot/settings/altitude-setting-ft", getprop("autopilot/route-manager/route/wp/altitude-ft"));
					setprop("/controls/autoflight/vnav-alt-ft", getprop("autopilot/route-manager/route/wp/altitude-ft"));
					setprop("/controls/autoflight/altitude-select", wp_altitude);
				} else {
					setprop("/autopilot/settings/altitude-setting-ft", getprop("/autopilot/route-manager/cruise/altitude-ft"));
					setprop("/controls/autoflight/vnav-alt-ft", getprop("/autopilot/route-manager/cruise/altitude-ft"));
					setprop("/controls/autoflight/altitude-select", getprop("/autopilot/route-manager/cruise/altitude-ft"));
				}
			}
		}
	}
}

var rudder_check=func() {
	if (getprop("/gear/gear[0]/wow")) {
# print("rudder=", getprop("/controls/flight/rudder"));
# print("comp=", getprop("/controls/flight/rudder_comp"));
		setprop("controls/flight/rudder", getprop("/controls/flight/rudder")-getprop("/controls/flight/rudder_comp"))
	}
}

# var vm_listener=setlistener("/controls/autoflight/vertical_mode", printMessage);
var vsabs_listener=setlistener("/controls/autoflight/vertical-speed-select", setVSabsolute);
var ap_listener=setlistener("/controls/autoflight/autopilot/engage", setAPengage);
var fpa_listener=setlistener("/controls/autoflight/fpa-engage", setFPAengage);
var alt_listener=setlistener("/controls/autoflight/alt-engage", setALTengage);
var flch_listener=setlistener("/controls/autoflight/flch-engage", setFLCHengage);
var vs_listener=setlistener("/controls/autoflight/vs-engage", setVSengage);
var app_listener=setlistener("/controls/autoflight/app-engage", setAPPengage);
var vnav_listener=setlistener("/controls/autoflight/vnav-engage", setVNAVengage);
var wp_listener=setlistener("/autopilot/route-manager/wp/id", waypointChange);
var rudder_listener=setlistener("/controls/flight/rudder", rudder_check);
settimer (check, 1);

