local MAJOR, MINOR = "LibCenterScreenMessage", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end	--the same or newer version of this lib is already loaded into memory
