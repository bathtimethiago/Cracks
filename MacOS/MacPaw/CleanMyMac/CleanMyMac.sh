function edit_SMPrivilegedExecutables() {
	/usr/libexec/PlistBuddy -c "Remove :SMPrivilegedExecutables:com.macpaw.CleanMyMac4.Agent" "$1"
	/usr/libexec/PlistBuddy -c "Add :SMPrivilegedExecutables:com.macpaw.CleanMyMac4.Agent string 'identifier com.macpaw.CleanMyMac4.Agent'" "$1"
}
function CMMFoundation_framework_patch() {
	xxd -p -c 0 "$1" - | \
	sed "s/fd7bbfa9fd030091b3000094/200080d2c0035fd6b3000094/; \
	     s/554889e5e817030000/48c7c001000000c300/; " | \
	xxd -r -p -c 0 - "$1"
}
function CMAgentController_patch() {
	xxd -p -c 0 "$1" - | \
	sed "s/ffc30191c0035fd6ff4302d1fc6f03a9fa6704a9f85f05a9f65706a9f44f07a9fd7b08a9fd030291f90300aa/ffc30191c0035fd6000080d2c0035fd6fa6704a9f85f05a9f65706a9f44f07a9fd7b08a9fd030291f90300aa/; \
	     s/0094ffc301d1fa6702a9f85f03a9f65704a9f44f05a9fd7b06a9fd830191f60300aa/0094200080d2c0035fd6f85f03a9f65704a9f44f05a9fd7b06a9fd830191f60300aa/; \
		 s/554889e54157415641554154534883ec284989fe48897dd0/48c7c001000000c341554154534883ec284989fe48897dd0/; \
	     s/415f5dc3554889e54157415641554154534883ec584989fd/415f5dc348c7c000000000c341554154534883ec584989fd/; " | \
	xxd -r -p -c 0 - "$1"
}
function cmmx_agent_patch() {
	xxd -p -c 0 "$1" - | \
	sed "s/f40300aae0090034/f40300aa340080d2/; \
	     s/84c00f8483010000/84c0909090909090/; \
		 s/20616e6420616e63686f72206170706c652067656e6572696320616e64206365727469666963617465206c6561665b7375626a6563742e4f555d203d20225338455838324e4a503622/20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020/g; " | \
	xxd -r -p -c 0 - "$1"
	codesign -fs - --all-architectures --timestamp=none "$1"
}
function cmmx_patch() {
	local cmmx_exe_path="$1/Contents/MacOS/CleanMyMac X"
	xxd -p -c 0 "$cmmx_exe_path" - | \
	sed "s/fc6fbea9fd7b01a9fd430091ff831bd1e8631191/200080d2c0035fd6fd430091ff831bd1e8631191/; \
		 s/554889e54881eca0060000/48c7c001000000c3060000/; " | \
	xxd -r -p -c 0 - "$cmmx_exe_path"

	CMAgentController_patch "$cmmx_exe_path"
	CMAgentController_patch "$1/Contents/Library/LoginItems/CleanMyMac X Menu.app/Contents/MacOS/CleanMyMac X Menu"

	edit_SMPrivilegedExecutables "$1/Contents/Info.plist"
	edit_SMPrivilegedExecutables "$1/Contents/Library/LoginItems/CleanMyMac X Menu.app/Contents/Info.plist"
	
	CMMFoundation_framework_patch "$1/Contents/Library/LoginItems/CleanMyMac X HealthMonitor.app/Contents/Frameworks/CMMFoundation.framework/Versions/A/CMMFoundation"
	CMMFoundation_framework_patch "$1/Contents/Library/LoginItems/CleanMyMac X Menu.app/Contents/Frameworks/CMMFoundation.framework/Versions/A/CMMFoundation"

	cmmx_agent_patch "$1/Contents/Library/LaunchServices/com.macpaw.CleanMyMac4.Agent"
	cmmx_agent_patch "$1/Contents/Library/LoginItems/CleanMyMac X Menu.app/Contents/Library/LaunchServices/com.macpaw.CleanMyMac4.Agent"

	codesign -fs - --all-architectures --deep --timestamp=none "$1" && xattr -cr "$1"
}; cmmx_patch "/Applications/CleanMyMac X.app"