var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog", "Aircraft/VIP/Systems/radio.xml");

gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");
