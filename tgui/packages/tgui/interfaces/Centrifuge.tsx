import { Component } from "inferno";
import { useBackend } from "../backend";
import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from "../components";
import { Window } from "../layouts";

interface CentrifugeContainer {
  slot: number;
  occupied: number;
  container_name: string | null;
  container_ref: string | null;
}

interface CentrifugeRotor {
  name: string;
  max_rpm: number;
  radius: number;
  slots_count: number;
  integrity: number;
  cycles_used: number;
  max_cycles: number;
  is_balanced: number;
}

interface CentrifugeData {
  is_running: number;
  anchored: number;
  has_rotor: number;
  target_rpm_settable: number;
  target_duration_settable: number;
  target_temp_settable: number;
  target_rpm: number;
  target_temperature: number;
  target_duration: number;
  max_rpm: number;
  min_temp: number;
  max_temp: number;
  current_rpm: number;
  current_temp: number;
  time_remaining: number;
  rotor: CentrifugeRotor | null;
  containers: CentrifugeContainer[];
}

/**
 * Computes relative centrifugal force (g) from RPM and radius.
 * Formula from DM: g = 1.118e-5 * radius_cm * rpm^2
 */
const computeG = (rpm: number, radiusM: number): number => {
  const radiusCm = radiusM * 100;

  return 1.118e-5 * radiusCm * rpm * rpm;
};

/**
 * Formats deciseconds into MM:SS display.
 */
const formatDuration = (ds: number): string => {
  const totalSeconds = Math.floor(ds / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;

  return `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
};

/**
 * Converts Kelvin to Celsius for display.
 */
const kelvinToCelsius = (k: number): number => {
  return k - 273.15;
};

/**
 * Converts Celsius to Kelvin for backend.
 */
const celsiusToKelvin = (c: number): number => {
  return c + 273.15;
};

/**
 * Rounds a number to specified decimal places.
 */
const round = (value: number, decimals: number = 0): number => {
  const factor = Math.pow(10, decimals);
  return Math.round(value * factor) / factor;
};

export const Centrifuge = (props, context) => {
  const { act, data } = useBackend<CentrifugeData>(context);

  const {
    is_running,
    anchored,
    has_rotor,
    target_rpm_settable,
    target_duration_settable,
    target_temp_settable,
    target_rpm,
    target_temperature,
    target_duration,
    max_rpm,
    min_temp,
    max_temp,
    current_rpm,
    current_temp,
    time_remaining,
    rotor,
    containers,
  } = data;

  const running = !!is_running;
  const hasRotor = !!has_rotor;
  const canSetRpm = !!target_rpm_settable;
  const canSetDuration = !!target_duration_settable;
  const canSetTemp = !!target_temp_settable;

  // Precompute g-force if rotor is present
  const currentG = hasRotor && rotor ? computeG(current_rpm, rotor.radius) : 0;
  const targetG = hasRotor && rotor ? computeG(target_rpm, rotor.radius) : 0;
  const maxG = hasRotor && rotor ? computeG(max_rpm, rotor.radius) : 0;

  // Integrity and cycle ratios for progress bars
  const integrityRatio = hasRotor && rotor ? rotor.integrity : 0;
  const cycleRatio =
    hasRotor && rotor ? rotor.cycles_used / Math.max(rotor.max_cycles, 1) : 0;

  // Temperature display in Celsius
  const currentTempC = kelvinToCelsius(current_temp);
  const targetTempC = kelvinToCelsius(target_temperature);
  const minTempC = kelvinToCelsius(min_temp);
  const maxTempC = kelvinToCelsius(max_temp);

  return (
    <Window title="Centrifuge" width={850} height={680}>
      <Window.Content>
        <Stack fill vertical>
          {/* Status header */}
          <Stack.Item>
            <StatusHeader
              running={running}
              anchored={!!anchored}
              hasRotor={hasRotor}
              timeRemaining={time_remaining}
              isBalanced={hasRotor && rotor ? !!rotor.is_balanced : false}
            />
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              {/* Left panel: controls */}
              <Stack.Item grow basis={0}>
                <Section fill title="Controls">
                  <Stack vertical fill>
                    {/* Power controls */}
                    <Stack.Item>
                      <PowerControls
                        running={running}
                        canStart={hasRotor && !!anchored}
                        onStart={() => act("turn_on")}
                        onStop={() => act("turn_off")}
                      />
                    </Stack.Item>

                    <Stack.Item>
                      <Divider />
                    </Stack.Item>

                    {/* Parameter controls */}
                    <Stack.Item grow>
                      <ParameterControls
                        canSetRpm={canSetRpm}
                        canSetDuration={canSetDuration}
                        canSetTemp={canSetTemp}
                        targetRpm={target_rpm}
                        targetDuration={target_duration}
                        targetTempC={targetTempC}
                        maxRpm={max_rpm}
                        minTempC={minTempC}
                        maxTempC={maxTempC}
                        targetG={targetG}
                        maxG={maxG}
                        hasRotor={hasRotor}
                        rotorRadius={rotor?.radius ?? 0}
                        onSetRpm={(value) => act("set_rpm", { rpm: value })}
                        onSetDuration={(value) =>
                          act("set_duration", { duration: value })
                        }
                        onSetTemp={(value) =>
                          act("set_temp", { temp: celsiusToKelvin(value) })
                        }
                        onSetG={(value) => act("set_g", { g: value })}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

              {/* Right panel: rotor visualization */}
              <Stack.Item grow basis={0}>
                <Section fill title="Rotor Chamber">
                  <Stack vertical fill>
                    {/* Live telemetry */}
                    <Stack.Item>
                      <TelemetryDisplay
                        running={running}
                        currentRpm={current_rpm}
                        currentG={currentG}
                        currentTempC={currentTempC}
                        timeRemaining={time_remaining}
                      />
                    </Stack.Item>

                    <Stack.Item>
                      <Divider />
                    </Stack.Item>

                    {/* Rotor status */}
                    <Stack.Item>
                      <RotorStatus
                        rotor={rotor}
                        integrityRatio={integrityRatio}
                        cycleRatio={cycleRatio}
                      />
                    </Stack.Item>

                    <Stack.Item grow>
                      <Divider />
                    </Stack.Item>

                    {/* Slot visualization */}
                    <Stack.Item grow>
                      <SlotVisualization
                        containers={containers}
                        slotsCount={rotor?.slots_count ?? 0}
                        running={running}
                        onEject={(slot) => act("eject_container", { slot })}
                        onInsert={(slot) => act("insert_container", { slot })}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * Displays the top status bar with running state and alerts.
 */
const StatusHeader = (props: {
  running: boolean;
  anchored: boolean;
  hasRotor: boolean;
  timeRemaining: number;
  isBalanced: boolean;
}) => {
  const { running, anchored, hasRotor, isBalanced } = props;

  let statusColor = "label";
  let statusText = "READY";
  let icon = "check-circle";

  if (running) {
    statusColor = "good";
    statusText = "SPINNING";
    icon = "sync";
  } else if (!anchored) {
    statusColor = "average";
    statusText = "UNANCHORED";
    icon = "warning";
  } else if (!hasRotor) {
    statusColor = "bad";
    statusText = "NO ROTOR";
    icon = "times-circle";
  } else if (!isBalanced) {
    statusColor = "average";
    statusText = "UNBALANCED";
    icon = "balance-scale";
  }

  return (
    <NoticeBox color={statusColor}>
      <Flex align="center" justify="space-between">
        <Flex.Item>
          <Icon name={icon} spin={running} mr={1} />
          <Box inline bold>
            {statusText}
          </Box>
        </Flex.Item>

        {running && (
          <Flex.Item>
            <Box inline color="label">
              Time remaining:
            </Box>
            <Box inline bold>
              {formatDuration(props.timeRemaining)}
            </Box>
          </Flex.Item>
        )}
      </Flex>
    </NoticeBox>
  );
};

/**
 * Power on/off controls with safety interlocks.
 */
const PowerControls = (props: {
  running: boolean;
  canStart: boolean;
  onStart: () => void;
  onStop: () => void;
}) => {
  const { running, canStart, onStart, onStop } = props;

  return (
    <Flex align="center" justify="space-around">
      <Flex.Item>
        <Button
          icon="power-off"
          content="START"
          color="good"
          disabled={running || !canStart}
          onClick={onStart}
          fontSize="1.2em"
          px={2}
          py={1}
        />
      </Flex.Item>
      <Flex.Item>
        <Button
          icon="stop"
          content="STOP"
          color="bad"
          disabled={!running}
          onClick={onStop}
          fontSize="1.2em"
          px={2}
          py={1}
        />
      </Flex.Item>
    </Flex>
  );
};

/**
 * Parameter input controls for RPM, G-force, duration, and temperature.
 */
const ParameterControls = (props: {
  canSetRpm: boolean;
  canSetDuration: boolean;
  canSetTemp: boolean;
  targetRpm: number;
  targetDuration: number;
  targetTempC: number;
  maxRpm: number;
  minTempC: number;
  maxTempC: number;
  targetG: number;
  maxG: number;
  hasRotor: boolean;
  rotorRadius: number;
  onSetRpm: (value: number) => void;
  onSetDuration: (value: number) => void;
  onSetTemp: (value: number) => void;
  onSetG: (value: number) => void;
}) => {
  const {
    canSetRpm,
    canSetDuration,
    canSetTemp,
    targetRpm,
    targetDuration,
    targetTempC,
    maxRpm,
    minTempC,
    maxTempC,
    targetG,
    maxG,
    hasRotor,
    rotorRadius,
    onSetRpm,
    onSetDuration,
    onSetTemp,
    onSetG,
  } = props;

  return (
    <LabeledList>
      {canSetRpm && (
        <>
          <LabeledList.Item label="Target RPM">
            <NumberInput
              value={targetRpm}
              minValue={0}
              maxValue={maxRpm}
              step={100}
              stepPixelSize={5}
              unit="RPM"
              onChange={(e, value) => onSetRpm(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Target RCF">
            <NumberInput
              value={round(targetG, 1)}
              minValue={0}
              maxValue={round(maxG, 1)}
              step={10}
              stepPixelSize={2}
              unit="x g"
              format={(value) => round(value, 1).toString()}
              onChange={(e, value) => {
                if (!hasRotor || rotorRadius <= 0) return;
                onSetG(value);
              }}
            />
          </LabeledList.Item>
        </>
      )}

      {!canSetRpm && (
        <LabeledList.Item label="RPM">
          <Box color="label">{targetRpm} RPM (fixed)</Box>
        </LabeledList.Item>
      )}

      {canSetDuration && (
        <LabeledList.Item label="Duration">
          <NumberInput
            value={targetDuration}
            minValue={100}
            maxValue={864000}
            step={100}
            stepPixelSize={3}
            unit="ds"
            format={(value) => formatDuration(value)}
            onChange={(e, value) => onSetDuration(value)}
          />
        </LabeledList.Item>
      )}

      {!canSetDuration && (
        <LabeledList.Item label="Duration">
          <Box color="label">{formatDuration(targetDuration)} (fixed)</Box>
        </LabeledList.Item>
      )}

      {canSetTemp && (
        <LabeledList.Item label="Temperature">
          <NumberInput
            value={round(targetTempC, 1)}
            minValue={round(minTempC, 1)}
            maxValue={round(maxTempC, 1)}
            step={1}
            stepPixelSize={5}
            unit="°C"
            format={(value) => round(value, 1).toString()}
            onChange={(e, value) => onSetTemp(value)}
          />
        </LabeledList.Item>
      )}

      {!canSetTemp && (
        <LabeledList.Item label="Temperature">
          <Box color="label">{round(targetTempC, 1)}°C (fixed)</Box>
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

/**
 * Live telemetry readout showing current operating parameters.
 */
const TelemetryDisplay = (props: {
  running: boolean;
  currentRpm: number;
  currentG: number;
  currentTempC: number;
  timeRemaining: number;
}) => {
  const { running, currentRpm, currentG, currentTempC, timeRemaining } = props;

  return (
    <Box>
      <Flex justify="space-between" mb={1}>
        <Flex.Item>
          <Box color="label" fontSize="0.9em">
            RPM
          </Box>
          <Box
            fontSize="1.3em"
            bold
            color={running ? "good" : "white"}
            style={{
              transition: "color 0.3s ease",
            }}
          >
            {Math.round(currentRpm).toLocaleString()}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box color="label" fontSize="0.9em">
            RCF
          </Box>
          <Box
            fontSize="1.3em"
            bold
            color={running ? "good" : "white"}
            style={{
              transition: "color 0.3s ease",
            }}
          >
            {round(currentG, 1)} x g
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box color="label" fontSize="0.9em">
            Temp
          </Box>
          <Box
            fontSize="1.3em"
            bold
            color={running ? "good" : "white"}
            style={{
              transition: "color 0.3s ease",
            }}
          >
            {round(currentTempC, 1)}°C
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box color="label" fontSize="0.9em">
            Remaining
          </Box>
          <Box
            fontSize="1.3em"
            bold
            color={running ? "good" : "white"}
            style={{
              transition: "color 0.3s ease",
            }}
          >
            {formatDuration(timeRemaining)}
          </Box>
        </Flex.Item>
      </Flex>

      {/* RPM progress bar */}
      <ProgressBar
        value={currentRpm}
        minValue={0}
        maxValue={150000}
        color={running ? "good" : "default"}
        mt={1}
      >
        <Box textAlign="center">
          {Math.round(currentRpm).toLocaleString()} RPM
        </Box>
      </ProgressBar>
    </Box>
  );
};

/**
 * Displays rotor health and cycle information.
 */
const RotorStatus = (props: {
  rotor: CentrifugeRotor | null;
  integrityRatio: number;
  cycleRatio: number;
}) => {
  const { rotor, integrityRatio, cycleRatio } = props;

  if (!rotor) {
    return (
      <NoticeBox color="bad">
        <Icon name="exclamation-triangle" mr={1} />
        No rotor installed.
      </NoticeBox>
    );
  }

  const integrityColor =
    integrityRatio > 0.7 ? "good" : integrityRatio > 0.3 ? "average" : "bad";
  const cycleColor =
    cycleRatio < 0.5 ? "good" : cycleRatio < 0.8 ? "average" : "bad";

  return (
    <Box>
      <Flex justify="space-between" mb={1}>
        <Box>
          <Box color="label" fontSize="0.8em">
            Rotor
          </Box>
          <Box bold>{rotor.name}</Box>
        </Box>
        <Box textAlign="right">
          <Box color="label" fontSize="0.8em">
            Radius
          </Box>
          <Box bold>{rotor.radius * 100} cm</Box>
        </Box>
        <Box textAlign="right">
          <Box color="label" fontSize="0.8em">
            Max RPM
          </Box>
          <Box bold>{rotor.max_rpm.toLocaleString()}</Box>
        </Box>
      </Flex>

      <Box mb={1}>
        <Flex justify="space-between" mb={0.5}>
          <Box color="label" fontSize="0.8em">
            Integrity
          </Box>
          <Box fontSize="0.8em" bold>
            {Math.round(integrityRatio * 100)}%
          </Box>
        </Flex>
        <ProgressBar
          value={integrityRatio}
          minValue={0}
          maxValue={1}
          color={integrityColor}
        />
      </Box>

      <Box>
        <Flex justify="space-between" mb={0.5}>
          <Box color="label" fontSize="0.8em">
            Service Life
          </Box>
          <Box fontSize="0.8em" bold>
            {rotor.cycles_used.toLocaleString()} /{" "}
            {rotor.max_cycles.toLocaleString()} cycles
          </Box>
        </Flex>
        <ProgressBar
          value={cycleRatio}
          minValue={0}
          maxValue={1}
          color={cycleColor}
        />
      </Box>
    </Box>
  );
};

/**
 * Circular slot visualization for the rotor.
 * Slots are arranged in a circle. Clicking an occupied slot ejects,
 * clicking an empty slot inserts from active hand.
 */
class SlotVisualization extends Component<{
  containers: CentrifugeContainer[];
  slotsCount: number;
  running: boolean;
  onEject: (slot: number) => void;
  onInsert: (slot: number) => void;
}> {
  private spinGroup: SVGGElement | null = null;
  private slotTextGroups: SVGGElement[] = [];
  private spinInterval: ReturnType<typeof setInterval> | null = null;
  private angle: number = 0;

  componentDidMount() {
    if (this.props.running) {
      this.startSpin();
    }
  }

  componentDidUpdate(
    prevProps: Readonly<{
      containers: CentrifugeContainer[];
      slotsCount: number;
      running: boolean;
      onEject: (slot: number) => void;
      onInsert: (slot: number) => void;
    }>,
  ) {
    if (prevProps.running !== this.props.running) {
      if (this.props.running) {
        this.startSpin();
      } else {
        this.stopSpin();
      }
    }
  }

  componentWillUnmount() {
    this.stopSpin();
  }

  private startSpin() {
    if (this.spinInterval !== null) {
      return;
    }
    const { slotsCount } = this.props;
    const center = 150;
    const radius = 100;

    this.spinInterval = setInterval(() => {
      this.angle = (this.angle + 36) % 360;
      const angleRad = (this.angle * Math.PI) / 180;

      if (this.spinGroup) {
        this.spinGroup.setAttribute(
          "transform",
          `rotate(${this.angle}, ${center}, ${center})`,
        );
      }

      for (let i = 0; i < slotsCount; i++) {
        const baseAngle = (i / slotsCount) * Math.PI * 2 - Math.PI / 2;
        const x = center + Math.cos(baseAngle + angleRad) * radius;
        const y = center + Math.sin(baseAngle + angleRad) * radius;
        const group = this.slotTextGroups[i];

        if (group) {
          group.setAttribute("transform", `translate(${x}, ${y})`);
        }
      }
    }, 50);
  }

  private stopSpin() {
    if (this.spinInterval !== null) {
      clearInterval(this.spinInterval);
      this.spinInterval = null;
    }

    if (this.spinGroup) {
      this.spinGroup.removeAttribute("transform");
    }

    const { slotsCount } = this.props;
    const center = 150;
    const radius = 100;

    for (let i = 0; i < slotsCount; i++) {
      const baseAngle = (i / slotsCount) * Math.PI * 2 - Math.PI / 2;
      const x = center + Math.cos(baseAngle) * radius;
      const y = center + Math.sin(baseAngle) * radius;
      const group = this.slotTextGroups[i];

      if (group) {
        group.setAttribute("transform", `translate(${x}, ${y})`);
      }
    }

    this.angle = 0;
  }

  public render() {
    const { containers, slotsCount, running, onEject, onInsert } = this.props;

    if (slotsCount <= 0) {
      return (
        <Box textAlign="center" color="label" mt={2}>
          No rotor installed.
        </Box>
      );
    }

    const viewBoxSize = 300;
    const center = viewBoxSize / 2;
    const radius = 100;
    const slotRadius = 30;
    const hubRadius = 35;
    const svgSize = 280;

    const slots: CentrifugeContainer[] = [];

    for (let i = 1; i <= slotsCount; i++) {
      const found = containers.find((c) => c.slot === i);

      slots.push(
        found || {
          slot: i,
          occupied: 0,
          container_name: null,
          container_ref: null,
        },
      );
    }

    return (
      <Box position="relative" height={`${svgSize}px`} width="100%">
        <svg
          viewBox={`0 0 ${viewBoxSize} ${viewBoxSize}`}
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            width: `${svgSize}px`,
            height: `${svgSize}px`,
          }}
        >
          <g
            ref={(el: SVGGElement | null) => {
              this.spinGroup = el;
            }}
          >
            {slots.map((slot, index) => {
              const angleRad = (index / slotsCount) * Math.PI * 2 - Math.PI / 2;
              const x = center + Math.cos(angleRad) * radius;
              const y = center + Math.sin(angleRad) * radius;
              return (
                <line
                  key={`line-${slot.slot}`}
                  x1={center}
                  y1={center}
                  x2={x}
                  y2={y}
                  stroke="#444444"
                  strokeWidth="3"
                />
              );
            })}

            {slots.map((slot, index) => {
              const angleRad = (index / slotsCount) * Math.PI * 2 - Math.PI / 2;
              const x = center + Math.cos(angleRad) * radius;
              const y = center + Math.sin(angleRad) * radius;
              const occupied = !!slot.occupied;

              return (
                <circle
                  key={`circle-${slot.slot}`}
                  cx={x}
                  cy={y}
                  r={slotRadius}
                  fill={occupied ? "#64b464" : "#3c3c3c"}
                  stroke={occupied ? "#8cff8c" : "#777777"}
                  strokeWidth="2"
                  style={{
                    cursor: running ? "not-allowed" : "pointer",
                    transition: "all 0.2s ease",
                  }}
                  onClick={() => {
                    if (running) return;
                    if (occupied) {
                      onEject(slot.slot);
                    } else {
                      onInsert(slot.slot);
                    }
                  }}
                />
              );
            })}
          </g>

          {slots.map((slot, index) => {
            const angleRad = (index / slotsCount) * Math.PI * 2 - Math.PI / 2;
            const x = center + Math.cos(angleRad) * radius;
            const y = center + Math.sin(angleRad) * radius;
            const occupied = !!slot.occupied;

            return (
              <g
                key={`text-${slot.slot}`}
                ref={(el: SVGGElement | null) => {
                  if (el) this.slotTextGroups[index] = el;
                }}
                transform={`translate(${x}, ${y})`}
                pointerEvents="none"
              >
                <text
                  textAnchor="middle"
                  fill="#cccccc"
                  fontSize="12"
                  fontWeight="bold"
                  y={-6}
                >
                  #{slot.slot}
                </text>
                <text
                  textAnchor="middle"
                  fill={occupied ? "#8cff8c" : "#888888"}
                  fontSize="10"
                  y={10}
                >
                  {occupied
                    ? slot.container_name?.substring(0, 10) || "???"
                    : "[empty]"}
                </text>
              </g>
            );
          })}

          <circle
            cx={center}
            cy={center}
            r={hubRadius}
            fill="#3c3c3c"
            stroke="#666666"
            strokeWidth="2"
          />
          <text
            x={center}
            y={center + 5}
            textAnchor="middle"
            fill="#999999"
            fontSize="14"
            fontWeight="bold"
          >
            HUB
          </text>
        </svg>

        {/* Legend */}
        <Flex justify="center" mt={1}>
          <Flex.Item mx={1}>
            <Box inline color="good">
              ●
            </Box>{" "}
            <Box inline fontSize="0.8em" color="label">
              Occupied
            </Box>
          </Flex.Item>
          <Flex.Item mx={1}>
            <Box inline color="label">
              ●
            </Box>{" "}
            <Box inline fontSize="0.8em" color="label">
              Empty
            </Box>
          </Flex.Item>
        </Flex>
      </Box>
    );
  }
}
