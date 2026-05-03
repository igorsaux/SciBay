var/__z_name = null

/proc/__z_detect()
	if (__z_name != null)
		return
	
	if(world.system_type == MS_WINDOWS)
		if(fexists("libz.native.dll"))
			__z_name = "libz.native.dll"
		else
			__z_name = "libz.dll"
	else
		// Fuck you zlib
		// UPD: And linux too
		if(fexists("./liblibz.native.so"))
			__z_name = "./liblibz.native.so"
		else
			__z_name = "./liblibz.so"

#define Z_ERROR_OUT_OF_MEMORY "OutOfMemory"
#define Z_ERROR_UNKNOWN "Unknown"
#define Z_ERROR_ALREADY_RUNNING "AlreadyRunning"
#define Z_ERROR_FAILED_TO_START "FailedToStart"
#define Z_ERROR_ALREADY_BINDED "AlreadyBinded"
#define Z_ERROR_CONTENTS_NOT_FOUND "ContentsNotFound"
#define Z_ERROR_PHASE_NOT_FOUND "PhaseNotFound"

// Global

/// Returns the last error message from the backend, or null if no error.
#define Z_GET_LAST_ERROR(...) call_ext(__z_name, "byond:Z_get_last_error")()

/// Frees all the resources and the memory used by the library.
#define Z_DEINIT(...) call_ext(__z_name, "byond:Z_deinit")()

// WebSocket

// Callback signatures:
//   ON_TEXT_PROC(content: string, address: string, connection_index: number)
//   ON_BINARY_PROC(content: list, address: string, connection_index: number)
//   ON_DISCONNECT_PROC()
// Inside of the ON_TEXT_PROC and ON_BINARY_PROC you can return any falsy value
// to disconnect the connection. But you should not try to disconnect any other connections
// during the callback call.

/// PORT - the port to listen on, 0 for a random port.
/// ON_TEXT_PROC - the callback to call when a text message received, may be null.
/// ON_BINARY_PROC - the callback to call when a binary message received, may be null.
/// CFG - a string of a JSON object with options.
/// Options:
/// - max_connections = 256
/// - max_connections_per_ip = 5
/// - handshake_timeout_ms = 5000
/// - idle_timeout_ms = 300000
/// - ping_interval_ms = 30000
/// - pong_timeout_ms = 10000
/// - max_message_size = 1 * 1024 * 1024
/// - max_frame_size = 1 * 1024 * 1024
/// - max_handshake_size = 8192
/// - max_write_buffer_size = 64 * 1024
/// - rate_limit_messages_per_sec = 25
/// - rate_limit_bytes_per_sec = 1 * 1024 * 1024
/// - initial_message_timeout_ms = 5000
/// - afk_timeout_ms = 0
/// - trust_x_real_ip = false
/// - log = false (0/1)
/// Returns false if the server failed to start (see Z_ERROR_ALREADY_RUNNING, Z_ERROR_FAILED_TO_START).
#define Z_WS_START(PORT, ON_TEXT_PROC, ON_BINARY_PROC, CFG) call_ext(__z_name, "byond:Z_ws_start")(PORT, ON_TEXT_PROC, ON_BINARY_PROC, CFG)

/// Sends a content to the connection by id.
/// Pass a string to send a text message, or a list to send a binary message.
/// Returns false if failed to send, or the connection not found, or the server is not running.
#define Z_WS_SEND(IDX, CONTENT) call_ext(__z_name, "byond:Z_ws_send")(IDX, CONTENT)

/// Ties the OBJ object with the connection.
/// Returns false if the connection not found, or if the connection is already tied, or the server is not running.
#define Z_WS_TIE(IDX, OBJ, ON_TEXT_PROC, ON_BINARY_PROC, ON_DISCONNECT_PROC) call_ext(__z_name, "byond:Z_ws_tie")(IDX, OBJ, ON_TEXT_PROC, ON_BINARY_PROC, ON_DISCONNECT_PROC)

/// Returns a connection id tied to the OBJ, or null if the object is not tied.
#define Z_WS_GET_TIED(OBJ) call_ext(__z_name, "byond:Z_ws_get_tied")(OBJ)

/// Unties the connection with the tied object.
/// Returns false if the connection was not tied, or the connection not found, or the server is not running.
#define Z_WS_UNTIE(IDX) call_ext(__z_name, "byond:Z_ws_untie")(IDX)

/// Disconnects the connection.
/// Returns false if the connection was not found, or the server is not running.
/// Do not call this inside of ON_*_PROC callbacks.
#define Z_WS_DISCONNECT(IDX) call_ext(__z_name, "byond:Z_ws_disconnect")(IDX)

/// Returns true if tick succeeded, false if the server was not running.
/// Returns null on error (e.g., out of memory, see Z_ERROR_OUT_OF_MEMORY).
#define Z_WS_TICK(...) call_ext(__z_name, "byond:Z_ws_tick")()

/// Returns a port the WebSocket server is running on.
/// Returns null if the WebSocket server is not running.
#define Z_WS_GET_PORT(...) call_ext(__z_name, "byond:Z_ws_get_port")()

/// Returns a JSON string with stats:
/// - sent_kilobytes_per_second
/// - received_kilobytes_per_second
/// - tick_duration_ms
/// Returns null if the server is not running or a error was occured.
#define Z_WS_STATS(...) call_ext(__z_name, "byond:Z_ws_stats")()

/// Returns connections count.
/// Returns null if the WebSocket server is not running.
#define Z_WS_CONNECTIONS(...) call_ext(__z_name, "byond:Z_ws_connections")()

/// Stops the WebSocket server. Returns true if the server was running.
#define Z_WS_STOP(...) call_ext(__z_name, "byond:Z_ws_stop")()

// Crypto

/// Generates a LEN bytes and encodes them in url-safe base64 string without padding.
#define Z_CRYPTO_RANDOM_BASE64(LEN) call_ext(__z_name, "byond:Z_crypto_random_base64")(LEN)

/// Content and key must be a string.
/// Returns a url-safe base64 string without padding.
#define Z_CRYPTO_HMAC_SHA256(CONTENT, KEY) call_ext(__z_name, "byond:Z_crypto_hmac_sha256")(CONTENT, KEY)

// Chem

#define Z_CHEM_CREATE(SRC) call_ext(__z_name, "byond:Z_chem_create")(SRC)

#define Z_CHEM_GET_LIQUIDS_VOLUME(SRC) call_ext(__z_name, "byond:Z_chem_get_liquids_volume")(SRC)

#define Z_CHEM_GET_SOLIDS_VOLUME(SRC) call_ext(__z_name, "byond:Z_chem_get_solids_volume")(SRC)

#define Z_CHEM_DESTROY(SRC) call_ext(__z_name, "byond:Z_chem_destroy")(SRC)

#define Z_CHEM_HAS_CONTENTS(SRC) call_ext(__z_name, "byond:Z_chem_has_contents")(SRC)

#define Z_CHEM_GET_LIQUID_PHASES(SRC) call_ext(__z_name, "byond:Z_chem_get_liquid_phases")(SRC)

#define Z_CHEM_GET_SOLID_PHASES(SRC) call_ext(__z_name, "byond:Z_chem_get_solid_phases")(SRC)

#define Z_CHEM_GET_ODOR(SRC) call_ext(__z_name, "byond:Z_chem_get_odor")(SRC)

#define Z_CHEM_GET_LIQUID_PHASE_FLAVOR(SRC, PHASE_IDX) call_ext(__z_name, "byond:Z_chem_get_liquid_phase_flavor")(SRC, PHASE_IDX)

#define Z_CHEM_GET_SOLID_PHASE_FLAVOR(SRC, PHASE_IDX) call_ext(__z_name, "byond:Z_chem_get_solid_phase_flavor")(SRC, PHASE_IDX)

#define Z_CHEM_GET_GAS_FLAVOR(SRC) call_ext(__z_name, "byond:Z_chem_get_gas_flavor")(SRC)

#define Z_CHEM_GET_SOLID_PHASE_PARTICLE_DIAMETER(SRC, PHASE_IDX) call_ext(__z_name, "byond:Z_chem_get_solid_phase_particle_diameter")(SRC, PHASE_IDX)

#define Z_CHEM_INTEGRATE(SRC, DT, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_integrate")(SRC, DT, MAX_VOLUME)

#define Z_CHEM_LIQUID_PHASE_HAS(SRC, PHASE_IDX, MOLECULE) call_ext(__z_name, "byond:Z_chem_liquid_phase_has")(SRC, PHASE_IDX, MOLECULE)

#define Z_CHEM_LIQUID_PHASE_PH(SRC, PHASE_ID) call_ext(__z_name, "byond:Z_chem_liquid_phase_ph")(SRC, PHASE_ID)

#define Z_CHEM_UPDATE_PHASE_TRANSITIONS(SRC, DT, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_update_phase_transitions")(SRC, DT, MAX_VOLUME)

#define Z_CHEM_SETTLE(SRC) call_ext(__z_name, "byond:Z_chem_settle")(SRC)

#define Z_CHEM_EXCHANGE_HEAT(SRC, T_KELVINS, THERMAL_COND, DT) call_ext(__z_name, "byond:Z_chem_exchange_heat")(SRC, T_KELVINS, THERMAL_COND, DT)

#define Z_CHEM_SET_HEAT_CAPACITY(SRC, CAP) call_ext(__z_name, "byond:Z_chem_set_heat_capacity")(SRC, CAP)

#define Z_CHEM_SET_STIRRING(SRC, STIRRING) call_ext(__z_name, "byond:Z_chem_set_stirring")(SRC, STIRRING)

#define Z_CHEM_SET_TEMPERATURE(SRC, T_KELVINS, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_set_temperature")(SRC, T_KELVINS, MAX_VOLUME)

#define Z_CHEM_GET_TEMPERATURE(SRC) call_ext(__z_name, "byond:Z_chem_get_temperature")(SRC)

#define Z_CHEM_GET_LIQUIDS_WEIGHT(SRC) call_ext(__z_name, "byond:Z_chem_get_liquids_weight")(SRC)

#define Z_CHEM_GET_SOLIDS_WEIGHT(SRC) call_ext(__z_name, "byond:Z_chem_get_solids_weight")(SRC)

#define Z_CHEM_SET_GAS_CONTACT_AREA(SRC, AREA) call_ext(__z_name, "byond:Z_chem_set_gas_contact_area")(SRC, AREA)

#define Z_CHEM_GET_BOILED_MOLES(SRC) call_ext(__z_name, "byond:Z_chem_get_boiled_moles")(SRC)

#define Z_CHEM_GET_DEBUG_INFO(SRC, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_get_debug_info")(SRC, MAX_VOLUME)

#define Z_CHEM_UPDATE_PRESSURE(SRC, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_update_pressure")(SRC, MAX_VOLUME)

#define Z_CHEM_GET_PRESSURE(SRC) call_ext(__z_name, "byond:Z_chem_get_pressure")(SRC)

#define Z_CHEM_SET_PRESSURE(SRC, PRESSURE) call_ext(__z_name, "byond:Z_chem_set_pressure")(SRC, PRESSURE)

#define Z_CHEM_CLEAR(SRC) call_ext(__z_name, "byond:Z_chem_clear")(SRC)

#define Z_CHEM_GET_EVAPORATED_MOLES(SRC) call_ext(__z_name, "byond:Z_chem_get_evaporated_moles")(SRC)

#define Z_CHEM_GET_LIQUID_PHASE_MOLES(SRC, PHASE_IDX, MOLECULE) call_ext(__z_name, "byond:Z_chem_get_liquid_phase_moles")(SRC, PHASE_IDX, MOLECULE)

#define Z_CHEM_GET_SOLID_PHASE_MOLES(SRC, PHASE_IDX) call_ext(__z_name, "byond:Z_chem_get_solid_phase_moles")(SRC, PHASE_IDX)

#define Z_CHEM_GET_SOLID_PHASE_MOLECULE(SRC, PHASE_IDX) call_ext(__z_name, "byond:Z_chem_get_solid_phase_molecule")(SRC, PHASE_IDX)

#define Z_CHEM_ADD_VOLUME(SRC, MOLECULE, VOLUME, PARTICLE_DIAMETER) call_ext(__z_name, "byond:Z_chem_add_volume")(SRC, MOLECULE, VOLUME, PARTICLE_DIAMETER)

#define Z_CHEM_POUR(SRC, DST, VOLUME, DST_MAX_VOLUME, STRATIFICATION) call_ext(__z_name, "byond:Z_chem_pour")(SRC, DST, VOLUME, DST_MAX_VOLUME, STRATIFICATION)

#define Z_CHEM_ENSURE_GAS(SRC) call_ext(__z_name, "byond:Z_chem_ensure_gas")(SRC)

#define Z_CHEM_ENSURE_HEADSPACE(SRC, MAX_VOLUME, EXCESS_DST) call_ext(__z_name, "byond:Z_chem_ensure_headspace")(SRC, MAX_VOLUME, EXCESS_DST)

#define Z_CHEM_RESET_GAS(SRC, MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_reset_gas")(SRC, MAX_VOLUME)

#define Z_CHEM_TRANSFER_LIQUID_VOLUME(SRC, DST, VOLUME, DST_MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_transfer_liquid_volume")(SRC, DST, VOLUME, DST_MAX_VOLUME)

#define Z_CHEM_TRANSFER_SOLID_PHASE_VOLUME(SRC, DST, PHASE_IDX, VOLUME, DST_MAX_VOLUME) call_ext(__z_name, "byond:Z_chem_transfer_solid_phase_volume")(SRC, DST, PHASE_IDX, VOLUME, DST_MAX_VOLUME)

#define Z_CHEM_GET_STRATIFICATION_RATE(SRC, G) call_ext(__z_name, "byond:Z_chem_get_stratification_rate")(SRC, G)
